import io
import sys
import requests
import json

# Ensure stdout handles UTF-8 on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

BASE_URL = "http://127.0.0.1:8001"

TOPICS = [
    ("Photosynthesis", "How do plants convert sunlight, water, and carbon dioxide into oxygen and glucose?"),
    ("Binary Search", "How does binary search find a target in a sorted array by dividing search space in half?"),
    ("Ohm's Law", "Explain how voltage, current, and resistance are related by V = I * R in electric circuits."),
    ("Object Oriented Programming", "Explain classes, objects, encapsulation, and inheritance in OOP."),
    ("TCP three-way handshake", "How does TCP establish a reliable connection using SYN, SYN-ACK, and ACK?"),
    ("SQL JOIN", "Explain how INNER JOIN combines rows from two tables based on a related column.")
]

def test_topics():
    print("=" * 60)
    print("TESTING DUAL LEARNING EXPERIENCE (VISUAL + EDUCATIONAL CONTENT)")
    print("=" * 60)

    all_passed = True

    for title, text in TOPICS:
        print(f"\n---> Testing Topic: '{title}'")
        try:
            resp = requests.post(
                f"{BASE_URL}/analyze-material",
                json={"title": title, "text": text},
                timeout=25
            )
            if resp.status_code != 200:
                print(f"[FAIL] HTTP {resp.status_code}: {resp.text}")
                all_passed = False
                continue

            data = resp.json()
            viz_type = data.get("visualizationType") or (data.get("interactiveVisualization") or {}).get("type")
            overview = data.get("conceptOverview", "")
            steps = data.get("steps", [])
            key_idea = data.get("keyIdea", "")
            real_world = data.get("realWorldConnection", "")
            qc = data.get("quickCheck") or {}

            print(f"  * Visualization Type: {viz_type}")
            print(f"  * Concept Overview:   {overview[:80]}...")
            print(f"  * Steps Count:        {len(steps)} steps")
            if steps:
                print(f"    - Step 1: '{steps[0].get('title')}' -> What is happening: '{steps[0].get('whatIsHappening', '')[:60]}...'")
            print(f"  * Key Idea:           {key_idea[:80]}...")
            print(f"  * Real-World Connect: {real_world[:80]}...")
            print(f"  * Quick Check:        Q: '{qc.get('question', '')}' (Ans: {qc.get('correctAnswer')}, Options: {len(qc.get('options', []))})")

            # Validation assertions
            assert len(overview) > 10, "conceptOverview is too short or missing"
            assert len(steps) >= 2, "steps must contain at least 2 steps"
            assert len(key_idea) > 5, "keyIdea is too short or missing"
            assert len(real_world) > 5, "realWorldConnection is too short or missing"
            assert len(qc.get("options", [])) >= 2, "quickCheck must have at least 2 options"
            assert bool(qc.get("correctAnswer")), "quickCheck must have a correctAnswer"

            print(f"  [PASS] Successfully verified full structured learning package for '{title}'!")

        except Exception as e:
            print(f"  [ERROR] {e}")
            all_passed = False

    print("\n" + "=" * 60)
    if all_passed:
        print("ALL TOPICS PASSED THE LEARNING EXPERIENCE UPGRADE VERIFICATION!")
    else:
        print("SOME TESTS FAILED!")
    print("=" * 60)
    return all_passed

if __name__ == "__main__":
    success = test_topics()
    sys.exit(0 if success else 1)
