import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnx_stream/core/theme/app_theme.dart';
import 'package:learnx_stream/features/material_input/models/material_analysis_models.dart';
import 'package:learnx_stream/features/smart_explain/data/visualization_data_provider.dart';
import 'package:learnx_stream/features/smart_explain/models/visual_explanation_models.dart';
import 'package:learnx_stream/features/smart_explain/widgets/algorithm_visualization.dart';
import 'package:learnx_stream/features/smart_explain/widgets/concept_map_visualization.dart';
import 'package:learnx_stream/features/smart_explain/widgets/guided_chat_visualizer.dart';
import 'package:learnx_stream/features/smart_explain/widgets/interactive_diagram_visualization.dart';
import 'package:learnx_stream/features/smart_explain/widgets/process_visualization.dart';
import 'package:learnx_stream/features/smart_explain/widgets/simulation_visualization.dart';
import 'package:learnx_stream/features/smart_explain/widgets/step_visualization.dart';
import 'package:learnx_stream/features/smart_explain/widgets/topic_visualization_helper.dart';
import 'package:learnx_stream/features/smart_explain/widgets/visualization_renderer.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: SingleChildScrollView(
        child: child,
      ),
    ),
  );
}

void main() {
  group('Generic Visual Explanation Architecture Tests', () {
    // -------------------------------------------------------------------------
    // 1. Process & Workflow Visualization (e.g. Photosynthesis / TCP Handshake)
    // -------------------------------------------------------------------------
    testWidgets('ProcessVisualization renders Photosynthesis multi-stage cycle correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          const ProcessVisualization(
            topic: 'Photosynthesis',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Photosynthesis'), findsWidgets);
      expect(find.text('Stage 1 of 3'), findsOneWidget);
      expect(find.text('Why this works'), findsOneWidget);

      // Verify Next button
      final nextBtn = find.text('Next');
      expect(nextBtn, findsOneWidget);
      await tester.tap(nextBtn);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Stage 2 of 3'), findsOneWidget);
    });

    testWidgets('ProcessVisualization renders TCP Handshake data correctly',
        (WidgetTester tester) async {
      final tcpData = TopicVisualizationHelper.getStepByStepData('TCP Three-Way Handshake', null);
      await tester.pumpWidget(
        createTestApp(
          ProcessVisualization(
            topic: 'TCP Three-Way Handshake',
            visualizationData: tcpData,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Client'), findsWidgets);
      expect(find.text('Server'), findsWidgets);
      expect(find.textContaining('SYN'), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // 2. Interactive Diagram Visualization (e.g. SQL JOIN / Human Heart)
    // -------------------------------------------------------------------------
    testWidgets('InteractiveDiagramVisualization renders SQL JOINs with interactive modes',
        (WidgetTester tester) async {
      final sqlData = TopicVisualizationHelper.getInteractiveDiagramData('SQL JOINs', null);
      await tester.pumpWidget(
        createTestApp(
          InteractiveDiagramVisualization(
            topic: 'SQL JOINs',
            visualizationData: sqlData,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('SQL Relational JOINs & Set Theory'), findsOneWidget);
      expect(find.text('INNER JOIN'), findsOneWidget);
      expect(find.text('LEFT JOIN'), findsOneWidget);
      expect(find.text('RIGHT JOIN'), findsOneWidget);
      expect(find.text('FULL OUTER JOIN'), findsOneWidget);

      // Switch mode to LEFT JOIN
      await tester.tap(find.text('LEFT JOIN'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('Left Table A'), findsOneWidget);
    });

    testWidgets('InteractiveDiagramVisualization renders Human Heart anatomy',
        (WidgetTester tester) async {
      final heartData = TopicVisualizationHelper.getInteractiveDiagramData('Human Heart Circulation', null);
      await tester.pumpWidget(
        createTestApp(
          InteractiveDiagramVisualization(
            topic: 'Human Heart Circulation',
            visualizationData: heartData,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Human Heart & Blood Circulation Diagram'), findsOneWidget);
      expect(find.text('Systemic Circuit'), findsOneWidget);
      expect(find.text('Pulmonary Circuit'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 3. Concept Map Visualization (e.g. OOP Pillars / DBMS)
    // -------------------------------------------------------------------------
    testWidgets('ConceptMapVisualization renders OOP hierarchy and node selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          const ConceptMapVisualization(
            topic: 'Object Oriented Programming',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Interactive Concept Hierarchy'), findsOneWidget);
      expect(find.text('Encapsulation'), findsWidgets);
      expect(find.text('Inheritance'), findsWidgets);

      // Tap on Inheritance node
      await tester.tap(find.text('Inheritance').first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('class ElectricCar extends Vehicle'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 4. Algorithm Visualization (Binary Search / Sorting / Arbitrary arrays)
    // -------------------------------------------------------------------------
    testWidgets('AlgorithmVisualization renders Binary Search dataset and steps through cleanly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          const AlgorithmVisualization(
            topic: 'Binary Search',
            initialArray: [10, 20, 30, 40, 50, 60, 70],
            initialTarget: 60,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Target: 60'), findsOneWidget);
      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text('LOW'), findsOneWidget);
      expect(find.text('MID'), findsOneWidget);
      expect(find.text('HIGH'), findsOneWidget);
      expect(find.text('STEP 1 — FIND THE MIDDLE'), findsOneWidget);

      // Step forward to Step 2
      final nextBtn = find.text('Next');
      expect(nextBtn, findsOneWidget);
      await tester.tap(nextBtn);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.text('STEP 2 — CHECK THE NEW MIDDLE'), findsOneWidget);

      // Step forward to Step 3
      await tester.tap(nextBtn);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('STEP 3 — UNDERSTAND THE IDEA'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 5. Simulation Visualization (e.g. Ohm\'s Law)
    // -------------------------------------------------------------------------
    testWidgets('SimulationVisualization renders Ohm\'s Law formula and controls',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          const SimulationVisualization(
            topic: "Ohm's Law",
          ),
        ),
      );
      // Pump a bounded duration for repeating animation controllers
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text("Ohm's Law"), findsWidgets);
      expect(find.textContaining('V = I × R'), findsOneWidget);
      expect(find.textContaining('Voltage'), findsWidgets);
      expect(find.textContaining('Resistance'), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // 6. StepVisualization (Sequential checkpoints)
    // -------------------------------------------------------------------------
    testWidgets('StepVisualization renders sequential stages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          const StepVisualization(
            topic: 'Compiler Lifecycle',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('STAGE 1 of 3'), findsOneWidget);
      expect(find.text('1. Initiation Phase'), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // 7. GuidedChatVisualizer (Socratic reasoning)
    // -------------------------------------------------------------------------
    testWidgets('GuidedChatVisualizer renders Socratic discovery questions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          const GuidedChatVisualizer(
            topic: 'Binary Search',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Why must the array be sorted?'), findsOneWidget);
      expect(find.textContaining('Step 1:'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 8. VisualizationRenderer Factory Routing
    // -------------------------------------------------------------------------
    testWidgets('VisualizationRenderer routes dynamic types properly',
        (WidgetTester tester) async {
      // 8a. Diagram Routing
      final diagramAnalysis = MaterialAnalysisResponse(
        topic: 'SQL Relational JOINs',
        summary: 'Learn SQL table joins.',
        concepts: [
          const ConceptItem(name: 'JOIN', type: 'database', importance: 'high'),
        ],
        difficulty: 'medium',
        prerequisites: ['SQL Basics'],
        recommendedRepresentation: const RecommendedRepresentation(
          type: 'interactive_diagram',
          reason: 'Table relationships are best understood through Venn diagrams.',
        ),
        visualizationType: 'interactive_diagram',
        visualizationData: {},
        whyThisWorks: 'Visual diagrams show relational overlaps.',
      );

      await tester.pumpWidget(
        createTestApp(
          VisualizationRenderer(
            analysis: diagramAnalysis,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(InteractiveDiagramVisualization), findsOneWidget);

      // 8b. Process Routing
      final processAnalysis = MaterialAnalysisResponse(
        topic: 'Photosynthesis',
        summary: 'Plant cellular energy cycle.',
        concepts: [
          const ConceptItem(name: 'Calvin Cycle', type: 'biology', importance: 'high'),
        ],
        difficulty: 'easy',
        prerequisites: ['Cell Biology'],
        recommendedRepresentation: const RecommendedRepresentation(
          type: 'process',
          reason: 'Biological cycles are best visualized as stage processes.',
        ),
        visualizationType: 'process',
        visualizationData: {},
        whyThisWorks: 'Visual processes clarify energy flow.',
      );

      await tester.pumpWidget(
        createTestApp(
          VisualizationRenderer(
            analysis: processAnalysis,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ProcessVisualization), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 9. Generic Visualization Model & Data Provider Architecture Tests
    // -------------------------------------------------------------------------
    test('VisualizationDataProvider creates canonical 3-step Binary Search data', () {
      final vis = VisualizationDataProvider.getBinarySearchVisualization();
      expect(vis.topic, equals('Binary Search'));
      expect(vis.type, equals(VisualizationType.visualExplanation));
      expect(vis.steps.length, equals(3));

      // Step 1
      final s1 = vis.steps[0];
      expect(s1.stepNumber, equals(1));
      expect(s1.totalSteps, equals(3));
      expect(s1.lowIndex, equals(0));
      expect(s1.midIndex, equals(3));
      expect(s1.highIndex, equals(6));
      expect(s1.midValue, equals(40));
      expect(s1.elements, equals([10, 20, 30, 40, 50, 60, 70]));
      expect(s1.highlightedElements, equals([40]));
      expect(s1.comparison, equals('60 > 40'));
      expect(s1.action, equals('Search RIGHT HALF'));
      expect(s1.isFound, isFalse);

      // Step 2
      final s2 = vis.steps[1];
      expect(s2.stepNumber, equals(2));
      expect(s2.totalSteps, equals(3));
      expect(s2.lowIndex, equals(4));
      expect(s2.midIndex, equals(5));
      expect(s2.highIndex, equals(6));
      expect(s2.midValue, equals(60));
      expect(s2.activeElements, equals([50, 60, 70]));
      expect(s2.eliminatedElements, equals([10, 20, 30, 40]));
      expect(s2.highlightedElements, equals([60]));
      expect(s2.comparison, equals('60 = 60'));
      expect(s2.result, equals('TARGET FOUND'));
      expect(s2.isFound, isTrue);

      // Step 3
      final s3 = vis.steps[2];
      expect(s3.stepNumber, equals(3));
      expect(s3.totalSteps, equals(3));
      expect(s3.isIdeaStep, isTrue);
      expect(s3.summaryBlocks, equals(['7 elements', '3 elements', '1 element', 'FOUND']));
      expect(s3.shortExplanation, equals('Each comparison eliminates about half of the remaining search area.'));
    });

    test('Visualization serialization and deserialization preserves all fields', () {
      final original = VisualizationDataProvider.getBinarySearchVisualization();
      final json = original.toJson();
      final reconstructed = Visualization.fromJson(json);

      expect(reconstructed.topic, equals('Binary Search'));
      expect(reconstructed.steps.length, equals(3));
      expect(reconstructed.steps[0].midValue, equals(40));
      expect(reconstructed.steps[1].midValue, equals(60));
      expect(reconstructed.steps[1].isFound, isTrue);
      expect(reconstructed.steps[2].summaryBlocks.length, equals(4));
    });

    test('VisualizationDataProvider supports future visualization types generically', () {
      final oopVis = VisualizationDataProvider.getVisualizationForTopic(
        topic: 'OOP Pillars',
        type: VisualizationType.conceptMap,
      );
      expect(oopVis.type, equals(VisualizationType.conceptMap));
      expect(oopVis.title, contains('OOP Pillars'));

      final ohmVis = VisualizationDataProvider.getVisualizationForTopic(
        topic: "Ohm's Law",
        type: VisualizationType.simulation,
      );
      expect(ohmVis.type, equals(VisualizationType.simulation));

      final tcpVis = VisualizationDataProvider.getVisualizationForTopic(
        topic: 'TCP Handshake',
        type: VisualizationType.workflow,
      );
      expect(tcpVis.type, equals(VisualizationType.workflow));
    });

    // -------------------------------------------------------------------------
    // 10. AI Analysis Output Model & Topic-to-Visualization Connection Tests
    // -------------------------------------------------------------------------
    test('MaterialAnalysisResponse parses new recommendedVisualization, reason, and visualization structure', () {
      final jsonPayload = {
        'topic': 'Binary Search',
        'summary': 'Logarithmic divide and conquer search.',
        'concepts': [
          {'name': 'Divide and Conquer', 'type': 'paradigm', 'importance': 'high'},
        ],
        'difficulty': 'medium',
        'prerequisites': ['Sorted Arrays'],
        'recommendedVisualization': 'visualExplanation',
        'reason': 'An animated array makes the search process easy to see.',
        'visualization': {
          'title': 'Binary Search',
          'steps': [
            {
              'step_number': 1,
              'title': 'STEP 1 — FIND THE MIDDLE',
              'elements': [10, 20, 30, 40, 50, 60, 70],
              'mid_value': 40,
              'action': 'Search RIGHT HALF',
            }
          ]
        },
      };

      final response = MaterialAnalysisResponse.fromJson(jsonPayload);
      expect(response.topic, equals('Binary Search'));
      expect(response.recommendedVisualization, equals('visualExplanation'));
      expect(response.reason, equals('An animated array makes the search process easy to see.'));
      expect(response.visualization, isNotEmpty);
      expect(response.visualization['title'], equals('Binary Search'));
      expect(response.visualizationDisplayName, equals('Visual Explanation'));
    });

    test('Topic-to-Visualization connection across all 6 specified topics', () {
      // 1. Binary Search -> visualExplanation
      final bs = MaterialAnalysisResponse.fromJson({
        'topic': 'Binary Search',
        'recommendedVisualization': 'visualExplanation',
        'reason': 'An animated array makes the search process easy to see.',
        'visualization': {},
      });
      expect(bs.recommendedVisualization, equals('visualExplanation'));
      expect(bs.visualizationDisplayName, equals('Visual Explanation'));

      // 2. Ohm's Law -> simulation
      final ohm = MaterialAnalysisResponse.fromJson({
        'topic': "Ohm's Law",
        'recommendedVisualization': 'simulation',
        'reason': 'Changing voltage and resistance helps students observe how current changes.',
        'visualization': {},
      });
      expect(ohm.recommendedVisualization, equals('simulation'));
      expect(ohm.visualizationDisplayName, equals('Interactive Simulation'));

      // 3. Object Oriented Programming -> conceptMap
      final oop = MaterialAnalysisResponse.fromJson({
        'topic': 'Object Oriented Programming',
        'recommendedVisualization': 'conceptMap',
        'reason': 'OOP concepts are easier to understand through relationships between classes, objects, inheritance, encapsulation and polymorphism.',
        'visualization': {},
      });
      expect(oop.recommendedVisualization, equals('conceptMap'));
      expect(oop.visualizationDisplayName, equals('Concept Map'));

      // 4. TCP Three-Way Handshake -> workflow
      final tcp = MaterialAnalysisResponse.fromJson({
        'topic': 'TCP Three-Way Handshake',
        'recommendedVisualization': 'workflow',
        'reason': 'The concept is naturally represented as a sequence of communication steps.',
        'visualization': {},
      });
      expect(tcp.recommendedVisualization, equals('workflow'));
      expect(tcp.visualizationDisplayName, equals('Workflow Sequence'));

      // 5. Photosynthesis -> workflow
      final photo = MaterialAnalysisResponse.fromJson({
        'topic': 'Photosynthesis',
        'recommendedVisualization': 'workflow',
        'reason': 'Photosynthesis consists of connected stages and processes.',
        'visualization': {},
      });
      expect(photo.recommendedVisualization, equals('workflow'));
      expect(photo.visualizationDisplayName, equals('Workflow Sequence'));

      // 6. Sorting -> visualExplanation
      final sort = MaterialAnalysisResponse.fromJson({
        'topic': 'Sorting',
        'recommendedVisualization': 'visualExplanation',
        'reason': 'An animated array can show elements being compared and rearranged.',
        'visualization': {},
      });
      expect(sort.recommendedVisualization, equals('visualExplanation'));
      expect(sort.visualizationDisplayName, equals('Visual Explanation'));
    });

    test('Unsupported visualization type gracefully falls back to visualExplanation without crashing', () {
      final fallback = MaterialAnalysisResponse.fromJson({
        'topic': 'Quantum Computing',
        'recommendedVisualization': 'unknown_unsupported_3d_render',
        'reason': 'Complex quantum state transformations.',
        'visualization': {},
      });
      expect(fallback.recommendedVisualization, equals('visualExplanation'));
      expect(fallback.visualizationDisplayName, equals('Visual Explanation'));
    });

    testWidgets('SmartExplainScreen renders appropriate widget matching AI recommended visualization',
        (WidgetTester tester) async {
      // Test 1: Ohm's Law -> renders Simulation
      final ohmAnalysis = MaterialAnalysisResponse.fromJson({
        'topic': "Ohm's Law",
        'summary': 'Voltage, Current, Resistance relationship.',
        'concepts': [],
        'difficulty': 'easy',
        'prerequisites': [],
        'recommendedVisualization': 'simulation',
        'reason': 'Changing voltage and resistance helps students observe how current changes.',
        'visualization': {},
      });

      await tester.pumpWidget(
        createTestApp(
          VisualizationRenderer(
            analysis: ohmAnalysis,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(SimulationVisualization), findsOneWidget);

      // Test 2: OOP -> renders Concept Map
      final oopAnalysis = MaterialAnalysisResponse.fromJson({
        'topic': 'Object Oriented Programming',
        'summary': 'Classes, Objects, and Pillars.',
        'concepts': [],
        'difficulty': 'medium',
        'prerequisites': [],
        'recommendedVisualization': 'conceptMap',
        'reason': 'OOP concepts are easier to understand through relationships.',
        'visualization': {},
      });

      await tester.pumpWidget(
        createTestApp(
          VisualizationRenderer(
            analysis: oopAnalysis,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ConceptMapVisualization), findsOneWidget);

      // Test 3: TCP Handshake -> renders Process / Workflow
      final tcpAnalysis = MaterialAnalysisResponse.fromJson({
        'topic': 'TCP Three-Way Handshake',
        'summary': 'SYN, SYN-ACK, ACK handshake.',
        'concepts': [],
        'difficulty': 'medium',
        'prerequisites': [],
        'recommendedVisualization': 'workflow',
        'reason': 'The concept is naturally represented as a sequence of communication steps.',
        'visualization': {},
      });

      await tester.pumpWidget(
        createTestApp(
          VisualizationRenderer(
            analysis: tcpAnalysis,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ProcessVisualization), findsOneWidget);

      // Test 4: Sorting -> renders Algorithm / Visual Explanation
      final sortAnalysis = MaterialAnalysisResponse.fromJson({
        'topic': 'Sorting',
        'summary': 'Sorting array elements.',
        'concepts': [],
        'difficulty': 'easy',
        'prerequisites': [],
        'recommendedVisualization': 'visualExplanation',
        'reason': 'An animated array can show elements being compared and rearranged.',
        'visualization': {},
      });

      await tester.pumpWidget(
        createTestApp(
          VisualizationRenderer(
            analysis: sortAnalysis,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AlgorithmVisualization), findsOneWidget);
    });
  });
}
