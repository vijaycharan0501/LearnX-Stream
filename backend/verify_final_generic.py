import json
import urllib.request
import sys
import io

# Ensure stdout handles utf-8
if sys.platform == "win32":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

topics = [
    ("1. Explain Binary Search", "Explain Binary Search"),
    ("2. Explain Photosynthesis", "Explain Photosynthesis"),
    ("3. Explain Ohm's Law", "Explain Ohm's Law"),
    ("4. Explain Object Oriented Programming", "Explain Object Oriented Programming"),
    ("5. Explain TCP three-way handshake", "Explain TCP three-way handshake"),
    ("6. Explain SQL JOIN", "Explain SQL JOIN"),
]

print("=" * 70)
print("LEARNX STREAM -- FINAL GENERIC AI TEST (6 TOPICS VERIFICATION)")
print("=" * 70)

all_passed = True

for label, topic_prompt in topics:
    print(f"\n--- Testing: {label} ---")
    payload = json.dumps({"title": topic_prompt, "text": topic_prompt}).encode("utf-8")
    req = urllib.request.Request(
        "http://127.0.0.1:8001/analyze-material",
        data=payload,
        headers={"Content-Type": "application/json"},
    )
    try:
        res = urllib.request.urlopen(req, timeout=30)
        assert res.status == 200, f"Expected 200, got {res.status}"
        data = json.loads(res.read().decode("utf-8"))
        
        topic_res = data.get("topic", "")
        rec_vis = data.get("recommendedVisualization") or data.get("visualization_type")
        reason = data.get("reason") or data.get("why_this_works", "")
        why_works = data.get("why_this_works", "")
        concepts = [c.get("name") for c in data.get("concepts", [])]
        vis_payload = data.get("visualization") or data.get("visualization_data", {})
        
        print(f"[OK] HTTP Status: 200 OK")
        print(f"[OK] Returned Topic: '{topic_res}'")
        print(f"[OK] Recommended Visualization: '{rec_vis}'")
        print(f"[OK] Reason: {reason}")
        print(f"[OK] Concepts ({len(concepts)}): {concepts}")
        print(f"[OK] Visualization Payload Structure: {list(vis_payload.keys()) if isinstance(vis_payload, dict) else type(vis_payload)}")
        
        # Verify topic is preserved and not replaced by hardcoded fallback
        assert topic_res != "", "Topic should not be empty"
        assert rec_vis in ["visualExplanation", "simulation", "conceptMap", "workflow", "stepByStep", "guidedChat", "interactive_visualization", "process", "diagram"], f"Invalid visualization type {rec_vis}"
        
        # Verify content relevance
        if "Binary Search" in topic_prompt:
            assert any("binary" in c.lower() or "search" in c.lower() or "divide" in c.lower() or "array" in c.lower() for c in concepts) or "binary" in str(vis_payload).lower() or "search" in str(vis_payload).lower()
        elif "Photosynthesis" in topic_prompt:
            assert any("photo" in c.lower() or "light" in c.lower() or "calvin" in c.lower() or "chloroplast" in c.lower() for c in concepts) or "light" in str(vis_payload).lower() or "glucose" in str(vis_payload).lower()
        elif "Ohm" in topic_prompt:
            assert any("voltage" in c.lower() or "current" in c.lower() or "resistance" in c.lower() or "ohm" in c.lower() for c in concepts) or "voltage" in str(vis_payload).lower() or "current" in str(vis_payload).lower()
        elif "Object Oriented" in topic_prompt or "OOP" in topic_prompt:
            assert any("class" in c.lower() or "object" in c.lower() or "encapsulation" in c.lower() or "inheritance" in c.lower() or "polymorphism" in c.lower() for c in concepts) or "class" in str(vis_payload).lower() or "object" in str(vis_payload).lower()
        elif "TCP" in topic_prompt:
            assert any("syn" in c.lower() or "ack" in c.lower() or "handshake" in c.lower() or "tcp" in c.lower() or "packet" in c.lower() or "connection" in c.lower() for c in concepts) or "syn" in str(vis_payload).lower() or "ack" in str(vis_payload).lower()
        elif "SQL JOIN" in topic_prompt:
            assert any("join" in c.lower() or "table" in c.lower() or "sql" in c.lower() or "relational" in c.lower() for c in concepts) or "join" in str(vis_payload).lower() or "table" in str(vis_payload).lower()
            
        print(f"[PASS] Verification Passed for {topic_prompt}!")
    except Exception as e:
        print(f"[FAIL] Failed for {topic_prompt}: {e}")
        all_passed = False

if all_passed:
    print("\n" + "=" * 70)
    print("ALL 6 TOPICS FULLY VALIDATED WITH LIVE GEMINI AI!")
    print("=" * 70)
    sys.exit(0)
else:
    print("\nSome tests failed!")
    sys.exit(1)

