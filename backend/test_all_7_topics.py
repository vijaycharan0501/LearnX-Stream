import urllib.request
import json
import time

topics = [
    "Explain photosynthesis",
    "How does binary search work?",
    "Explain Ohm's Law",
    "What is polymorphism in OOP?",
    "Explain TCP three-way handshake",
    "What is SQL JOIN?",
    "Explain recursion"
]

print("=== TESTING ALL 7 BENCHMARK TOPICS AGAINST FASTAPI + GEMINI ===")
for t in topics:
    payload = json.dumps({"title": t, "text": t}).encode("utf-8")
    req = urllib.request.Request(
        "http://127.0.0.1:8001/analyze-material",
        data=payload,
        headers={"Content-Type": "application/json"}
    )
    try:
        t0 = time.time()
        with urllib.request.urlopen(req, timeout=30) as resp:
            elapsed = time.time() - t0
            body = json.loads(resp.read().decode("utf-8"))
            vis = body.get("visualization_type")
            ans = body.get("answer") or {}
            secs = len(ans.get("sections", []))
            print(f"[OK] \"{t}\" -> 200 OK ({elapsed:.1f}s) | Vis: {vis} | Sections: {secs}")
    except Exception as e:
        print(f"[FAIL] \"{t}\" -> Failed: {e}")
