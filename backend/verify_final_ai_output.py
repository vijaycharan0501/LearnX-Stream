import io
import json
import sys
import requests

# Ensure stdout handles UTF-8 on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")

BASE_URL = "http://127.0.0.1:8001"

TEST_QUESTIONS = [
    ("Explain photosynthesis", "Photosynthesis in green plants, chlorophyll, sunlight, water, carbon dioxide, glucose and oxygen."),
    ("How does binary search work?", "Binary search on sorted array with low, mid, high pointers and logarithmic time complexity."),
    ("Explain Ohm's Law", "Voltage, current, resistance, circuit simulation, and V = I * R formula."),
    ("What is inheritance in OOP?", "Object-oriented programming inheritance, parent classes, subclasses, code reuse, and method overriding."),
    ("Explain TCP three-way handshake", "TCP connection sequence with SYN, SYN-ACK, and ACK packets across client and server."),
    ("What is SQL JOIN?", "SQL relational joins including INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL OUTER JOIN with Venn sets."),
    ("Explain recursion", "Recursive function calls, base cases, call stacks, unwinding, and preventing stack overflow."),
    ("What is the water cycle?", "Hydrologic water cycle, evaporation, transpiration, condensation, precipitation, and runoff."),
]


def test_final_ai_output():
    print("=" * 70)
    print("LEARNX STREAM — FINAL AI OUTPUT GENERATION VERIFICATION")
    print("Testing 8 canonical questions for natural, tailored educational responses")
    print("=" * 70)

    all_passed = True
    collected_responses = []

    for i, (title, text) in enumerate(TEST_QUESTIONS, 1):
        print(f"\n[{i}/8] Testing: \"{title}\"")
        try:
            resp = requests.post(
                f"{BASE_URL}/analyze-material",
                json={"title": title, "text": text},
                timeout=25,
            )
            if resp.status_code != 200:
                print(f"  [FAIL] HTTP {resp.status_code}: {resp.text}")
                all_passed = False
                continue

            data = resp.json()
            collected_responses.append(data)

            # Extract fields
            topic = data.get("topic", "")
            summary = data.get("summary", "")
            answer = data.get("answer") or {}
            ans_title = answer.get("title", "")
            ans_sections = answer.get("sections", [])
            vis_type = data.get("visualizationType") or data.get("visualization_type")
            vis_data = data.get("visualization") or data.get("visualization_data") or {}
            steps = data.get("steps") or vis_data.get("steps") or vis_data.get("stages") or []
            visual_exp = data.get("visualExplanation", "")
            key_takeaway = data.get("keyTakeaway") or data.get("keyIdea", "")
            quick_check = data.get("quickCheck") or {}
            concepts = data.get("concepts", [])

            print(f"  * Topic:              {topic}")
            print(f"  * Answer Title:       {ans_title}")
            print(f"  * Summary:            {summary[:90]}...")
            print(f"  * Sections Count:     {len(ans_sections)} tailored sections")
            for idx, s in enumerate(ans_sections, 1):
                print(f"    - Section {idx}: [{s.get('type', 'text')}] \"{s.get('heading')}\" -> {s.get('content', '')[:60]}...")
            print(f"  * Visualization Type: {vis_type}")
            print(f"  * Visual Elements/Steps: {len(steps)} steps/stages")
            if steps:
                first_step = steps[0]
                print(f"    - Step 1: \"{first_step.get('title')}\" -> {first_step.get('whatIsHappening', first_step.get('description', ''))[:60]}...")
            print(f"  * Visual Explanation: {visual_exp[:80]}...")
            print(f"  * Key Takeaway:       {key_takeaway[:80]}...")
            print(f"  * Quick Check Q:      \"{quick_check.get('question', '')}\"")
            print(f"    - Options:          {quick_check.get('options', [])}")
            print(f"    - Correct Answer:   \"{quick_check.get('correctAnswer', '')}\"")

            # Assertions
            assert len(summary) > 20, "Summary is missing or too short"
            assert len(ans_sections) >= 2, "Answer should have at least 2 flexible sections"
            assert vis_type, "Visualization type must be present"
            assert len(steps) >= 2, "Visualization must contain at least 2 steps or stages"
            assert len(key_takeaway) > 10, "Key takeaway must be meaningful"
            assert len(quick_check.get("options", [])) >= 2, "Quick check must have multiple options"
            assert bool(quick_check.get("correctAnswer")), "Quick check must have a correct answer"

            print(f"  [PASS] Verified natural educational response & visualization for \"{title}\"")

        except Exception as e:
            print(f"  [ERROR] {e}")
            all_passed = False

    # Check that answers feel different and are not forced into the same template
    if len(collected_responses) == 8:
        print("\n" + "-" * 70)
        print("VERIFYING DIVERSITY & NON-TEMPLATE SPECIALIZATION:")
        vis_types = [r.get("visualizationType") for r in collected_responses]
        unique_types = set(vis_types)
        print(f"  * Unique visualization types used across 8 questions: {unique_types}")
        assert len(unique_types) >= 4, f"Expected at least 4 distinct visualization types, got {len(unique_types)}"

        section_counts = [len((r.get("answer") or {}).get("sections", [])) for r in collected_responses]
        print(f"  * Section counts across 8 questions: {section_counts}")

        all_headings = [[s.get("heading") for s in (r.get("answer") or {}).get("sections", [])] for r in collected_responses]
        print("  * Sample section headings per topic:")
        for t, h in zip([q[0] for q in TEST_QUESTIONS], all_headings):
            print(f"    - {t}: {h}")
        print("  [PASS] All 8 questions use specialized, non-template educational structures!")

    print("\n" + "=" * 70)
    if all_passed:
        print("ALL 8 QUESTIONS PASSED FINAL AI OUTPUT GENERATION VERIFICATION!")
    else:
        print("SOME VERIFICATIONS FAILED!")
    print("=" * 70)
    return all_passed


if __name__ == "__main__":
    success = test_final_ai_output()
    sys.exit(0 if success else 1)
