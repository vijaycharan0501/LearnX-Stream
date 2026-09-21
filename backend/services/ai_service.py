import json
import logging
import os
import re
from typing import Any, Dict, List, Optional

from dotenv import load_dotenv
from models.schemas import (
    AnswerPayload,
    AnswerSection,
    ConceptItem,
    MaterialAnalysisResponse,
    QuickCheck,
    RecommendedRepresentation,
    StepItem,
)

# Load environment variables from .env
load_dotenv()

logger = logging.getLogger("learnx_ai_service")
logging.basicConfig(level=logging.INFO)


def choose_visualization_type(topic: str, text: str = "") -> str:
    """
    Determines the most suitable visual explanation method for a concept.

    Returns one of:
    - visualExplanation / algorithm (Algorithms, search, sorting, pointer arrays)
    - simulation (Physics formulas, reactive circuits, math relationships)
    - conceptMap (OOP hierarchies, taxonomies, systems, structures)
    - workflow / process (Cycles, photosynthesis, water cycle, protocols, handshakes)
    - diagram (SQL JOINs, entity relations, Venn comparisons)
    - stepByStep (Sequential procedures, multi-stage checkpoints)
    - guidedChat (Conversational inquiry, philosophy, nuanced reasoning)
    """
    lower_topic = topic.lower()
    lower_text = text.lower()
    combined = f"{lower_topic} {lower_text}"

    # 1. Visual Explanation / Algorithm (Search, Sorting, Arrays)
    if any(k in combined for k in [
        "binary search", "search", "sorting", "bubble sort", "quick sort",
        "merge sort", "linear search", "pointer array", "selection sort", "insertion sort"
    ]):
        return "visualExplanation"

    # 2. Simulation (Physics formulas, reactive circuits & models, Ohm's Law, Supply & Demand)
    if any(k in combined for k in [
        "ohm", "physics", "circuit", "voltage", "resistance", "current",
        "gravity", "pendulum", "simulation", "kinetic", "thermodynamics",
        "supply and demand", "equilibrium"
    ]):
        return "simulation"

    # 3. Concept Map (Hierarchies, OOP, DBMS, Systems, Taxonomies, Classification)
    if any(k in combined for k in [
        "oop", "object oriented", "inheritance", "polymorphism", "encapsulation",
        "abstraction", "dbms", "database management", "relational database", "hierarchy",
        "taxonomy", "classification", "networking concepts", "operating system"
    ]):
        return "conceptMap"

    # 4. Workflow / Process (Photosynthesis, Water Cycle, Digestion, TCP Handshake, Protocols, Pipelines)
    if any(k in combined for k in [
        "water cycle", "hydrologic", "photosynthesis", "plant", "calvin", "chloroplast",
        "digestion", "krebs", "mitosis", "tcp", "handshake", "transaction", "acid",
        "authentication", "oauth", "jwt", "compiler", "pipeline", "lifecycle",
        "workflow", "process", "instruction cycle"
    ]):
        return "workflow"

    # 5. Diagram (SQL JOINs, database schemas, relational models, Venn comparisons)
    if any(k in combined for k in [
        "sql", "join", "inner join", "left join", "right join", "outer join",
        "relational", "database table", "schema", "diagram", "venn", "anatomy", "heart"
    ]):
        return "diagram"

    # 6. Step-by-Step / Algorithm (Recursion, sequential stage breakdowns)
    if any(k in combined for k in [
        "recursion", "recursive", "call stack", "base case",
        "step by step", "step-by-step", "sequence", "procedure", "stage by stage"
    ]):
        return "stepByStep"

    # 7. Guided Chat (AI, reasoning, philosophy)
    if any(k in combined for k in [
        "artificial intelligence", "ai", "machine learning", "neural network",
        "ethics", "trade-off", "philosophy", "why does", "what is", "how do"
    ]):
        return "guidedChat"

    return "visualExplanation"


class AIService:
    def __init__(self, api_key: Optional[str] = None):
        raw_key = (
            api_key
            or os.getenv("GEMINI_API_KEY")
            or os.getenv("Gemini API Key")
            or os.getenv("GEMINI_APIKEY")
            or os.getenv("GOOGLE_API_KEY")
            or ""
        )
        self.api_key = raw_key.strip().strip("'").strip('"')
        self.model_name = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")
        self._client = None

        if self.api_key and self.api_key not in ("your_api_key_here", "YOUR_API_KEY_HERE"):
            try:
                from google import genai
                self._client = genai.Client(api_key=self.api_key)
                logger.info(f"Gemini client initialized with model: {self.model_name}")
            except Exception as e:
                logger.warning(f"Could not initialize official Google GenAI client: {e}")
        else:
            logger.info(
                "GEMINI_API_KEY not configured in backend/.env. Running with structured educational fallback engine."
            )

    async def analyze_material(self, title: str, text: str) -> MaterialAnalysisResponse:
        """
        Analyzes study material and extracts structured concepts, difficulty, and dynamic visualization data.
        """
        clean_title = title.strip()
        clean_text = text.strip()

        if not clean_title and not clean_text:
            clean_title = "Study Concept"
            clean_text = "Study Concept"
        elif not clean_text:
            clean_text = clean_title
        elif not clean_title:
            text_lines = [l.strip() for l in clean_text.splitlines() if l.strip()]
            clean_title = text_lines[0][:60] if text_lines else "Study Concept"

        # Attempt real Gemini generation if client is configured
        if self._client is not None:
            try:
                return await self._call_gemini_api(clean_title, clean_text)
            except Exception as e:
                logger.error(f"Gemini API call failed: {e}. Falling back to structured analyzer.", exc_info=True)
                return self._generate_fallback_analysis(clean_title, clean_text)

        # Local educational analysis engine
        return self._generate_fallback_analysis(clean_title, clean_text)

    def _normalize_vis_type(self, raw_type: str) -> str:
        t = (raw_type or "").lower().strip().replace("-", "_").replace(" ", "_")
        if t in ["simulation", "relationship", "formula", "circuit"]:
            return "simulation"
        if t in ["conceptmap", "concept_map", "hierarchy", "tree", "taxonomy"]:
            return "conceptMap"
        if t in ["workflow", "process", "sequence", "protocol", "cycle"]:
            return "workflow"
        if t in ["diagram", "interactive_diagram", "comparison", "table", "venn"]:
            return "diagram"
        if t in ["stepbystep", "step_by_step", "stages"]:
            return "stepByStep"
        if t in ["guidedchat", "guided_chat", "socratic"]:
            return "guidedChat"
        if t in ["algorithm", "visualexplanation", "visual_explanation", "interactive_visualization", "genericvisualexplanation"]:
            return "visualExplanation"
        return "visualExplanation"

    async def _call_gemini_api(self, title: str, text: str) -> MaterialAnalysisResponse:
        from google.genai import types

        system_instruction = (
            "You are the pedagogical intelligence behind LearnX STREAM — an elite AI visual educator.\n"
            "When a student asks ANY educational question, your mission is to behave like an exceptional teacher: "
            "provide a natural, crystal-clear explanation paired with a synchronized, dynamic visualization.\n\n"
            "==================================================\n"
            "TEACHING PRINCIPLES (NATURAL & TAILORED):\n"
            "==================================================\n"
            "1. Explain clearly and naturally (like top-tier ChatGPT / Gemini responses).\n"
            "2. Do NOT force every answer into the same fixed structure or rigid template.\n"
            "3. Use clear language, short paragraphs (no massive textbook walls of text), tailored section headings, "
            "intuitive real-world examples, and formulas/equations where relevant (e.g. V = I * R).\n"
            "4. Do NOT repeat information or use unnecessary AI jargon.\n"
            "5. Number of sections in 'answer.sections' should match what the concept needs (typically 2 to 4 focused sections).\n\n"
            "==================================================\n"
            "DYNAMIC VISUALIZATION SELECTION:\n"
            "==================================================\n"
            "Choose the most effective visualization type for the specific concept:\n"
            "- 'workflow' / 'process': for biological cycles, chemical reactions, physical transformations (e.g., Photosynthesis, Water Cycle, Cellular Respiration)\n"
            "- 'workflow' / 'sequence': for network protocols, transaction flows, execution stages (e.g., TCP Three-Way Handshake, OAuth, Packet Transmission)\n"
            "- 'visualExplanation' / 'algorithm': for algorithms, search, sorting, divide-and-conquer (e.g., Binary Search, MergeSort, Two Pointers)\n"
            "- 'conceptMap' / 'hierarchy': for OOP inheritance, taxonomy, class blueprints, systems (e.g., OOP Inheritance, DBMS Models)\n"
            "- 'simulation' / 'relationship': for physics formulas, reactive circuits, math balance (e.g., Ohm's Law, Gravity, Supply & Demand)\n"
            "- 'diagram' / 'comparison': for relational database queries, table sets, entity relations (e.g., SQL JOIN types, Set Intersections)\n"
            "- 'stepByStep': for recursive call stack unwinding, multi-stage procedures (e.g., Recursion call frames, Factorial stack)\n"
            "- 'guidedChat': for philosophical, abstract, or open-ended reasoning.\n\n"
            "IMPORTANT: The visualization and the explanation MUST come from the EXACT SAME conceptual understanding.\n"
            "Always include 2 to 5 stages in 'visualization.steps' (even for concept maps, hierarchies, and diagrams, provide sequential exploration stages: e.g. Stage 1: Superclass Base, Stage 2: Subclasses & Attributes, Stage 3: Method Overriding & Execution).\n\n"
            "==================================================\n"
            "JSON OUTPUT FORMAT:\n"
            "==================================================\n"
            "Return ONLY valid JSON matching this schema:\n"
            "{\n"
            '  "topic": "Canonical topic name (e.g. Recursion)",\n'
            '  "summary": "Short 2-3 sentence overview explaining what the student will learn",\n'
            '  "answer": {\n'
            '    "title": "Clear, engaging educational title (e.g. Recursion: Self-Referential Problem Solving)",\n'
            '    "summary": "Direct, clear answer to the student question",\n'
            '    "sections": [\n'
            '      {\n'
            '        "heading": "Tailored Section Heading",\n'
            '        "content": "Short, clear paragraph explaining this aspect.",\n'
            '        "type": "text"\n'
            '      }\n'
            '    ]\n'
            '  },\n'
            '  "visualization": {\n'
            '    "enabled": true,\n'
            '    "type": "process|sequence|algorithm|hierarchy|relationship|comparison|simulation|conceptMap|stepByStep|genericVisualExplanation",\n'
            '    "title": "Descriptive visual model title",\n'
            '    "description": "Short description of the visual model",\n'
            '    "elements": [\n'
            '      {\n'
            '        "id": "1",\n'
            '        "label": "Element Label",\n'
            '        "description": "What this represents",\n'
            '        "role": "core|input|intermediate|output",\n'
            '        "state": "active|inactive"\n'
            '      }\n'
            '    ],\n'
            '    "relationships": [\n'
            '      {\n'
            '        "from": "1",\n'
            '        "to": "2",\n'
            '        "label": "Flow or interaction description",\n'
            '        "type": "flow|subclass|call|connects"\n'
            '      }\n'
            '    ],\n'
            '    "steps": [\n'
            '      {\n'
            '        "stepNumber": 1,\n'
            '        "title": "Stage Title",\n'
            '        "description": "Explanation of this stage",\n'
            '        "whatIsHappening": "Clear, concise explanation of the action taking place",\n'
            '        "visualElements": ["Element 1", "Element 2"],\n'
            '        "action": "Action taken in this stage",\n'
            '        "result": "Resulting state or output"\n'
            '      }\n'
            '    ]\n'
            '  },\n'
            '  "visualExplanation": "2-3 clear sentences explaining what the student sees in the visualization and how it proves the concept.",\n'
            '  "keyTakeaway": "1-2 punchy sentences summarizing the core mental model or key idea.",\n'
            '  "realWorldConnection": "Practical real-world application or where you see this.",\n'
            '  "quickCheck": {\n'
            '    "enabled": true,\n'
            '    "question": "Insightful conceptual multiple-choice question",\n'
            '    "options": ["Option A", "Option B", "Option C"],\n'
            '    "correctAnswer": "Option A",\n'
            '    "explanation": "Clear reason why this answer is correct."\n'
            '  },\n'
            '  "concepts": [\n'
            '    {"name": "Sub-concept", "type": "category", "importance": "high"}\n'
            '  ],\n'
            '  "difficulty": "easy|medium|hard",\n'
            '  "prerequisites": ["Prerequisite 1"]\n'
            "}"
        )

        prompt = (
            f"Question / Topic: {title}\n\n"
            f"Context / Study Material: {text}\n\n"
            "Provide an expert teacher response. Understand the concept, explain it clearly with natural tailored sections, "
            "and create a synchronized interactive visualization matching the schema."
        )

        config = types.GenerateContentConfig(
            system_instruction=system_instruction,
            response_mime_type="application/json",
            temperature=0.2,
        )

        response = self._client.models.generate_content(
            model=self.model_name,
            contents=prompt,
            config=config,
        )

        raw_response_text = response.text or ""
        logger.info(f"Gemini responded with {len(raw_response_text)} chars.")
        cleaned_json = self._clean_json_string(raw_response_text)

        return self._parse_and_normalize_gemini_response(cleaned_json, title, text)

    def _parse_and_normalize_gemini_response(self, raw_json: str, title: str, text: str) -> MaterialAnalysisResponse:
        data = json.loads(raw_json)
        if not isinstance(data, dict):
            raise ValueError(f"Expected JSON object from AI, got {type(data)}")

        topic = data.get("topic") or title

        # 1. Answer Payload & Sections
        raw_answer = data.get("answer") or {}
        ans_title = raw_answer.get("title") or f"Understanding {topic}"
        ans_summary = (
            raw_answer.get("summary")
            or data.get("summary")
            or data.get("conceptOverview")
            or f"A visual and conceptual guide to understanding {topic}."
        )

        raw_sections = raw_answer.get("sections") or []
        sections: List[AnswerSection] = []
        if isinstance(raw_sections, list):
            for s in raw_sections:
                if isinstance(s, dict):
                    h = (s.get("heading") or "Key Aspect").strip()
                    c = (s.get("content") or "").strip()
                    t = (s.get("type") or "text").strip()
                    if h or c:
                        sections.append(AnswerSection(heading=h, content=c, type=t))

        if not sections and ans_summary:
            sections.append(AnswerSection(heading="Key Concepts", content=ans_summary, type="text"))

        answer_payload = AnswerPayload(
            title=ans_title,
            summary=ans_summary,
            sections=sections,
        )

        # 2. Dynamic Visualization Selection & Normalization
        raw_vis = data.get("visualization") or data.get("visualization_data") or {}
        vis_type_str = (
            raw_vis.get("type")
            or data.get("visualizationType")
            or data.get("visualization_type")
            or data.get("recommendedVisualization")
            or choose_visualization_type(topic, text)
        )
        canonical_vis = self._normalize_vis_type(vis_type_str)

        # Parse visual steps
        raw_steps = raw_vis.get("steps") or data.get("steps") or []
        steps_list: List[StepItem] = []
        if isinstance(raw_steps, list):
            for idx, st in enumerate(raw_steps, 1):
                if isinstance(st, dict):
                    steps_list.append(StepItem(
                        stepNumber=int(st.get("stepNumber") or st.get("step_number") or idx),
                        title=(st.get("title") or f"Stage {idx}").strip(),
                        description=(st.get("description") or st.get("whatIsHappening") or "").strip(),
                        whatIsHappening=(st.get("whatIsHappening") or st.get("description") or "").strip(),
                        visualElements=st.get("visualElements") or st.get("elements") or [],
                        highlightedElements=st.get("highlightedElements") or [],
                        activeElements=st.get("activeElements") or [],
                        action=st.get("action") or "",
                        result=st.get("result") or "",
                    ))

        # If steps list has fewer than 2 stages (e.g. for static concept maps or graphs), synthesize stages
        if len(steps_list) < 2:
            raw_elements = raw_vis.get("elements") or []
            if raw_elements and isinstance(raw_elements, list):
                for idx, elem in enumerate(raw_elements[:4], 1):
                    if isinstance(elem, dict):
                        lbl = elem.get("label") or elem.get("name") or f"Component {idx}"
                        desc = elem.get("description") or f"Explore the role of {lbl} in {topic}."
                        steps_list.append(StepItem(
                            stepNumber=idx,
                            title=f"Stage {idx}: {lbl}",
                            description=desc,
                            whatIsHappening=desc,
                            visualElements=[lbl],
                            action=f"Focusing on {lbl}",
                            result=f"{lbl} structured in the visual model"
                        ))
            elif sections:
                for idx, s in enumerate(sections[:3], 1):
                    steps_list.append(StepItem(
                        stepNumber=idx,
                        title=s.heading,
                        description=s.content[:140],
                        whatIsHappening=s.content[:140],
                        visualElements=[topic, s.heading],
                        action=f"Analyzing {s.heading}",
                        result=f"Established understanding of {s.heading}"
                    ))
            else:
                steps_list = [
                    StepItem(stepNumber=1, title=f"Foundation of {topic}", description=f"Initial setup of {topic}", whatIsHappening=f"Observing core properties of {topic}"),
                    StepItem(stepNumber=2, title=f"Execution of {topic}", description=f"Applying {topic} in practice", whatIsHappening=f"Tracking state transformation in {topic}")
                ]

        # Construct clean visualization payload dictionary
        vis_dict = {
            "enabled": True,
            "type": canonical_vis,
            "title": raw_vis.get("title") or f"{topic} Visual Model",
            "description": raw_vis.get("description") or f"Interactive visualization of {topic}.",
            "elements": raw_vis.get("elements") or [],
            "relationships": raw_vis.get("relationships") or [],
            "steps": [s.model_dump() for s in steps_list],
        }

        # 3. Pedagogical Takeaways & Real-World Connection
        visual_explanation = (
            data.get("visualExplanation")
            or raw_vis.get("description")
            or f"The visual representation demonstrates the core structure and interactions of {topic}."
        )

        key_takeaway = (
            data.get("keyTakeaway")
            or data.get("keyIdea")
            or ans_summary
        )

        real_world = (
            data.get("realWorldConnection")
            or ""
        )

        # 4. Quick Check Question
        raw_qc = data.get("quickCheck") or data.get("quick_check") or {}
        if isinstance(raw_qc, dict) and raw_qc.get("question") and raw_qc.get("options"):
            opts = [str(o) for o in raw_qc.get("options", []) if o]
            ans = str(raw_qc.get("correctAnswer") or (opts[0] if opts else ""))
            quick_check = QuickCheck(
                enabled=raw_qc.get("enabled", True),
                question=str(raw_qc.get("question")),
                options=opts,
                correctAnswer=ans,
                explanation=str(raw_qc.get("explanation") or f"'{ans}' correctly captures the core mechanism of {topic}."),
            )
        else:
            quick_check = QuickCheck(
                enabled=True,
                question=f"What is the most critical principle governing {topic}?",
                options=[
                    f"Understanding its core rule and step-by-step mechanism",
                    f"Executing random operations without constraints",
                    f"Assuming all inputs behave identically regardless of structure"
                ],
                correctAnswer=f"Understanding its core rule and step-by-step mechanism",
                explanation=f"Mastering {topic} requires identifying its key rules, inputs, and state changes."
            )

        # 5. Concept Items & Taxonomy
        raw_concepts = data.get("concepts") or []
        concepts_list: List[ConceptItem] = []
        if isinstance(raw_concepts, list):
            for c in raw_concepts:
                if isinstance(c, dict) and c.get("name"):
                    imp = c.get("importance", "medium")
                    if imp not in ["high", "medium", "low"]:
                        imp = "medium"
                    concepts_list.append(ConceptItem(
                        name=str(c.get("name")),
                        type=str(c.get("type") or "concept"),
                        importance=imp,
                    ))
        if not concepts_list:
            concepts_list = [
                ConceptItem(name=topic, type="core_concept", importance="high")
            ]

        difficulty = data.get("difficulty")
        if difficulty not in ["easy", "medium", "hard"]:
            difficulty = "medium"

        raw_prereqs = data.get("prerequisites") or []
        prereqs = [str(p) for p in raw_prereqs if p] if isinstance(raw_prereqs, list) else []

        reason_str = raw_vis.get("description") or f"This visual model is tailored to clarify {topic}."

        return MaterialAnalysisResponse(
            topic=topic,
            summary=ans_summary,
            conceptOverview=ans_summary,
            answer=answer_payload,
            visualExplanation=visual_explanation,
            keyTakeaway=key_takeaway,
            keyIdea=key_takeaway,
            realWorldConnection=real_world,
            quickCheck=quick_check,
            steps=steps_list,
            concepts=concepts_list,
            difficulty=difficulty,
            prerequisites=prereqs,
            recommended_representation=RecommendedRepresentation(
                type=canonical_vis,
                reason=reason_str,
            ),
            visualization_type=canonical_vis,
            visualization_data=vis_dict,
            why_this_works=visual_explanation,
            visualizationType=canonical_vis,
            title=topic,
            subtitle="Let's understand it visually.",
            recommendedVisualization=canonical_vis,
            reason=reason_str,
            visualization=vis_dict,
        )

    def _clean_json_string(self, text: str) -> str:
        text = text.strip()
        if text.startswith("```"):
            text = re.sub(r"^```(?:json)?\s*", "", text, flags=re.IGNORECASE)
            text = re.sub(r"\s*```$", "", text)
        return text.strip()

    def _generate_fallback_analysis(self, title: str, text: str) -> MaterialAnalysisResponse:
        """
        Deterministic, high-quality structured concept analysis with full dynamic visualization data,
        flexible educational answer sections, and synchronized visual models for any topic.
        """
        vis_type = choose_visualization_type(title, text)
        lower_title = title.lower()
        lower_text = text.lower()
        combined = f"{lower_title} {lower_text}"

        clean_topic = (
            title.replace("Explain", "")
            .replace("explain", "")
            .replace("What is", "")
            .replace("what is", "")
            .replace("How does", "")
            .replace("how does", "")
            .replace("work?", "")
            .replace("work", "")
            .replace("?", "")
            .strip()
        )
        if not clean_topic:
            clean_topic = title

        # Extract customized educational package for the topic
        (
            answer_payload,
            vis_data,
            visual_explanation,
            key_takeaway,
            real_world,
            quick_check,
            steps_list,
            concepts,
            prereqs,
            rec_vis,
            rep_reason,
            why_works,
            difficulty,
        ) = self._build_canonical_topic_data(clean_topic, title, combined, vis_type)

        return MaterialAnalysisResponse(
            topic=title,
            summary=answer_payload.summary,
            conceptOverview=answer_payload.summary,
            answer=answer_payload,
            visualExplanation=visual_explanation,
            keyTakeaway=key_takeaway,
            keyIdea=key_takeaway,
            realWorldConnection=real_world,
            quickCheck=quick_check,
            steps=steps_list,
            concepts=concepts,
            difficulty=difficulty,
            prerequisites=prereqs,
            recommended_representation=RecommendedRepresentation(
                type=rec_vis,
                reason=rep_reason,
            ),
            visualization_type=rec_vis,
            visualization_data=vis_data,
            why_this_works=why_works,
            visualizationType=rec_vis,
            title=title,
            subtitle="Let's understand it visually.",
            recommendedVisualization=rec_vis,
            reason=rep_reason,
            visualization=vis_data,
        )

    def _build_canonical_topic_data(
        self, clean_topic: str, title: str, combined: str, vis_type: str
    ):
        """
        Builds tailored pedagogical content, sections, visualization payload, and quick check
        for canonical topics and dynamic fallback for arbitrary questions.
        """
        # =========================================================================
        # 1. PHOTOSYNTHESIS
        # =========================================================================
        if "photosynthesis" in combined or "calvin" in combined or "chloroplast" in combined:
            answer_payload = AnswerPayload(
                title=f"{clean_topic}: Solar Energy to Chemical Food",
                summary=(
                    "Photosynthesis is the biochemical process plants use to produce glucose sugar using sunlight. "
                    "Leaves take in water (H₂O) from the soil and carbon dioxide (CO₂) from the air, utilizing solar energy "
                    "captured by chlorophyll to synthesize energy-rich glucose while releasing oxygen (O₂) into the atmosphere."
                ),
                sections=[
                    AnswerSection(
                        heading="The Solar Chemical Engine",
                        content="Inside leaf cells, green chloroplast organelles house chlorophyll pigments that absorb specific wavelengths of solar light to energize electrons.",
                        type="text",
                    ),
                    AnswerSection(
                        heading="How Light Converts to Chemical Energy",
                        content="The process occurs in two primary stages: the Light-Dependent Reactions (splitting water to generate ATP and release oxygen) and the Calvin Cycle (fixing CO₂ into glucose sugars).",
                        type="mechanism",
                    ),
                    AnswerSection(
                        heading="Why It Matters for Life on Earth",
                        content="Photosynthesis forms the energetic foundation of nearly all terrestrial food chains and supplies the atmospheric oxygen needed for cellular respiration.",
                        type="text",
                    ),
                ],
            )
            steps_list = [
                StepItem(
                    stepNumber=1,
                    title="Light Absorption",
                    description="Chlorophyll inside plant chloroplasts captures solar photons.",
                    whatIsHappening="Chlorophyll in the leaf absorbs solar energy to initiate photosynthetic reactions.",
                    visualElements=["Sunlight (Photons)", "Chlorophyll Pigment"],
                    action="Absorb solar photons",
                    result="Pigment molecules excited",
                ),
                StepItem(
                    stepNumber=2,
                    title="Water Splitting (Photolysis)",
                    description="Water (H₂O) molecules split to release oxygen and energized electrons.",
                    whatIsHappening="Enzymes split water molecules, releasing oxygen gas into the air and charging ATP energy carriers.",
                    visualElements=["Water (H₂O)", "Oxygen (O₂)"],
                    action="Split H₂O into 2H⁺ + 2e⁻ + ½O₂",
                    result="Oxygen released and energy charged",
                ),
                StepItem(
                    stepNumber=3,
                    title="Calvin Cycle (Sugar Synthesis)",
                    description="CO₂ combines with chemical energy carriers to create Glucose.",
                    whatIsHappening="Carbon dioxide is fixed using chemical energy carriers into durable glucose sugar for plant nutrition.",
                    visualElements=["Carbon Dioxide (CO₂)", "Glucose (C₆H₁₂O₆)"],
                    action="Fix CO₂ into C₆H₁₂O₆",
                    result="Glucose produced for plant growth",
                ),
            ]
            vis_data = {
                "enabled": True,
                "type": "workflow",
                "visualization_type": "workflow",
                "title": "Photosynthesis Energy Pathway",
                "subtitle": "Trace solar energy converting water and carbon dioxide into glucose.",
                "actors": ["Leaf Chloroplast", "Environment / Atmosphere"],
                "stages": [
                    {
                        "stage_number": 1,
                        "title": "1. Light Absorption",
                        "subtitle": "Chlorophyll captures sunlight",
                        "description": "Solar photons strike chlorophyll pigments in the thylakoid membrane.",
                        "from_actor": "Atmosphere (Sunlight)",
                        "to_actor": "Leaf Chloroplast",
                        "packet_label": "Solar Photons",
                        "state_label": "LIGHT CHARGED",
                    },
                    {
                        "stage_number": 2,
                        "title": "2. Water Splitting (Photolysis)",
                        "subtitle": "Water splits into O₂ and H⁺",
                        "description": "Water molecules split, charging ATP carriers and releasing oxygen gas.",
                        "from_actor": "Soil Roots (H₂O)",
                        "to_actor": "Atmosphere (O₂ Released)",
                        "packet_label": "Oxygen Gas (O₂)",
                        "state_label": "O₂ RELEASED",
                    },
                    {
                        "stage_number": 3,
                        "title": "3. Calvin Cycle (Glucose Synthesis)",
                        "subtitle": "Carbon dioxide fixed into Glucose",
                        "description": "Atmospheric CO₂ is fixed into energy-rich glucose sugar for plant growth.",
                        "from_actor": "Atmosphere (CO₂)",
                        "to_actor": "Plant Biomass (Glucose)",
                        "packet_label": "Glucose (C₆H₁₂O₆)",
                        "state_label": "GLUCOSE SYNTHESIZED",
                    },
                ],
                "steps": [s.model_dump() for s in steps_list],
                "why_this_works": "Process sequences trace how light energy converts water and carbon dioxide into glucose and oxygen.",
            }
            visual_explanation = "The workflow diagram demonstrates how solar photons split water molecules and drive the Calvin cycle to generate glucose."
            key_takeaway = "Photosynthesis transforms sunlight, water, and CO₂ into chemical energy stored in glucose while releasing vital oxygen."
            real_world = "Powers Earth's food chains and produces the atmospheric oxygen required by almost all living organisms."
            quick_check = QuickCheck(
                enabled=True,
                question="Why do plants require sunlight during photosynthesis?",
                options=[
                    "To provide photon energy to split water and charge ATP energy carriers",
                    "To make the leaf cells heavier",
                    "To turn carbon dioxide directly into nitrogen",
                ],
                correctAnswer="To provide photon energy to split water and charge ATP energy carriers",
                explanation="Solar photons provide the energy needed to excite chlorophyll electrons and power glucose synthesis.",
            )
            concepts = [
                ConceptItem(name="Light Absorption", type="biological_reaction", importance="high"),
                ConceptItem(name="Photolysis (Water Splitting)", type="chemical_process", importance="high"),
                ConceptItem(name="Calvin Cycle", type="biochemical_pathway", importance="high"),
                ConceptItem(name="Chloroplast & Chlorophyll", type="cellular_structure", importance="medium"),
            ]
            prereqs = ["Basic Plant Biology", "Chemical Molecules (H₂O, CO₂, O₂)"]
            rec_vis = "workflow"
            rep_reason = "Photosynthesis consists of sequential chemical transformations best understood as a workflow."
            why_works = "Process sequences clearly trace how light energy converts water and carbon dioxide into glucose and oxygen."
            difficulty = "easy"

        # =========================================================================
        # 2. BINARY SEARCH
        # =========================================================================
        elif "binary search" in combined or "search" in combined:
            answer_payload = AnswerPayload(
                title=f"{clean_topic}: Logarithmic Divide-and-Conquer Search",
                summary=(
                    "Binary Search is an efficient algorithm that finds the position of a target value within a sorted array. "
                    "Instead of scanning items one by one, it repeatedly checks the middle element and discards the half of the array "
                    "that cannot contain the target, achieving O(log N) logarithmic speed."
                ),
                sections=[
                    AnswerSection(
                        heading="The Divide-and-Conquer Principle",
                        content="By probing the middle element and comparing it with the target, Binary Search eliminates 50% of remaining candidates in a single step.",
                        type="text",
                    ),
                    AnswerSection(
                        heading="How the Search Works",
                        content="Two pointers ('low' and 'high') define the search boundary. The middle index is calculated as mid = (low + high) // 2. If target > array[mid], the search shifts to the right half (low = mid + 1); otherwise it shifts to the left.",
                        type="mechanism",
                    ),
                    AnswerSection(
                        heading="Why the Array Must Be Sorted",
                        content="If the array were unsorted, knowing that target > middle would provide no information about where the target is located.",
                        type="comparison",
                    ),
                ],
            )
            steps_list = [
                StepItem(
                    stepNumber=1,
                    title="Find the Middle",
                    description="Calculate middle index between low and high pointers.",
                    whatIsHappening="The algorithm checks middle element 40 to split the search range into two equal halves.",
                    visualElements=[10, 20, 30, 40, 50, 60, 70],
                    action="Compare target 60 > middle 40",
                    result="Middle element evaluated; discard left half [10, 20, 30, 40]",
                ),
                StepItem(
                    stepNumber=2,
                    title="Check the New Middle",
                    description="Narrow window to [50, 60, 70] and check new middle 60.",
                    whatIsHappening="Target 60 matches the new middle element 60 at index 5. Target found!",
                    visualElements=[50, 60, 70],
                    action="Compare target 60 == middle 60",
                    result="Target located at index 5",
                ),
                StepItem(
                    stepNumber=3,
                    title="Logarithmic Halving O(log N)",
                    description="Understand how halving achieves O(log N) efficiency.",
                    whatIsHappening="Halving the search space allows searching 1,000,000 sorted elements in only ~20 comparisons.",
                    visualElements=["7 elements", "3 elements", "1 element", "FOUND"],
                    action="O(log N) Logarithmic Reduction",
                    result="Search completed with maximum efficiency",
                ),
            ]
            vis_data = self._build_interactive_visualization_data(title, combined)
            visual_explanation = "The interactive array illustrates the search window narrowing by half on each comparison until the target is located."
            key_takeaway = "Binary Search achieves O(log N) speed by eliminating half of the remaining elements at every step."
            real_world = "Used in database indexes, dictionary lookups, and search engines to query millions of records in milliseconds."
            quick_check = QuickCheck(
                enabled=True,
                question="Why must an array be sorted before applying Binary Search?",
                options=[
                    "Comparing the middle value only eliminates a half if items are in sorted order",
                    "Unsorted arrays cannot be stored in computer memory",
                    "Binary Search only works on arrays of even length",
                ],
                correctAnswer="Comparing the middle value only eliminates a half if items are in sorted order",
                explanation="Without sorted order, knowing target > middle provides zero guarantee about which half contains the target.",
            )
            concepts = [
                ConceptItem(name="Divide and Conquer", type="algorithmic_paradigm", importance="high"),
                ConceptItem(name="Logarithmic Time O(log N)", type="complexity_metric", importance="high"),
                ConceptItem(name="Sorted Array Invariant", type="precondition", importance="high"),
                ConceptItem(name="Boundary Pointers (Low, Mid, High)", type="data_state", importance="medium"),
            ]
            prereqs = ["Arrays & Indexing", "Comparison Operators", "Basic Asymptotic Notation"]
            rec_vis = "visualExplanation"
            rep_reason = "An animated array simulation makes the halving process intuitive to see."
            why_works = "Because the array is sorted and the target is greater than the middle value, we safely ignore the entire left half."
            difficulty = "medium"

        # =========================================================================
        # 3. OHM'S LAW
        # =========================================================================
        elif "ohm" in combined or "circuit" in combined or "voltage" in combined or "resistance" in combined:
            answer_payload = AnswerPayload(
                title=f"{clean_topic}: Voltage, Current & Resistance Relationship",
                summary=(
                    "Ohm's Law states the fundamental relationship between Voltage (V), Current (I), and Resistance (R) "
                    "in electrical circuits: Voltage equals Current multiplied by Resistance (V = I × R). "
                    "Current increases proportionally with Voltage and decreases as Resistance increases."
                ),
                sections=[
                    AnswerSection(
                        heading="The Electrical Triad",
                        content="Voltage (V in Volts) is the electromotive pushing force; Current (I in Amperes) is the charge flow rate; Resistance (R in Ohms) opposes electron movement.",
                        type="text",
                    ),
                    AnswerSection(
                        heading="The Water Pipe Analogy",
                        content="Think of voltage as water pressure from a pump, current as the volume of water flowing through the pipe, and resistance as a constriction that restricts flow.",
                        type="example",
                    ),
                    AnswerSection(
                        heading="The Core Formula (I = V / R)",
                        content="Rearranging the formula shows that Current equals Voltage divided by Resistance. Doubling voltage doubles current; doubling resistance cuts current in half.",
                        type="formula",
                    ),
                ],
            )
            steps_list = [
                StepItem(
                    stepNumber=1,
                    title="Apply Voltage (Push Force)",
                    description="Battery creates an electrical potential difference.",
                    whatIsHappening="Voltage provides the electromotive push that drives free electrons through the circuit.",
                    visualElements=["Battery (Voltage Source)", "Conductor"],
                    action="Apply potential difference (V)",
                    result="Electromotive force active",
                ),
                StepItem(
                    stepNumber=2,
                    title="Encounter Resistance (Obstacle)",
                    description="Resistor or filament opposes electron movement.",
                    whatIsHappening="Resistor atoms collide with electrons, converting electrical energy into heat or light.",
                    visualElements=["Resistor (R)", "Electron Flow"],
                    action="Impose electrical resistance (R)",
                    result="Current flow restricted",
                ),
                StepItem(
                    stepNumber=3,
                    title="Equilibrium Current (I = V / R)",
                    description="Current stabilizes according to Ohm's Law.",
                    whatIsHappening="Steady electric current flows through the circuit, illuminating the bulb in proportion to I = V / R.",
                    visualElements=["Ammeter", "Light Bulb"],
                    action="Measure Current (I = V / R)",
                    result="Steady current and illumination established",
                ),
            ]
            vis_data = self._build_simulation_data(title, combined)
            visual_explanation = "The interactive circuit simulation shows electrons flowing through the resistor: adjusting voltage and resistance dynamically changes current and bulb brightness."
            key_takeaway = "Voltage pushes current forward while Resistance opposes it: Current equals Voltage divided by Resistance (I = V / R)."
            real_world = "Used by electrical engineers to size resistors and prevent smartphone chargers, electronics, and household appliances from overheating."
            quick_check = QuickCheck(
                enabled=True,
                question="If the voltage across a resistor is doubled while its resistance remains constant, what happens to the electric current?",
                options=[
                    "The current doubles",
                    "The current is halved",
                    "The current drops to zero",
                ],
                correctAnswer="The current doubles",
                explanation="According to Ohm's Law (I = V / R), electric current is directly proportional to voltage.",
            )
            concepts = [
                ConceptItem(name="Voltage (V)", type="potential_difference", importance="high"),
                ConceptItem(name="Current (I)", type="charge_flow_rate", importance="high"),
                ConceptItem(name="Resistance (R)", type="material_impedance", importance="high"),
                ConceptItem(name="Proportional Relationship", type="physical_law", importance="medium"),
            ]
            prereqs = ["Basic Electricity Concepts", "Algebraic Rearrangement"]
            rec_vis = "simulation"
            rep_reason = "Adjusting voltage and resistance in a live simulation makes the proportional relationship clear."
            why_works = "Current flows when Voltage pushes electrons through Resistance. Increasing voltage increases current, while higher resistance restricts the flow."
            difficulty = "easy"

        # =========================================================================
        # 4. OOP / INHERITANCE IN OOP
        # =========================================================================
        elif "oop" in combined or "inheritance" in combined or "object oriented" in combined:
            answer_payload = AnswerPayload(
                title=f"{clean_topic}: Hierarchical Code Reusability",
                summary=(
                    "Inheritance is a core principle of Object-Oriented Programming (OOP) that allows a child class (subclass) "
                    "to inherit fields and methods from a parent class (superclass). It establishes an 'is-a' relationship, "
                    "promoting code reuse, modularity, and clean polymorphic architectures."
                ),
                sections=[
                    AnswerSection(
                        heading="The 'is-a' Relationship",
                        content="A Dog 'is-a' Animal; a SportsCar 'is-a' Vehicle. By inheriting from a common base class, subclasses automatically receive all standard attributes and behaviors without duplicating code.",
                        type="text",
                    ),
                    AnswerSection(
                        heading="Code Reuse & Extensibility",
                        content="Parent classes encapsulate common logic in one place. Subclasses can add specialized properties or override inherited methods to customize behavior.",
                        type="mechanism",
                    ),
                    AnswerSection(
                        heading="Method Overriding & Polymorphism",
                        content="A child class can override a parent method (e.g. ElectricCar overriding startEngine() with silent ignition) while still presenting a uniform interface.",
                        type="example",
                    ),
                ],
            )
            steps_list = [
                StepItem(
                    stepNumber=1,
                    title="Define Superclass Blueprint",
                    description="Create base class with shared attributes and methods.",
                    whatIsHappening="The superclass defines baseline traits (e.g. Vehicle with speed and fuel).",
                    visualElements=["Superclass: Vehicle"],
                    action="Declare parent blueprint",
                    result="Common baseline established",
                ),
                StepItem(
                    stepNumber=2,
                    title="Derive Subclass (Inheritance)",
                    description="Child class extends parent with specialized behavior.",
                    whatIsHappening="Child class inherits all parent methods and adds unique features (e.g. ElectricCar extends Vehicle).",
                    visualElements=["Subclass: ElectricCar", "Inherited Traits"],
                    action="Extend superclass",
                    result="Code reused without duplication",
                ),
                StepItem(
                    stepNumber=3,
                    title="Polymorphic Invocation",
                    description="Invoke methods through unified parent interface.",
                    whatIsHappening="Calling vehicle.drive() executes specialized behavior depending on the concrete instance.",
                    visualElements=["Object Instance in Memory"],
                    action="Execute overridden method",
                    result="Modular, polymorphic execution verified",
                ),
            ]
            vis_data = self._build_concept_map_data(title, combined)
            visual_explanation = "The concept map hierarchy illustrates how child classes branch from parent blueprints, inheriting baseline attributes while adding specialized behaviors."
            key_takeaway = "Inheritance allows subclasses to inherit and extend parent class capabilities, avoiding boilerplate duplication and establishing clear hierarchies."
            real_world = "Used across modern software engineering, from UI widget trees in Flutter to backend database models."
            quick_check = QuickCheck(
                enabled=True,
                question="What is the primary architectural advantage of inheritance in OOP?",
                options=[
                    "Reusing parent class logic across specialized subclasses without repeating code",
                    "Making programs run at infinite speed",
                    "Preventing classes from containing any variables",
                ],
                correctAnswer="Reusing parent class logic across specialized subclasses without repeating code",
                explanation="Inheritance allows subclasses to inherit shared attributes and methods, following the DRY (Don't Repeat Yourself) principle.",
            )
            concepts = [
                ConceptItem(name="Superclass & Subclass", type="oop_primitive", importance="high"),
                ConceptItem(name="Code Reusability (DRY)", type="design_principle", importance="high"),
                ConceptItem(name="Method Overriding", type="polymorphism_mechanism", importance="high"),
                ConceptItem(name="Encapsulation", type="oop_pillar", importance="medium"),
            ]
            prereqs = ["Classes & Objects Basics", "Functions & Methods"]
            rec_vis = "conceptMap"
            rep_reason = "OOP relationships and inheritance trees are easiest to understand through an interactive concept map."
            why_works = "Concept maps show how specialized components inherit attributes and methods from base blueprints without repeating code."
            difficulty = "medium"

        # =========================================================================
        # 5. TCP THREE-WAY HANDSHAKE
        # =========================================================================
        elif "tcp" in combined or "handshake" in combined:
            answer_payload = AnswerPayload(
                title=f"{clean_topic}: Reliable Connection Establishment",
                summary=(
                    "The TCP Three-Way Handshake (SYN, SYN-ACK, ACK) is the protocol sequence used across the Internet "
                    "to establish a reliable, verified two-way communication channel between a client and a server "
                    "before transmitting actual data."
                ),
                sections=[
                    AnswerSection(
                        heading="Why TCP Requires a Handshake",
                        content="Unlike connectionless UDP, TCP guarantees that packets arrive in order and without loss. To do this, both client and server must verify they can both send and receive data.",
                        type="text",
                    ),
                    AnswerSection(
                        heading="The 3-Step Synchronization Sequence",
                        content="1. SYN: Client sends Initial Sequence Number (ISN).\n2. SYN-ACK: Server acknowledges client's ISN and sends its own SYN.\n3. ACK: Client acknowledges server's ISN. Both sides are synchronized.",
                        type="mechanism",
                    ),
                    AnswerSection(
                        heading="Full-Duplex Readiness",
                        content="Once the ACK packet is delivered, both channels are verified and application data (HTTP, TLS, etc.) can safely flow in both directions.",
                        type="text",
                    ),
                ],
            )
            steps_list = [
                StepItem(
                    stepNumber=1,
                    title="SYN (Synchronize)",
                    description="Client initiates connection with Initial Sequence Number.",
                    whatIsHappening="Client sends a SYN packet to the server requesting to open a reliable connection.",
                    visualElements=["Client", "SYN Packet [Seq=100]", "Server"],
                    action="Client sends SYN",
                    result="Server receives connection request",
                ),
                StepItem(
                    stepNumber=2,
                    title="SYN-ACK (Sync & Acknowledge)",
                    description="Server confirms client sequence and sends its own SYN.",
                    whatIsHappening="Server acknowledges the client's packet and replies with its own synchronization sequence.",
                    visualElements=["Server", "SYN-ACK Packet [Seq=300, Ack=101]", "Client"],
                    action="Server replies SYN-ACK",
                    result="Client verifies server can receive and send",
                ),
                StepItem(
                    stepNumber=3,
                    title="ACK (Final Confirmation)",
                    description="Client confirms server sequence; connection is established.",
                    whatIsHappening="Client sends final acknowledgment, establishing a full-duplex verified connection ready for data.",
                    visualElements=["Client", "ACK Packet [Ack=301]", "Server"],
                    action="Client sends ACK",
                    result="Connection established & ready for data",
                ),
            ]
            vis_data = self._build_step_by_step_data(title, combined)
            visual_explanation = "The interactive sequence tracks packet travel between Client and Server, highlighting how sequence numbers synchronize in 3 steps."
            key_takeaway = "The TCP three-way handshake verifies two-way communication and synchronizes sequence numbers before data transmission begins."
            real_world = "Used every time you load a website, stream a video, or send an email across the Internet."
            quick_check = QuickCheck(
                enabled=True,
                question="What is the primary purpose of the TCP Three-Way Handshake?",
                options=[
                    "To synchronize sequence numbers and verify two-way communication before sending data",
                    "To compress the web page size",
                    "To permanently encrypt all network traffic",
                ],
                correctAnswer="To synchronize sequence numbers and verify two-way communication before sending data",
                explanation="Both client and server must verify they can send and receive packets before initiating full-duplex transmission.",
            )
            concepts = [
                ConceptItem(name="SYN Packet (Synchronize)", type="protocol_message", importance="high"),
                ConceptItem(name="SYN-ACK Response", type="protocol_message", importance="high"),
                ConceptItem(name="ACK Confirmation", type="protocol_message", importance="high"),
                ConceptItem(name="Sequence Numbers (ISN)", type="state_tracking", importance="medium"),
            ]
            prereqs = ["Network Basics (OSI/TCP-IP)", "IP Packets & Ports"]
            rec_vis = "workflow"
            rep_reason = "The concept is naturally represented as a sequence of communication steps."
            why_works = "Step-by-step breakdowns turn complex multi-stage handshakes into clear sequential checkpoints."
            difficulty = "medium"

        # =========================================================================
        # 6. SQL JOIN
        # =========================================================================
        elif "join" in combined or "sql" in combined:
            answer_payload = AnswerPayload(
                title=f"{clean_topic}: Relational Data Merging with Set Theory",
                summary=(
                    "A SQL JOIN is a database query clause used to combine rows from two or more tables based on a related column "
                    "between them (such as primary and foreign keys). It enables querying relational data stored across normalized tables."
                ),
                sections=[
                    AnswerSection(
                        heading="Relational Set Matching",
                        content="Tables represent independent entities (e.g. Users and Orders). JOIN operations match rows where a common condition evaluates to true (e.g. Users.id = Orders.user_id).",
                        type="text",
                    ),
                    AnswerSection(
                        heading="The Primary JOIN Types",
                        content="• INNER JOIN: Returns only rows with matching keys in BOTH tables.\n• LEFT JOIN: Returns ALL rows from the left table, plus matching rows from the right.\n• RIGHT JOIN: Returns ALL rows from the right table.\n• FULL OUTER JOIN: Returns all rows when there is a match in either table.",
                        type="comparison",
                    ),
                ],
            )
            steps_list = [
                StepItem(
                    stepNumber=1,
                    title="Inspect Source Tables",
                    description="Identify left and right relational tables.",
                    whatIsHappening="The query engine inspects both tables and identifies the join key columns.",
                    visualElements=["Table A (Users)", "Table B (Orders)"],
                    action="Load Table A and Table B",
                    result="Tables ready for matching",
                ),
                StepItem(
                    stepNumber=2,
                    title="Evaluate Join Predicate",
                    description="Match rows where TableA.id == TableB.user_id.",
                    whatIsHappening="The database compares key values across both tables according to the ON condition.",
                    visualElements=["Matching Keys (Users.id = Orders.user_id)"],
                    action="Compare matching keys",
                    result="Matching row pairs identified",
                ),
                StepItem(
                    stepNumber=3,
                    title="Produce Joined Result",
                    description="Return merged columns based on chosen JOIN type.",
                    whatIsHappening="The query engine outputs consolidated rows containing combined columns from both tables.",
                    visualElements=["Result Set Table"],
                    action="Output result set",
                    result="Unified result table output",
                ),
            ]
            vis_data = self._build_interactive_diagram_data(title, combined)
            visual_explanation = "The interactive Venn diagram illustrates how INNER, LEFT, RIGHT, and FULL OUTER joins filter or include records across relational tables."
            key_takeaway = "SQL JOINs merge relational tables by matching shared primary and foreign key predicates across Venn sets."
            real_world = "Used in e-commerce to combine user accounts, orders, products, and shipping addresses into a single receipt."
            quick_check = QuickCheck(
                enabled=True,
                question="Which type of SQL JOIN returns only rows that have matching values in both tables?",
                options=[
                    "INNER JOIN",
                    "FULL OUTER JOIN",
                    "CROSS JOIN",
                ],
                correctAnswer="INNER JOIN",
                explanation="INNER JOIN computes the mathematical intersection where join keys match in both tables.",
            )
            concepts = [
                ConceptItem(name="INNER JOIN", type="set_intersection", importance="high"),
                ConceptItem(name="LEFT & RIGHT JOIN", type="directional_inclusion", importance="high"),
                ConceptItem(name="Primary & Foreign Keys", type="relational_predicate", importance="high"),
                ConceptItem(name="FULL OUTER JOIN", type="union_operation", importance="medium"),
            ]
            prereqs = ["Relational Tables & Rows", "Primary and Foreign Keys", "Basic SELECT Queries"]
            rec_vis = "diagram"
            rep_reason = "Interactive table diagrams and Venn relationships make join logic clear and visual."
            why_works = "SQL JOINs combine relational tables by matching shared primary and foreign key predicates across Venn sets."
            difficulty = "medium"

        # =========================================================================
        # 7. RECURSION
        # =========================================================================
        elif "recursion" in combined or "recursive" in combined:
            answer_payload = AnswerPayload(
                title=f"{clean_topic}: Self-Referential Problem Solving",
                summary=(
                    "Recursion is a programming technique where a function solves a problem by calling itself with smaller inputs. "
                    "Every recursive function requires two fundamental elements: a Base Case (which stops execution) "
                    "and a Recursive Step (which reduces the problem closer to the base case)."
                ),
                sections=[
                    AnswerSection(
                        heading="The Self-Referential Engine",
                        content="Rather than using explicit loops, recursive algorithms solve problems by breaking them into identical, smaller sub-problems.",
                        type="text",
                    ),
                    AnswerSection(
                        heading="The Base Case (The Stopping Anchor)",
                        content="Without a base case, a recursive function calls itself indefinitely, exhausting memory in a 'Stack Overflow' error.",
                        type="mechanism",
                    ),
                    AnswerSection(
                        heading="How the Call Stack Unwinds",
                        content="Each recursive call pushes a new frame onto the call stack. Once the base case is reached, values return and compute backwards as stack frames pop.",
                        type="mechanism",
                    ),
                ],
            )
            steps_list = [
                StepItem(
                    stepNumber=1,
                    title="Initial Function Call",
                    description="Function called with initial input and pushed onto stack.",
                    whatIsHappening="Root call factorial(3) executes and pauses waiting for factorial(2).",
                    visualElements=["Call Frame: factorial(3)"],
                    action="Push factorial(3) to Stack",
                    result="Stack depth: 1",
                ),
                StepItem(
                    stepNumber=2,
                    title="Recursive Descent",
                    description="Problem reduced to smaller sub-problem.",
                    whatIsHappening="factorial(2) pauses waiting for factorial(1) to evaluate.",
                    visualElements=["Call Frame: factorial(2)"],
                    action="Push factorial(2) to Stack",
                    result="Stack depth: 2",
                ),
                StepItem(
                    stepNumber=3,
                    title="Base Case Reached",
                    description="Base condition triggers; returns known direct value.",
                    whatIsHappening="factorial(1) hits base case n <= 1 and immediately returns 1 without further recursion.",
                    visualElements=["Base Case Reached: return 1"],
                    action="Return 1 directly",
                    result="Recursion terminates",
                ),
                StepItem(
                    stepNumber=4,
                    title="Call Stack Unwinding",
                    description="Return values propagate backwards up the stack.",
                    whatIsHappening="Stack frames pop in reverse order, multiplying returned results: 1 * 2 * 3 = 6.",
                    visualElements=["Pop Stack Frames", "Final Result: 6"],
                    action="Pop frames and compute final answer",
                    result="Final value 6 returned to caller",
                ),
            ]
            vis_data = {
                "enabled": True,
                "type": "step_by_step",
                "visualization_type": "step_by_step",
                "title": "Recursive Call Stack & Unwinding",
                "subtitle": "Watch the call stack grow during descent and resolve during unwinding.",
                "steps": [s.model_dump() for s in steps_list],
                "why_this_works": "Visualizing call frames highlights how base cases prevent infinite loops and enable return values to bubble up.",
            }
            visual_explanation = "The step-by-step visualization demonstrates call frames stacking during recursive descent and collapsing upwards as return values compute."
            key_takeaway = "Recursion breaks problems into self-similar sub-problems and always requires a base case to terminate safely."
            real_world = "Used in tree traversals, file system navigation, JSON parsers, and divide-and-conquer algorithms like Merge Sort."
            quick_check = QuickCheck(
                enabled=True,
                question="What happens if a recursive function does not include a base case?",
                options=[
                    "It causes a Stack Overflow error by exhausting memory with infinite calls",
                    "The program automatically loops backwards",
                    "The computer CPU permanently freezes",
                ],
                correctAnswer="It causes a Stack Overflow error by exhausting memory with infinite calls",
                explanation="Without a base case, recursive calls continue endlessly until the call stack runs out of memory.",
            )
            concepts = [
                ConceptItem(name="Base Case (Stopping Condition)", type="control_structure", importance="high"),
                ConceptItem(name="Recursive Step", type="algorithmic_paradigm", importance="high"),
                ConceptItem(name="Call Stack Memory", type="memory_model", importance="high"),
                ConceptItem(name="Stack Unwinding", type="execution_phase", importance="medium"),
            ]
            prereqs = ["Functions & Return Values", "Call Stack Basics", "Conditional Statements (if/else)"]
            rec_vis = "stepByStep"
            rep_reason = "Recursion is best understood through sequential stack frame growth and unwinding."
            why_works = "Visualizing call frames highlights how base cases prevent infinite loops and enable return values to bubble up."
            difficulty = "medium"

        # =========================================================================
        # 8. WATER CYCLE
        # =========================================================================
        elif "water cycle" in combined or "hydrologic" in combined:
            answer_payload = AnswerPayload(
                title=f"{clean_topic}: Earth's Continuous Hydrologic Loop",
                summary=(
                    "The water cycle (or hydrologic cycle) is the continuous biogeochemical process that moves Earth's water "
                    "through the atmosphere, land, and oceans. Powered by solar heat and gravity, water continually transforms "
                    "between liquid, vapor, and ice through evaporation, condensation, precipitation, and runoff."
                ),
                sections=[
                    AnswerSection(
                        heading="Earth's Closed-Loop System",
                        content="Earth does not gain or lose water; the water molecules present today have been recycled across billions of years.",
                        type="text",
                    ),
                    AnswerSection(
                        heading="Evaporation & Transpiration",
                        content="Solar heat warms oceans and lakes, evaporating liquid water into atmospheric vapor, while plants release moisture through leaf transpiration.",
                        type="mechanism",
                    ),
                    AnswerSection(
                        heading="Condensation & Precipitation",
                        content="As water vapor rises and cools, it condenses into clouds. When droplets become heavy, gravity pulls them down as rain, snow, or hail.",
                        type="mechanism",
                    ),
                    AnswerSection(
                        heading="Collection & Runoff",
                        content="Rainfall replenishes freshwater rivers, soil moisture, and underground aquifers, flowing back to oceans to restart the cycle.",
                        type="text",
                    ),
                ],
            )
            steps_list = [
                StepItem(
                    stepNumber=1,
                    title="Evaporation & Transpiration",
                    description="Sunlight heats water bodies, converting liquid into rising vapor.",
                    whatIsHappening="Thermal energy from the sun excites surface water molecules, causing them to evaporate into atmospheric vapor.",
                    visualElements=["Oceans & Lakes", "Solar Heat", "Water Vapor"],
                    action="Liquid H₂O -> Water Vapor",
                    result="Warm vapor rises into atmosphere",
                ),
                StepItem(
                    stepNumber=2,
                    title="Atmospheric Condensation",
                    description="Rising vapor cools and clusters into clouds.",
                    whatIsHappening="Cool temperatures aloft cause water vapor to condense into microscopic water droplets, forming visible clouds.",
                    visualElements=["Water Vapor", "Cool Altitudes", "Clouds"],
                    action="Vapor -> Condensed Cloud Droplets",
                    result="Clouds become saturated",
                ),
                StepItem(
                    stepNumber=3,
                    title="Precipitation",
                    description="Droplets fall to Earth as rain, snow, or hail.",
                    whatIsHappening="Gravity pulls condensed water droplets down to Earth when they become too heavy for updrafts to support.",
                    visualElements=["Clouds", "Rain / Snow Droplets", "Land"],
                    action="Precipitate to Earth",
                    result="Water returned to ground and oceans",
                ),
                StepItem(
                    stepNumber=4,
                    title="Runoff & Aquifer Collection",
                    description="Water flows through rivers and aquifers back to the sea.",
                    whatIsHappening="Freshwater flows across landscapes, replenishing groundwater and returning to oceans to repeat the loop.",
                    visualElements=["Rivers", "Groundwater Aquifers", "Oceans"],
                    action="Runoff to Ocean Basins",
                    result="Cycle loop completes and restarts",
                ),
            ]
            vis_data = {
                "enabled": True,
                "type": "workflow",
                "visualization_type": "workflow",
                "title": "Hydrologic Cycle Circulation",
                "subtitle": "Trace water circulating through Evaporation, Condensation, Precipitation, and Runoff.",
                "actors": ["Oceans & Land", "Atmosphere & Clouds"],
                "stages": [
                    {
                        "stage_number": 1,
                        "title": "1. Evaporation & Transpiration",
                        "subtitle": "Solar heat converts liquid to vapor",
                        "description": "Solar energy warms surface water, causing it to evaporate and rise as invisible vapor.",
                        "from_actor": "Oceans & Land",
                        "to_actor": "Atmosphere",
                        "packet_label": "Water Vapor",
                        "state_label": "VAPOR RISING",
                    },
                    {
                        "stage_number": 2,
                        "title": "2. Condensation",
                        "subtitle": "Vapor cools and forms clouds",
                        "description": "Rising vapor cools at high altitudes and condenses into cloud water droplets.",
                        "from_actor": "Atmosphere",
                        "to_actor": "Atmosphere & Clouds",
                        "packet_label": "Cloud Droplets",
                        "state_label": "CLOUDS FORMED",
                    },
                    {
                        "stage_number": 3,
                        "title": "3. Precipitation",
                        "subtitle": "Rain, snow, or hail falls",
                        "description": "Heavy condensed droplets fall to Earth under the pull of gravity.",
                        "from_actor": "Atmosphere & Clouds",
                        "to_actor": "Oceans & Land",
                        "packet_label": "Precipitation (Rain)",
                        "state_label": "RAIN FALLING",
                    },
                    {
                        "stage_number": 4,
                        "title": "4. Runoff & Collection",
                        "subtitle": "Water returns to oceans",
                        "description": "Precipitation collects in rivers, lakes, and aquifers, flowing back to oceans.",
                        "from_actor": "Land & Rivers",
                        "to_actor": "Oceans & Land",
                        "packet_label": "Surface Runoff",
                        "state_label": "CYCLE RESTARTED",
                    },
                ],
                "steps": [s.model_dump() for s in steps_list],
                "why_this_works": "Continuous process loops clearly demonstrate how solar energy and gravity drive the endless circulation of Earth's water.",
            }
            visual_explanation = "The workflow diagram traces water circulating continuously from ocean evaporation to cloud condensation, rain precipitation, and river collection."
            key_takeaway = "The water cycle is a solar-powered closed loop that continually moves Earth's water between atmosphere, land, and oceans."
            real_world = "Drives weather patterns, replenishes global freshwater reserves, and sustains agriculture worldwide."
            quick_check = QuickCheck(
                enabled=True,
                question="What primary energy source powers Earth's water cycle and drives evaporation?",
                options=[
                    "Solar radiation from the Sun",
                    "Geothermal heat from underwater volcanoes",
                    "Tidal forces from the Moon",
                ],
                correctAnswer="Solar radiation from the Sun",
                explanation="Solar thermal energy heats surface water, providing the energy required for evaporation.",
            )
            concepts = [
                ConceptItem(name="Evaporation & Transpiration", type="phase_change", importance="high"),
                ConceptItem(name="Condensation", type="phase_change", importance="high"),
                ConceptItem(name="Precipitation", type="atmospheric_process", importance="high"),
                ConceptItem(name="Runoff & Collection", type="hydrologic_transport", importance="medium"),
            ]
            prereqs = ["States of Matter (Solid, Liquid, Gas)", "Basic Earth Science"]
            rec_vis = "workflow"
            rep_reason = "The water cycle is a continuous circular process best understood as a multi-stage workflow."
            why_works = "Continuous process loops clearly demonstrate how solar energy and gravity drive the endless circulation of Earth's water."
            difficulty = "easy"

        # =========================================================================
        # DYNAMIC GENERIC EDUCATIONAL FALLBACK (For Any Other Educational Question)
        # =========================================================================
        else:
            answer_payload = AnswerPayload(
                title=f"{clean_topic}: Conceptual Overview & Mechanics",
                summary=(
                    f"{clean_topic} establishes foundational principles for solving problems and understanding systems in its domain. "
                    "By organizing complex behaviors into predictable rules and verifiable stages, students can analyze mechanisms "
                    "and apply insights effectively."
                ),
                sections=[
                    AnswerSection(
                        heading=f"What is {clean_topic}?",
                        content=f"{clean_topic} provides a structured framework for analyzing interactions, enforcing constraints, and producing predictable outcomes.",
                        type="text",
                    ),
                    AnswerSection(
                        heading="How the Mechanism Operates",
                        content=f"The system initializes baseline parameters, executes core state transitions according to fundamental rules, and verifies the final result.",
                        type="mechanism",
                    ),
                ],
            )
            steps_list = [
                StepItem(
                    stepNumber=1,
                    title="Baseline Setup & Inputs",
                    description=f"Establish initial state and parameters for {clean_topic}.",
                    whatIsHappening=f"Initial conditions and inputs are prepared for {clean_topic}.",
                    visualElements=["Initial Parameters", "Baseline State"],
                    action="Initialize system",
                    result="Baseline established",
                ),
                StepItem(
                    stepNumber=2,
                    title="Core Transformation",
                    description=f"Apply rules and process transitions in {clean_topic}.",
                    whatIsHappening=f"The governing laws and mechanisms of {clean_topic} transform inputs.",
                    visualElements=["Active Transformation", "Intermediary State"],
                    action="Execute transformation",
                    result="State updated",
                ),
                StepItem(
                    stepNumber=3,
                    title="Verified Outcome",
                    description=f"Final output is validated for {clean_topic}.",
                    whatIsHappening=f"Execution completes with verified results confirming {clean_topic} principles.",
                    visualElements=["Output State", "Verified Result"],
                    action="Verify result",
                    result="Outcome produced",
                ),
            ]
            vis_data = {
                "enabled": True,
                "type": vis_type,
                "visualization_type": vis_type,
                "title": f"{clean_topic} Interactive Exploration",
                "subtitle": "Explore the core mechanisms and principles interactively.",
                "steps": [s.model_dump() for s in steps_list],
                "why_this_works": f"Interactive visual explanations break down {clean_topic} into clear, digestible stages.",
            }
            visual_explanation = f"The interactive visualization illustrates the progressive state changes and core rules of {clean_topic}."
            key_takeaway = f"Understanding the fundamental rules and transformations of {clean_topic} allows you to predict outcomes accurately."
            real_world = f"Applied widely across modern science, mathematics, and technology to model systems in {clean_topic}."
            quick_check = QuickCheck(
                enabled=True,
                question=f"What is the foundational premise behind {clean_topic}?",
                options=[
                    "Applying structured rules systematically to achieve predictable results",
                    "Randomly altering parameters without constraints",
                    "Eliminating all computation",
                ],
                correctAnswer="Applying structured rules systematically to achieve predictable results",
                explanation=f"Systematic application of foundational principles ensures reliability in {clean_topic}.",
            )
            concepts = [
                ConceptItem(name=f"{clean_topic} Fundamentals", type="core_foundation", importance="high"),
                ConceptItem(name="Operational Mechanics", type="implementation_logic", importance="high"),
                ConceptItem(name="Key Constraints", type="structural_rule", importance="medium"),
            ]
            prereqs = ["Foundational Domain Knowledge"]
            rec_vis = vis_type
            rep_reason = f"An interactive visual explanation makes {clean_topic} easy to understand."
            why_works = f"Interactive visual explanations break down {clean_topic} into clear, digestible stages."
            difficulty = "medium"

        return (
            answer_payload,
            vis_data,
            visual_explanation,
            key_takeaway,
            real_world,
            quick_check,
            steps_list,
            concepts,
            prereqs,
            rec_vis,
            rep_reason,
            why_works,
            difficulty,
        )

    def _build_interactive_visualization_data(self, title: str, combined: str) -> Dict[str, Any]:
        return {
            "enabled": True,
            "type": "algorithm",
            "visualization_type": "interactive_visualization",
            "title": title,
            "subtitle": "Let's understand it visually.",
            "target": 60,
            "elements": [10, 20, 30, 40, 50, 60, 70],
            "items": [10, 20, 30, 40, 50, 60, 70],
            "quick_targets": [20, 50, 70],
            "steps": [
                {
                    "step_number": 1,
                    "total_steps": 3,
                    "title": "STEP 1 — FIND THE MIDDLE",
                    "description": "Compare Target 60 with Middle 40.",
                    "elements": [10, 20, 30, 40, 50, 60, 70],
                    "highlighted_elements": [40],
                    "low_index": 0,
                    "mid_index": 3,
                    "high_index": 6,
                    "low_value": 10,
                    "mid_value": 40,
                    "high_value": 70,
                    "target_value": 60,
                    "active_indices": [0, 1, 2, 3, 4, 5, 6],
                    "eliminated_indices": [],
                    "comparison_left": "Target 60",
                    "comparison_operator": ">",
                    "comparison_right": "Middle 40",
                    "action_direction": "Search RIGHT HALF →",
                    "action_explanation": "Left half [10, 20, 30, 40] is eliminated.",
                    "is_found": False,
                },
                {
                    "step_number": 2,
                    "total_steps": 3,
                    "title": "STEP 2 — CHECK THE NEW MIDDLE",
                    "description": "Compare Target 60 with Middle 60.",
                    "elements": [10, 20, 30, 40, 50, 60, 70],
                    "highlighted_elements": [60],
                    "low_index": 4,
                    "mid_index": 5,
                    "high_index": 6,
                    "low_value": 50,
                    "mid_value": 60,
                    "high_value": 70,
                    "target_value": 60,
                    "active_indices": [4, 5, 6],
                    "eliminated_indices": [0, 1, 2, 3],
                    "comparison_left": "Target 60",
                    "comparison_operator": "==",
                    "comparison_right": "Middle 60",
                    "action_direction": "✓ TARGET FOUND",
                    "action_explanation": "Target 60 is equal to middle element 60 at index 5. Search succeeded!",
                    "is_found": True,
                    "found_index": 5,
                },
                {
                    "step_number": 3,
                    "total_steps": 3,
                    "title": "STEP 3 — UNDERSTAND THE IDEA",
                    "description": "Binary Search eliminates half the remaining elements with each comparison.",
                    "elements": [10, 20, 30, 40, 50, 60, 70],
                    "target_value": 60,
                    "is_found": True,
                    "found_index": 5,
                    "is_why_step": True,
                    "is_idea_step": True,
                    "short_explanation": "Each comparison eliminates about half of the remaining search area.",
                    "summary_blocks": ["7 elements", "3 elements", "1 element", "FOUND"],
                    "linear_progression": [7, 6, 5, 4, 3, 2, 1],
                    "binary_progression": [7, 3, 1],
                    "action_direction": "Logarithmic O(log N) Efficiency",
                    "action_explanation": "Each comparison eliminates about half of the remaining search area.",
                },
            ],
            "why_question": "Why did we ignore the left half?",
            "why_answer": "Because the array is sorted and the target (60) is greater than the middle value (40).",
            "why_this_works": "Each comparison eliminates about half of the remaining search area.",
        }

    def _build_simulation_data(self, title: str, combined: str) -> Dict[str, Any]:
        is_ohm = "ohm" in combined or "circuit" in combined or "voltage" in combined
        return {
            "enabled": True,
            "type": "simulation",
            "visualization_type": "simulation",
            "title": "Ohm's Law" if is_ohm else title,
            "subtitle": "Adjust voltage & resistance to watch current and bulb brightness change.",
            "formula": "V = I × R",
            "secondary_formula": "I = V / R",
            "primary_output": {
                "label": "Current (I)",
                "unit": "mA",
                "formula_type": "division",
            },
            "controls": [
                {
                    "id": "voltage",
                    "label": "Voltage (Push Force)",
                    "unit": "V",
                    "min": 1.0,
                    "max": 24.0,
                    "initial": 9.0,
                    "color": "teal",
                },
                {
                    "id": "resistance",
                    "label": "Resistance (Obstacle)",
                    "unit": "Ω",
                    "min": 10.0,
                    "max": 500.0,
                    "initial": 100.0,
                    "color": "orange",
                },
            ],
            "experiment_question": "What happens if resistance increases?",
            "experiment_answer": "Higher resistance restricts the electron flow, causing Current to decrease and the bulb to dim.",
            "why_this_works": "Current flows when Voltage pushes electrons through Resistance. Increasing voltage increases current, while higher resistance restricts the flow.",
        }

    def _build_concept_map_data(self, title: str, combined: str) -> Dict[str, Any]:
        return {
            "enabled": True,
            "type": "concept_map",
            "visualization_type": "concept_map",
            "title": f"{title} Architecture",
            "subtitle": "Interactive hierarchical relationships and core pillars",
            "root_node": {
                "title": title,
                "subtitle": "Object-Oriented Programming Architecture",
            },
            "nodes": [
                {
                    "id": "class",
                    "title": "Class Blueprint",
                    "subtitle": "Template defining state and behavior",
                    "definition": "A blueprint defining attributes and methods.",
                    "example": "class Vehicle { int speed; void drive(); }",
                    "parent_id": "root",
                    "level": 1,
                    "icon": "blueprint",
                },
                {
                    "id": "object",
                    "title": "Object Instance",
                    "subtitle": "Concrete living entity in memory",
                    "definition": "An instantiated living object with state.",
                    "example": "Vehicle myCar = new Vehicle();",
                    "parent_id": "root",
                    "level": 1,
                    "icon": "instance",
                },
                {
                    "id": "inheritance",
                    "title": "Inheritance",
                    "subtitle": "Hierarchical code reuse ('is-a')",
                    "definition": "Mechanism where child classes inherit parent logic.",
                    "example": "class ElectricCar extends Vehicle",
                    "parent_id": "root",
                    "level": 1,
                    "icon": "hierarchy",
                },
                {
                    "id": "polymorphism",
                    "title": "Polymorphism",
                    "subtitle": "Multiple forms for unified interfaces",
                    "definition": "Ability of different classes to respond uniquely.",
                    "example": "car.accelerate() in SportCar",
                    "parent_id": "inheritance",
                    "level": 2,
                    "icon": "shapes",
                },
            ],
            "why_this_works": "Concept maps show how specialized components inherit attributes and methods from base blueprints without repeating code.",
        }

    def _build_step_by_step_data(self, title: str, combined: str) -> Dict[str, Any]:
        return {
            "enabled": True,
            "type": "workflow",
            "visualization_type": "workflow",
            "title": "TCP Connection Sequence",
            "subtitle": "Interactive 3-way synchronization sequence",
            "actors": ["Client", "Server"],
            "stages": [
                {
                    "stage_number": 1,
                    "title": "1. SYN (Synchronize)",
                    "subtitle": "Client sends Initial Sequence Number",
                    "description": "Client initiates connection with random ISN=100.",
                    "from_actor": "Client",
                    "to_actor": "Server",
                    "packet_label": "SYN [Seq=100]",
                    "state_label": "SYN SENT",
                },
                {
                    "stage_number": 2,
                    "title": "2. SYN-ACK (Sync & Acknowledge)",
                    "subtitle": "Server confirms and sends own SYN",
                    "description": "Server acknowledges Client ISN and replies with own ISN=300.",
                    "from_actor": "Server",
                    "to_actor": "Client",
                    "packet_label": "SYN-ACK [Seq=300, Ack=101]",
                    "state_label": "SYN RECEIVED",
                },
                {
                    "stage_number": 3,
                    "title": "3. ACK (Final Confirmation)",
                    "subtitle": "Connection established",
                    "description": "Client sends final acknowledgment. Full-duplex connection ready for data.",
                    "from_actor": "Client",
                    "to_actor": "Server",
                    "packet_label": "ACK [Ack=301]",
                    "state_label": "ESTABLISHED",
                },
            ],
            "why_this_works": "Step-by-step breakdowns turn complex multi-stage handshakes into clear sequential checkpoints.",
        }

    def _build_interactive_diagram_data(self, title: str, combined: str) -> Dict[str, Any]:
        return {
            "enabled": True,
            "type": "diagram",
            "visualization_type": "diagram",
            "title": "SQL Relational JOINs & Set Theory",
            "subtitle": "Interactive table set relationships & matching rows",
            "diagram_modes": [
                {
                    "id": "inner_join",
                    "label": "INNER JOIN",
                    "description": "Returns only rows with matching keys in BOTH Table A and Table B.",
                    "highlighted_region": "intersection",
                },
                {
                    "id": "left_join",
                    "label": "LEFT JOIN",
                    "description": "Returns ALL rows from Left Table A, plus matching rows from Right Table B (NULL if no match).",
                    "highlighted_region": "left",
                },
                {
                    "id": "right_join",
                    "label": "RIGHT JOIN",
                    "description": "Returns ALL rows from Right Table B, plus matching rows from Left Table A.",
                    "highlighted_region": "right",
                },
                {
                    "id": "full_outer",
                    "label": "FULL OUTER JOIN",
                    "description": "Returns ALL rows from BOTH tables when there is a match in either table.",
                    "highlighted_region": "all",
                },
            ],
            "nodes": [
                {
                    "id": "table_a",
                    "title": "Table A (Users)",
                    "subtitle": "Primary Left Entity (id, name)",
                    "description": "Holds primary entity records (e.g. Users [id=1: Alice, id=2: Bob]).",
                    "example": "SELECT * FROM Users",
                    "color": "teal",
                },
                {
                    "id": "intersection",
                    "title": "Joined Key Match",
                    "subtitle": "Users.id = Orders.user_id",
                    "description": "The matched rows where the foreign key equality predicate evaluates to TRUE.",
                    "example": "ON Users.id = Orders.user_id",
                    "color": "green",
                },
                {
                    "id": "table_b",
                    "title": "Table B (Orders)",
                    "subtitle": "Foreign Key Right Entity (order_id, user_id)",
                    "description": "Holds transaction records referencing users (e.g. Orders [order_101 -> user 1]).",
                    "example": "SELECT * FROM Orders",
                    "color": "purple",
                },
            ],
            "why_this_works": "SQL JOINs combine relational tables by matching shared primary and foreign key predicates across Venn sets.",
        }


_ai_service_instance: Optional[AIService] = None


def get_ai_service() -> AIService:
    global _ai_service_instance
    if _ai_service_instance is None:
        _ai_service_instance = AIService()
    return _ai_service_instance
