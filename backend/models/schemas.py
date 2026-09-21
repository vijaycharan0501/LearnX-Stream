from typing import List, Literal, Optional
from pydantic import BaseModel, Field


class ConceptItem(BaseModel):
    name: str = Field(
        ...,
        description="Name of the core concept or sub-topic",
        examples=["Divide and Conquer"],
    )
    type: str = Field(
        default="concept",
        description="Category/type of concept (e.g., algorithm, data_structure, rule, formula, architecture)",
        examples=["algorithmic_paradigm"],
    )
    importance: Literal["high", "medium", "low"] = Field(
        default="medium",
        description="Relative importance of this concept for understanding the topic",
        examples=["high"],
    )


class StepItem(BaseModel):
    stepNumber: int = Field(default=1, description="Sequential stage or step number")
    title: str = Field(default="", description="Short stage title")
    description: str = Field(default="", description="Explanation of what is happening in this stage")
    visualElements: List[object] = Field(default_factory=list, description="Visual elements or items present in stage")
    highlightedElements: List[object] = Field(default_factory=list, description="Elements in focus or highlighted")
    activeElements: List[object] = Field(default_factory=list, description="Active indices or elements")
    action: str = Field(default="", description="Action taking place")
    result: str = Field(default="", description="Result of this stage")
    whatIsHappening: str = Field(default="", description="Clear concise explanation of what is happening")


class AnswerSection(BaseModel):
    heading: str = Field(..., description="Section title or heading")
    content: str = Field(..., description="Clear, student-friendly explanation or example")
    type: str = Field(default="text", description="Section format: text, example, mechanism, formula, comparison")


class AnswerPayload(BaseModel):
    title: str = Field(..., description="Educational title for the answer")
    summary: str = Field(..., description="Direct, concise concept answer")
    sections: List[AnswerSection] = Field(default_factory=list, description="Flexible educational sections")


class QuickCheck(BaseModel):
    enabled: bool = Field(default=True, description="Whether quick check is active")
    question: str = Field(..., description="Concept check question")
    options: List[str] = Field(..., description="Selectable multiple choice options")
    correctAnswer: str = Field(..., description="Correct answer matching one option")
    explanation: str = Field(default="", description="Explanation of why this answer is correct")


class RecommendedRepresentation(BaseModel):
    type: str = Field(
        ...,
        description="The best interactive representation format chosen by AI to explain this concept",
        examples=["simulation"],
    )
    reason: str = Field(
        ...,
        description="Pedagogical explanation for why this representation format was chosen",
        examples=[
            "Binary Search operates with dynamic pointer bounds (low, high, mid) which are best understood through interactive step-by-step state simulation."
        ],
    )


class MaterialAnalysisRequest(BaseModel):
    title: str = Field(
        ...,
        min_length=1,
        description="Title or topic of the study material",
        examples=["Binary Search"],
    )
    text: str = Field(
        ...,
        min_length=1,
        description="Raw study material notes, textbook content, or document text",
        examples=[
            "Binary Search is a search algorithm that finds the position of a target value within a sorted array..."
        ],
    )


class MaterialAnalysisResponse(BaseModel):
    topic: str = Field(
        ...,
        description="Primary topic name identified from the study material",
        examples=["Binary Search"],
    )
    summary: str = Field(
        ...,
        description="Concise 2-3 sentence overview explaining what the student will learn",
        examples=[
            "Binary Search efficiently locates an element in a sorted list by repeatedly halving the search interval. It achieves O(log N) logarithmic time complexity by comparing the target with the middle element."
        ],
    )
    answer: Optional[AnswerPayload] = Field(
        default=None,
        description="Flexible, natural educational answer with tailored sections",
    )
    visualExplanation: Optional[str] = Field(
        default=None,
        description="Direct explanation of what the student is seeing in the visualization",
    )
    keyTakeaway: Optional[str] = Field(
        default=None,
        description="Core takeaway the student should remember",
    )
    conceptOverview: Optional[str] = Field(
        default=None,
        description="Clear 2-4 sentence student-friendly explanation answering 'What is [topic]?'",
    )
    steps: Optional[List[StepItem]] = Field(
        default=None,
        description="3-5 meaningful stages of the concept with what is happening",
    )
    keyIdea: Optional[str] = Field(
        default=None,
        description="1-2 sentences explaining the most important takeaway",
    )
    realWorldConnection: Optional[str] = Field(
        default=None,
        description="Short real-world application/connection",
    )
    quickCheck: Optional[QuickCheck] = Field(
        default=None,
        description="Interactive concept check question with options and explanation",
    )
    concepts: List[ConceptItem] = Field(
        default_factory=list,
        description="Extracted sub-concepts and foundational building blocks",
    )
    difficulty: Literal["easy", "medium", "hard"] = Field(
        default="medium",
        description="Estimated conceptual difficulty level",
        examples=["medium"],
    )
    prerequisites: List[str] = Field(
        default_factory=list,
        description="List of prerequisite concepts required before learning this material",
        examples=["Sorted Arrays", "Index Arithmetic", "Time Complexity Basics"],
    )
    recommended_representation: Optional[RecommendedRepresentation] = Field(
        default=None,
        description="AI recommended primary learning representation format",
    )
    visualization_type: str = Field(
        default="interactive_visualization",
        description="Dynamic visualization type: visualExplanation, simulation, conceptMap, workflow, diagram, stepByStep, guidedChat",
        examples=["visualExplanation"],
    )
    visualization_data: dict = Field(
        default_factory=dict,
        description="Structured dynamic payload tailored for the chosen visualization component",
    )
    why_this_works: str = Field(
        default="This visual representation breaks down complex logic into intuitive, digestible stages.",
        description="Concise, student-friendly explanation of why this visual method works",
    )
    # Generic visualization & studio extensions
    visualizationType: Optional[str] = Field(
        default=None,
        description="Generic visualization type",
    )
    title: Optional[str] = Field(default=None)
    subtitle: Optional[str] = Field(default=None)
    recommendedVisualization: Optional[str] = Field(
        default=None,
        description="Generic visualization type: visualExplanation, simulation, conceptMap, workflow, diagram, stepByStep, guidedChat",
    )
    reason: Optional[str] = Field(
        default=None,
        description="Rationale for the chosen visualization method",
    )
    visualization: Optional[dict] = Field(
        default=None,
        description="Structured visualization payload",
    )


class HealthResponse(BaseModel):
    status: str = "ok"
    service: str = "LearnX STREAM API"
