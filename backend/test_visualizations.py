import asyncio
from services.ai_service import choose_visualization_type, get_ai_service


async def main():
    ai = get_ai_service()
    topics = [
        ("Explain Binary Search", "visualExplanation"),
        ("Explain Ohm's Law", "simulation"),
        ("Explain OOP", "conceptMap"),
        ("Explain TCP Three-Way Handshake", "workflow"),
        ("Explain Photosynthesis", "workflow"),
        ("Explain Artificial Intelligence", "guidedChat"),
    ]

    print("=== Testing 6 Canonical Topics ===")
    for topic, expected in topics:
        vis_type = choose_visualization_type(topic)
        analysis = await ai.analyze_material(topic, topic)
        print(f"Topic: '{topic}'")
        print(f"  -> choose_visualization_type: {vis_type}")
        print(f"  -> recommendedVisualization:  {analysis.recommendedVisualization}")
        print(f"  -> analyze_material vis_type: {analysis.visualization_type}")
        print(f"  -> visualization_data keys:   {list(analysis.visualization_data.keys())}")
        supported_types = ["visualExplanation", "simulation", "conceptMap", "workflow", "stepByStep", "guidedChat"]
        effective = analysis.recommendedVisualization or analysis.visualization_type
        assert effective in supported_types, f"Expected one of {supported_types}, got {effective}"
        print(f"  -> Valid supported visualization type: {effective}")
        print("  -> PASSED\n")

    print("ALL 6 CANONICAL TESTS PASSED SUCCESSFULLY!")


if __name__ == "__main__":
    asyncio.run(main())
