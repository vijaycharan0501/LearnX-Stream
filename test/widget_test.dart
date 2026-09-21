import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learnx_stream/core/services/api_service.dart';
import 'package:learnx_stream/features/material_input/models/material_analysis_models.dart';
import 'package:learnx_stream/features/material_input/models/material_input_data.dart';
import 'package:learnx_stream/features/material_input/models/study_material.dart';
import 'package:learnx_stream/features/material_input/screens/ai_analysis_screen.dart';
import 'package:learnx_stream/features/material_input/screens/material_input_screen.dart';
import 'package:learnx_stream/features/material_input/screens/material_preview_screen.dart';
import 'package:learnx_stream/features/smart_explain/screens/smart_explain_screen.dart';
import 'package:learnx_stream/features/smart_explain/widgets/binary_search_visualizer.dart';
import 'package:learnx_stream/features/smart_explain/widgets/simulation_visualizer.dart';
import 'package:learnx_stream/features/smart_explain/widgets/concept_map_visualizer.dart';
import 'package:learnx_stream/features/smart_explain/widgets/step_by_step_visualizer.dart';
import 'package:learnx_stream/features/smart_explain/widgets/guided_chat_visualizer.dart';
import 'package:learnx_stream/features/smart_explain/widgets/workflow_visualizer.dart';
import 'package:learnx_stream/features/smart_explain/widgets/simple_binary_search_view.dart';
import 'package:learnx_stream/features/smart_explain/widgets/visualization_renderer.dart';
import 'package:learnx_stream/features/material_input/widgets/topic_input_view.dart';
import 'package:learnx_stream/features/splash/screens/splash_screen.dart';

void main() {
  const sampleBinarySearchJson = {
    "topic": "Binary Search",
    "summary":
        "Binary Search is a fundamental divide-and-conquer algorithm that finds elements in sorted collections in logarithmic O(log N) time by repeatedly halving the search space.",
    "concepts": [
      {
        "name": "Divide and Conquer",
        "type": "algorithmic_paradigm",
        "importance": "high"
      },
      {
        "name": "Logarithmic Time O(log N)",
        "type": "complexity_metric",
        "importance": "high"
      },
      {
        "name": "Sorted Array Invariant",
        "type": "precondition",
        "importance": "high"
      },
      {
        "name": "Boundary Pointers (Low, Mid, High)",
        "type": "data_state",
        "importance": "medium"
      }
    ],
    "difficulty": "medium",
    "prerequisites": [
      "Arrays & Indexing",
      "Comparison Operators",
      "Basic Asymptotic Notation"
    ],
    "recommended_representation": {
      "type": "workflow",
      "reason":
          "Binary Search involves dynamic algorithmic state transitions and boundary comparisons that are most intuitive when visualized interactively."
    },
    "visualization_type": "interactive_visualization",
    "visualization_data": {
      "items": [10, 20, 30, 40, 50, 60, 70],
      "target": 60,
      "quick_targets": [20, 50, 70],
      "why_this_works": "Binary Search repeatedly cuts the search area in half, making the search much faster."
    },
    "why_this_works": "Binary Search repeatedly cuts the search area in half, making the search much faster."
  };

  group('LearnX STREAM - Prototype Screen 1: Splash Screen Tests', () {
    testWidgets('SplashScreen renders emblem, LearnX STREAM branding, and Get Started action', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(disableAutoNavigation: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LearnX'), findsOneWidget);
      expect(find.text('STREAM'), findsOneWidget);
      expect(find.text('Turn Information Into Understanding'), findsOneWidget);
      expect(find.text('Adaptive Visual Pedagogical Engine'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Study Environment • Light Theme'), findsOneWidget);
      expect(find.byIcon(Icons.stream_rounded), findsOneWidget);
    });

    testWidgets('MaterialInputScreen supports Scan, Upload, Topic, and Voice tabs', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: MaterialInputScreen(initialMethod: InputMethod.scan),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Screen Title and Method Tabs
      expect(find.text('Study Material Input'), findsOneWidget);
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
      expect(find.text('Topic / Text'), findsOneWidget);
      expect(find.text('Voice'), findsOneWidget);

      // Switch to Upload Tab
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      expect(find.text('Upload PDF / Image'), findsOneWidget);
      expect(find.text('Tap to browse files from device'), findsOneWidget);

      // Switch to Topic Tab
      await tester.tap(find.text('Topic / Text'));
      await tester.pumpAndSettle();
      expect(find.text('Enter Topic & Notes'), findsOneWidget);

      // Switch to Voice Tab
      await tester.tap(find.text('Voice'));
      await tester.pumpAndSettle();
      expect(find.text('Voice Question'), findsOneWidget);
      expect(find.text('Tap microphone to speak'), findsOneWidget);
    });
  });


  group('LearnX STREAM Phase 6 - Model Serialization Tests', () {
    test('MaterialAnalysisResponse parses full JSON safely', () {
      final analysis = MaterialAnalysisResponse.fromJson(sampleBinarySearchJson);

      expect(analysis.topic, 'Binary Search');
      expect(analysis.difficulty, 'medium');
      expect(analysis.formattedDifficulty, 'Medium');
      expect(analysis.summary, contains('divide-and-conquer'));
      expect(analysis.concepts.length, 4);
      expect(analysis.concepts.first.name, 'Divide and Conquer');
      expect(analysis.concepts.first.formattedType, 'Algorithmic Paradigm');
      expect(analysis.concepts.first.importance, 'high');
      expect(analysis.prerequisites.length, 3);
      expect(analysis.prerequisites, contains('Arrays & Indexing'));
      expect(analysis.recommendedRepresentation.type, 'workflow');
      expect(analysis.recommendedRepresentation.displayName, 'Workflow Sequence');
      expect(analysis.recommendedRepresentation.reason, contains('dynamic algorithmic state'));
      expect(analysis.visualizationType, 'interactive_visualization');
      expect(analysis.visualizationDisplayName, 'Visual Explanation');
    });

    test('MaterialAnalysisResponse handles null / missing fields with defaults', () {
      final analysis = MaterialAnalysisResponse.fromJson({});

      expect(analysis.topic, 'Study Concept');
      expect(analysis.difficulty, 'medium');
      expect(analysis.concepts, isEmpty);
      expect(analysis.prerequisites, isEmpty);
      expect(analysis.recommendedRepresentation.type, 'step_by_step');
    });
  });

  group('LearnX STREAM Phase 6 - ApiService Tests', () {
    test('analyzeMaterial successfully sends POST and parses 200 response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/analyze-material');
        expect(request.method, 'POST');
        final decodedBody = jsonDecode(request.body);
        expect(decodedBody['title'], 'Binary Search');
        expect(decodedBody['text'], contains('algorithm'));

        return http.Response(
          jsonEncode(sampleBinarySearchJson),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(
        baseUrl: 'http://127.0.0.1:8001',
        client: mockClient,
      );

      final result = await service.analyzeMaterial(
        'Binary Search',
        'Binary Search is a search algorithm that finds position in a sorted array.',
      );

      expect(result.topic, 'Binary Search');
      expect(result.concepts.length, 4);
      expect(result.recommendedRepresentation.type, 'workflow');
    });

    test('analyzeMaterial throws ApiException on 400 Bad Request with server message', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'detail': 'Study material text cannot be empty.'}),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ApiService(
        baseUrl: 'http://127.0.0.1:8001',
        client: mockClient,
      );

      expect(
        () => service.analyzeMaterial('Binary Search', 'non-empty text'),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Study material text cannot be empty.')),
      );
    });
  });

  group('LearnX STREAM Phase 6 - AIAnalysisScreen UI Widget Tests', () {
    testWidgets('AIAnalysisScreen renders topic, difficulty, prominent representation, concepts, and prerequisites', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final analysis = MaterialAnalysisResponse.fromJson(sampleBinarySearchJson);

      await tester.pumpWidget(
        MaterialApp(
          home: AIAnalysisScreen(
            analysis: analysis,
            originalMaterial: StudyMaterial(
              title: 'Binary Search',
              sourceType: 'Typed Text',
              rawText: 'Sample text...',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('AI Pedagogical Analysis'), findsOneWidget);
      expect(find.text('Binary Search'), findsOneWidget);
      expect(find.text('Medium Difficulty'), findsOneWidget);

      // Verify Prominent Recommended Representation Section
      expect(find.text('BEST WAY TO LEARN THIS'), findsOneWidget);
      expect(find.text('Workflow Sequence'), findsOneWidget);
      expect(find.text('WORKFLOW'), findsOneWidget);
      expect(find.textContaining('dynamic algorithmic state transitions'), findsOneWidget);

      // Verify AI Summary
      expect(find.text('AI Summary'), findsOneWidget);
      expect(find.textContaining('fundamental divide-and-conquer algorithm'), findsOneWidget);

      // Verify Concepts List
      expect(find.text('Important Concepts'), findsOneWidget);
      expect(find.text('Divide and Conquer'), findsOneWidget);
      expect(find.text('Logarithmic Time O(log N)'), findsOneWidget);
      expect(find.text('Sorted Array Invariant'), findsOneWidget);
      expect(find.text('HIGH PRIORITY'), findsWidgets);

      // Verify Prerequisites
      expect(find.text('Recommended Prerequisites'), findsOneWidget);
      expect(find.text('Arrays & Indexing'), findsOneWidget);
      expect(find.text('Comparison Operators'), findsOneWidget);
    });
  });

  group('LearnX STREAM Phase 6 - Preview Screen Integration & Error Flow', () {
    testWidgets('MaterialPreviewScreen triggers ApiService, shows loading dialog, and navigates to AIAnalysisScreen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final completer = Completer<http.Response>();
      final mockClient = MockClient((request) => completer.future);

      final mockApiService = ApiService(
        baseUrl: 'http://127.0.0.1:8001',
        client: mockClient,
      );

      final studyMaterial = StudyMaterial(
        title: 'Binary Search',
        sourceType: 'Typed Text',
        rawText: 'Binary Search is a search algorithm that finds the position of a target value within a sorted array.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MaterialPreviewScreen(
            material: studyMaterial,
            apiService: mockApiService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Material Preview'), findsOneWidget);
      expect(find.text('Analyze Material'), findsOneWidget);

      // Tap Analyze Material
      await tester.tap(find.text('Analyze Material'));
      await tester.pump(); // Start async action and render dialog

      // Verify loading state dialog is present
      expect(find.text('Analyzing your material...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete async response
      completer.complete(
        http.Response(
          jsonEncode(sampleBinarySearchJson),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );

      // Settle async HTTP response and navigation
      await tester.pumpAndSettle();

      // Verify navigated to AIAnalysisScreen
      expect(find.text('AI Pedagogical Analysis'), findsOneWidget);
      expect(find.text('BEST WAY TO LEARN THIS'), findsOneWidget);
      expect(find.text('Workflow Sequence'), findsOneWidget);
    });

    testWidgets('MaterialPreviewScreen handles API error with Error Dialog and Try Again button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      int callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          // Fail first call
          return http.Response(
            jsonEncode({'detail': 'Backend service temporarily unavailable.'}),
            503,
            headers: {'content-type': 'application/json'},
          );
        } else {
          // Succeed second call
          return http.Response(
            jsonEncode(sampleBinarySearchJson),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
      });

      final mockApiService = ApiService(
        baseUrl: 'http://127.0.0.1:8001',
        client: mockClient,
      );

      final studyMaterial = StudyMaterial(
        title: 'Binary Search',
        sourceType: 'Typed Text',
        rawText: 'Binary Search study notes...',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MaterialPreviewScreen(
            material: studyMaterial,
            apiService: mockApiService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Analyze Material
      await tester.tap(find.text('Analyze Material'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify Error Dialog is shown
      expect(find.text('Analysis Error'), findsOneWidget);
      expect(find.text('Backend service temporarily unavailable.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // Tap "Try Again"
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify second call succeeded and navigated to AIAnalysisScreen
      expect(callCount, 2);
      expect(find.text('AI Pedagogical Analysis'), findsOneWidget);
      expect(find.text('BEST WAY TO LEARN THIS'), findsOneWidget);
    });

    testWidgets('Full User Journey: Home -> Topic Input -> Preview -> AI Analysis', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final completer = Completer<http.Response>();
      final mockClient = MockClient((request) => completer.future);
      final mockApiService = ApiService(
        baseUrl: 'http://127.0.0.1:8001',
        client: mockClient,
      );

      // We start at Home Screen
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MaterialPreviewScreen(
                            material: StudyMaterial(
                              title: 'Binary Search',
                              sourceType: 'Typed Text',
                              rawText: 'Binary Search is a search algorithm...',
                            ),
                            apiService: mockApiService,
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Binary Search Preview'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap to open preview
      await tester.tap(find.text('Open Binary Search Preview'));
      await tester.pumpAndSettle();

      expect(find.text('Material Preview'), findsOneWidget);
      expect(find.text('Binary Search'), findsWidgets);

      // Tap Analyze Material
      await tester.tap(find.text('Analyze Material'));
      await tester.pump();

      expect(find.text('Analyzing your material...'), findsOneWidget);

      completer.complete(
        http.Response(
          jsonEncode(sampleBinarySearchJson),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );
      await tester.pumpAndSettle();

      // Verify on AI Analysis Screen
      expect(find.text('AI Pedagogical Analysis'), findsOneWidget);
      expect(find.text('BEST WAY TO LEARN THIS'), findsOneWidget);
      expect(find.text('Workflow Sequence'), findsOneWidget);
      expect(find.text('Divide and Conquer'), findsOneWidget);
      expect(find.text('Recommended Prerequisites'), findsOneWidget);

      // Tap "Start Interactive Learning"
      final startButton = find.text('Start Interactive Learning');
      await tester.ensureVisible(startButton);
      await tester.pumpAndSettle();
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // Verify on Smart Explain Screen
      expect(find.text('Smart Explain Studio'), findsOneWidget);
      expect(find.text('Binary Search'), findsWidgets);
      expect(find.text("Let's understand it visually."), findsOneWidget);
      expect(find.text('Target: 60'), findsWidgets);
      expect(find.text('40 = MIDDLE'), findsOneWidget);
    });
  });

  group('LearnX STREAM - Simplified Student-Friendly Smart Explain Tests', () {
    testWidgets('SimpleBinarySearchView executes 3-step rich visual experience with cards, pointers, and reduction flow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SimpleBinarySearchView(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Target Badge and Step 1 of 3
      expect(find.text('Target: 60'), findsWidgets);
      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text('STEP 1 — FIND THE MIDDLE'), findsOneWidget);

      // Verify Pointer Labels in Step 1: LOW, MID, HIGH
      expect(find.text('LOW'), findsOneWidget);
      expect(find.text('MID'), findsOneWidget);
      expect(find.text('HIGH'), findsOneWidget);
      expect(find.text('40 = MIDDLE'), findsOneWidget);

      // Verify all 7 numbers are displayed in the clean array
      for (final num in [10, 20, 30, 40, 50, 60, 70]) {
        expect(find.text('$num'), findsWidgets);
      }

      // Verify Step 1: Visual comparison and animated search right direction
      expect(find.text('Target 60'), findsWidgets);
      expect(find.text('Middle 40'), findsWidgets);
      expect(find.text('60 > 40'), findsOneWidget);
      expect(find.text('Search RIGHT HALF →'), findsOneWidget);

      // Step 1 -> Next -> Step 2
      final nextBtn = find.text('Next');
      expect(nextBtn, findsOneWidget);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.text('STEP 2 — CHECK THE NEW MIDDLE'), findsOneWidget);
      expect(find.text('LOW'), findsOneWidget);
      expect(find.text('MID'), findsOneWidget);
      expect(find.text('HIGH'), findsOneWidget);
      expect(find.text('60 = MIDDLE'), findsOneWidget);
      expect(find.text('Middle 60'), findsWidgets);
      expect(find.text('✓ TARGET FOUND'), findsOneWidget);

      // Step 2 -> Next -> Step 3 ("UNDERSTAND THE IDEA")
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('STEP 3 — UNDERSTAND THE IDEA'), findsOneWidget);
      expect(find.text('Binary Search'), findsWidgets);
      expect(find.text('[ 7 elements ]'), findsOneWidget);
      expect(find.text('[ 3 elements ]'), findsOneWidget);
      expect(find.text('[ 1 element ]'), findsOneWidget);
      expect(find.text('[ FOUND ]'), findsOneWidget);
      expect(
        find.text('Each comparison eliminates about half of the remaining search area.'),
        findsOneWidget,
      );

      // Verify "Previous" button returns to Step 2
      final prevBtn = find.text('Previous');
      expect(prevBtn, findsOneWidget);
      await tester.tap(prevBtn);
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.text('60 = MIDDLE'), findsOneWidget);
      expect(find.text('✓ TARGET FOUND'), findsOneWidget);

      // Verify "Restart" button returns to Step 1
      final restartBtn = find.text('Restart');
      expect(restartBtn, findsOneWidget);
      await tester.tap(restartBtn);
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text('40 = MIDDLE'), findsOneWidget);
      expect(find.text('Search RIGHT HALF →'), findsOneWidget);
    });

    testWidgets('BinarySearchVisualizer dynamically computes and executes steps for Target 20', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BinarySearchVisualizer(initialTarget: 20),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: mid = 40, 20 < 40 -> Search LEFT half
      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text('40 = MIDDLE'), findsOneWidget);
      expect(find.text('20 < 40'), findsOneWidget);
      expect(find.textContaining('Search LEFT HALF'), findsOneWidget);

      // Next -> Step 2: mid = 20, 20 = 20
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.text('20 = MIDDLE'), findsOneWidget);
      expect(find.text('✓ TARGET FOUND'), findsOneWidget);

      // Next -> Step 3: UNDERSTAND THE IDEA
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('STEP 3 — UNDERSTAND THE IDEA'), findsOneWidget);
    });

    testWidgets('BinarySearchVisualizer dynamically computes and executes steps for Target 50', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BinarySearchVisualizer(initialTarget: 50),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: mid = 40, 50 > 40 -> Right
      expect(find.text('Step 1 of 4'), findsOneWidget);
      expect(find.text('40 = MIDDLE'), findsOneWidget);
      expect(find.text('50 > 40'), findsOneWidget);
      expect(find.textContaining('Search RIGHT HALF'), findsOneWidget);

      // Next -> Step 2: mid = 60, 50 < 60 -> Left
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 4'), findsOneWidget);
      expect(find.text('60 = MIDDLE'), findsOneWidget);
      expect(find.text('50 < 60'), findsOneWidget);
      expect(find.textContaining('Search LEFT HALF'), findsOneWidget);

      // Next -> Step 3: mid = 50, 50 = 50 -> Found
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 3 of 4'), findsOneWidget);
      expect(find.text('50 = MIDDLE'), findsOneWidget);
      expect(find.text('✓ TARGET FOUND'), findsOneWidget);

      // Next -> Step 4: Success state / Idea state
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 4 of 4'), findsOneWidget);
      expect(find.text('STEP 3 — UNDERSTAND THE IDEA'), findsOneWidget);
    });

    testWidgets('BinarySearchVisualizer dynamically computes and executes steps for Target 70', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BinarySearchVisualizer(initialTarget: 70),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: mid = 40, 70 > 40 -> Right
      expect(find.text('Step 1 of 4'), findsOneWidget);
      expect(find.text('40 = MIDDLE'), findsOneWidget);
      expect(find.text('70 > 40'), findsOneWidget);

      // Step 2: mid = 60, 70 > 60 -> Right
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 4'), findsOneWidget);
      expect(find.text('60 = MIDDLE'), findsOneWidget);
      expect(find.text('70 > 60'), findsOneWidget);

      // Step 3: mid = 70, 70 = 70 -> Found
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 3 of 4'), findsOneWidget);
      expect(find.text('70 = MIDDLE'), findsOneWidget);
      expect(find.text('✓ TARGET FOUND'), findsOneWidget);

      // Step 4: Idea state
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 4 of 4'), findsOneWidget);
      expect(find.text('STEP 3 — UNDERSTAND THE IDEA'), findsOneWidget);
    });

    testWidgets('BinarySearchVisualizer restart and previous controls test', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BinarySearchVisualizer(initialTarget: 60),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1 of 3
      expect(find.text('Target: 60'), findsWidgets);
      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text('60 > 40'), findsOneWidget);

      // Test Next -> Step 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Step 2 of 3'), findsOneWidget);

      // Test Restart button
      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();
      expect(find.text('Step 1 of 3'), findsOneWidget);
    });

    testWidgets('SmartExplainScreen renders clean header with "AI chose" badge and Try another way sheet', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final analysis = MaterialAnalysisResponse.fromJson(sampleBinarySearchJson);

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExplainScreen(
            analysis: analysis,
            originalMaterial: StudyMaterial(
              title: 'Binary Search',
              sourceType: 'Typed Text',
              rawText: 'Binary Search study notes...',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Studio Header & Subtitle
      expect(find.text('Smart Explain Studio'), findsOneWidget);
      expect(find.text('Binary Search'), findsWidgets);
      expect(find.text("Let's understand it visually."), findsOneWidget);
      expect(find.text('AI chose: Visual Explanation'), findsOneWidget);
      expect(find.text('Try another way'), findsOneWidget);

      // Open "Try another way" bottom sheet
      final tryAnotherWayBtn = find.text('Try another way');
      await tester.ensureVisible(tryAnotherWayBtn);
      await tester.tap(tryAnotherWayBtn);
      await tester.pumpAndSettle();

      expect(find.text('Explain Differently'), findsOneWidget);
      expect(find.text('Choose another way to understand Binary Search.'), findsOneWidget);
      expect(find.text('Visual Explanation'), findsWidgets);
      expect(find.text('Step-by-Step'), findsOneWidget);
      expect(find.text('Concept Map'), findsOneWidget);
      expect(find.text('Interactive Simulation'), findsOneWidget);
      expect(find.text('Guided Chat'), findsOneWidget);

      // Verify generic descriptions (no topic specific leaks)
      expect(find.text('Understand the concept through interactive visuals'), findsOneWidget);
      expect(find.text('Follow the concept one step at a time'), findsOneWidget);
      expect(find.text('See how the main ideas connect'), findsOneWidget);
      expect(find.text('Experiment with the concept and see what changes'), findsOneWidget);
      expect(find.text('Learn through a simple conversation'), findsOneWidget);

      // Switch to Concept Map Mode via bottom sheet
      await tester.tap(find.text('Concept Map'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ConceptMapVisualizer), findsOneWidget);
      expect(find.text('Showing: Concept Map'), findsOneWidget);
      // Verify topic-aware Concept Map for Binary Search
      expect(find.text('Sorted Array Invariant'), findsWidgets);
      expect(find.text('Middle Element (MID)'), findsWidgets);
      expect(find.text('Comparison Logic'), findsWidgets);

      // Open sheet and switch to Step-by-Step Mode
      await tester.tap(find.text('Try another way'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Step-by-Step'));
      await tester.pumpAndSettle();

      expect(find.byType(WorkflowVisualizer), findsOneWidget);
      expect(find.text('Showing: Step-by-Step'), findsOneWidget);
      // Verify topic-aware Step-by-Step for Binary Search
      expect(find.textContaining('Initialize Boundary Pointers'), findsWidgets);
      expect(find.textContaining('Calculate Middle Element'), findsWidgets);

      // Open sheet and switch to Guided Chat Mode
      await tester.tap(find.text('Try another way'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Guided Chat'));
      await tester.pumpAndSettle();

      expect(find.byType(GuidedChatVisualizer), findsOneWidget);
      expect(find.text('Showing: Guided Chat'), findsOneWidget);
      // Verify topic-aware Guided Chat for Binary Search
      expect(find.textContaining('Why must the array be sorted?'), findsOneWidget);
    });
  });

  group('LearnX STREAM - Topic / Text Input Flow Tests', () {
    testWidgets('TopicInputView succeeds with topic only and empty notes', (WidgetTester tester) async {
      StudyMaterial? submittedMaterial;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TopicInputView(
                initialTopic: '',
                initialMaterial: '',
                onMaterialSubmitted: (mat) {
                  submittedMaterial = mat;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter Topic Name only
      final topicField = find.widgetWithText(TextField, 'e.g. Binary Search');
      await tester.enterText(topicField, 'Binary Search');
      await tester.pumpAndSettle();

      // Notes field is left empty. Tap Continue.
      final continueBtn = find.text('Continue');
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // Verify no error is displayed and material was successfully created
      expect(find.text('Please enter study material notes'), findsNothing);
      expect(find.text('Topic / Concept Name is required'), findsNothing);
      expect(submittedMaterial, isNotNull);
      expect(submittedMaterial!.title, 'Binary Search');
      expect(submittedMaterial!.rawText, 'Binary Search');
    });

    testWidgets('TopicInputView uses both topic and notes when both are entered', (WidgetTester tester) async {
      StudyMaterial? submittedMaterial;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TopicInputView(
                initialTopic: '',
                initialMaterial: '',
                onMaterialSubmitted: (mat) {
                  submittedMaterial = mat;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter topic and notes
      final topicField = find.widgetWithText(TextField, 'e.g. Binary Search');
      await tester.enterText(topicField, 'Binary Search');
      final notesField = find.widgetWithText(TextField, 'Paste your notes or leave blank to generate explanation from the topic name');
      await tester.enterText(notesField, 'Binary search divides the sorted array in halves.');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(submittedMaterial, isNotNull);
      expect(submittedMaterial!.title, 'Binary Search');
      expect(submittedMaterial!.rawText, 'Binary search divides the sorted array in halves.');
    });

    testWidgets('TopicInputView extracts topic from notes when topic field is empty', (WidgetTester tester) async {
      StudyMaterial? submittedMaterial;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TopicInputView(
                initialTopic: '',
                initialMaterial: '',
                onMaterialSubmitted: (mat) {
                  submittedMaterial = mat;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter only notes
      final notesField = find.widgetWithText(TextField, 'Paste your notes or leave blank to generate explanation from the topic name');
      await tester.enterText(notesField, 'Ohm\'s Law Fundamentals\nV = I * R');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(submittedMaterial, isNotNull);
      expect(submittedMaterial!.title, 'Ohm\'s Law Fundamentals');
      expect(submittedMaterial!.rawText, 'Ohm\'s Law Fundamentals\nV = I * R');
    });

    testWidgets('TopicInputView displays validation error only when both fields are empty', (WidgetTester tester) async {
      StudyMaterial? submittedMaterial;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TopicInputView(
                initialTopic: '',
                initialMaterial: '',
                onMaterialSubmitted: (mat) {
                  submittedMaterial = mat;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Continue with empty inputs
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(submittedMaterial, isNull);
      expect(find.text('Topic / Concept Name is required'), findsOneWidget);
    });

    testWidgets('Preset chip loads Binary Search and submits seamlessly', (WidgetTester tester) async {
      StudyMaterial? submittedMaterial;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TopicInputView(
                initialTopic: '',
                initialMaterial: '',
                onMaterialSubmitted: (mat) {
                  submittedMaterial = mat;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Binary Search preset chip
      final presetChip = find.widgetWithText(InkWell, 'Binary Search');
      await tester.tap(presetChip);
      await tester.pumpAndSettle();

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(submittedMaterial, isNotNull);
      expect(submittedMaterial!.title, 'Binary Search');
      expect(submittedMaterial!.rawText, contains('Binary Search is a search algorithm'));
    });

    testWidgets('Entering topic "binary search" with empty notes navigates to Preview and continues flow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Start directly on MaterialInputScreen with Topic method
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const MaterialInputScreen(
            initialMethod: InputMethod.topic,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify on Topic tab
      expect(find.text('Enter Topic & Notes'), findsOneWidget);

      // Type "binary search" in Topic / Concept Name field
      final topicField = find.widgetWithText(TextField, 'e.g. Binary Search');
      await tester.enterText(topicField, 'binary search');
      await tester.pumpAndSettle();

      // Study Material / Notes is EMPTY. Tap Continue.
      final continueBtn = find.text('Continue');
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // Confirm Continue navigated to Material Preview screen
      expect(find.text('Material Preview'), findsOneWidget);
      expect(find.text('binary search'), findsWidgets);
      expect(find.text('Direct Topic: binary search'), findsOneWidget);
      expect(find.text('Please enter study material notes'), findsNothing);
      expect(find.text('Analyze Material'), findsOneWidget);
    });
  });

  group('LearnX STREAM - Dynamic Visualization Factory & Renderer Tests', () {
    testWidgets('VisualizationRenderer renders interactive_visualization with dynamic data', (
      WidgetTester tester,
    ) async {
      final analysis = MaterialAnalysisResponse(
        topic: 'Binary Search',
        summary: 'Algorithm summary',
        concepts: [],
        difficulty: 'medium',
        prerequisites: [],
        recommendedRepresentation: const RecommendedRepresentation(type: 'workflow', reason: 'Search visual'),
        visualizationType: 'interactive_visualization',
        visualizationData: {
          'items': [5, 10, 15, 20, 25],
          'target': 20,
          'why_this_works': 'Binary search eliminates half the options per check.',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BinarySearchVisualizer), findsOneWidget);
      expect(find.text('Target: 20'), findsWidgets);
      expect(find.text('STEP 1 — FIND THE MIDDLE'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('VisualizationRenderer renders simulation with dynamic data and interactive sliders', (
      WidgetTester tester,
    ) async {
      final analysis = MaterialAnalysisResponse(
        topic: "Ohm's Law",
        summary: 'Physics law summary',
        concepts: [],
        difficulty: 'easy',
        prerequisites: [],
        recommendedRepresentation: const RecommendedRepresentation(type: 'simulation', reason: 'Circuit simulation'),
        visualizationType: 'simulation',
        visualizationData: {
          'formula': 'V = I × R',
          'primary_output': {'label': 'Current Flow', 'unit': 'mA'},
          'controls': [
            {'label': 'Voltage Push', 'unit': 'V', 'min': 1.0, 'max': 30.0, 'initial': 12.0},
            {'label': 'Circuit Resistance', 'unit': 'Ω', 'min': 10.0, 'max': 600.0, 'initial': 120.0},
          ],
          'why_this_works': 'Current increases proportionally with Voltage.',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SimulationVisualizer), findsOneWidget);
      expect(find.text("Ohm's Law"), findsOneWidget);
      expect(find.textContaining('V = I × R'), findsWidgets);
      expect(find.text('Current Flow: 100.0 mA'), findsOneWidget);
      expect(find.text('Voltage Push'), findsOneWidget);
      expect(find.text('Circuit Resistance'), findsOneWidget);
      expect(find.text('Current increases proportionally with Voltage.'), findsOneWidget);
    });

    testWidgets('VisualizationRenderer renders concept_map with dynamic nodes', (
      WidgetTester tester,
    ) async {
      final analysis = MaterialAnalysisResponse(
        topic: 'Object Oriented Programming',
        summary: 'OOP summary',
        concepts: [],
        difficulty: 'medium',
        prerequisites: [],
        recommendedRepresentation: const RecommendedRepresentation(type: 'concept_map', reason: 'OOP Map'),
        visualizationType: 'concept_map',
        visualizationData: {
          'root_node': {
            'title': 'OOP Core',
            'subtitle': 'Foundational programming paradigm',
          },
          'nodes': [
            {'id': 'class', 'title': 'Class Definition', 'subtitle': 'Blueprint for instances'},
            {'id': 'object', 'title': 'Living Object', 'subtitle': 'Concrete instantiation'},
            {'id': 'inheritance', 'title': 'Inheritance Hierarchy', 'subtitle': 'Extends base traits'},
          ],
          'why_this_works': 'Taxonomies make hierarchical abstractions intuitive.',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ConceptMapVisualizer), findsOneWidget);
      expect(find.text('OOP Core'), findsWidgets);
      expect(find.text('Class Definition'), findsWidgets);
      expect(find.text('Living Object'), findsWidgets);
      expect(find.text('Inheritance Hierarchy'), findsWidgets);
      expect(find.text('Taxonomies make hierarchical abstractions intuitive.'), findsOneWidget);
    });

    testWidgets('VisualizationRenderer renders step_by_step with sequential stages and progress control', (
      WidgetTester tester,
    ) async {
      final analysis = MaterialAnalysisResponse(
        topic: 'TCP Three-Way Handshake',
        summary: 'Networking summary',
        concepts: [],
        difficulty: 'medium',
        prerequisites: [],
        recommendedRepresentation: const RecommendedRepresentation(type: 'step_by_step', reason: 'Protocol stages'),
        visualizationType: 'step_by_step',
        visualizationData: {
          'stages': [
            {
              'stage_number': 1,
              'title': '1. SYN',
              'subtitle': 'Client → Server',
              'description': 'Client sends synchronise packet with Initial Sequence Number.',
            },
            {
              'stage_number': 2,
              'title': '2. SYN-ACK',
              'subtitle': 'Server → Client',
              'description': 'Server acknowledges and sends its own SYN packet.',
            },
            {
              'stage_number': 3,
              'title': '3. ACK',
              'subtitle': 'Client → Server',
              'description': 'Connection is established.',
            },
          ],
          'why_this_works': 'Breaking protocols into sequential checkpoints clarifies communication.',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StepByStepVisualizer), findsOneWidget);
      expect(find.text('1. SYN'), findsWidgets);
      expect(find.text('2. SYN-ACK'), findsWidgets);
      expect(find.text('3. ACK'), findsWidgets);
      expect(find.text('Breaking protocols into sequential checkpoints clarifies communication.'), findsOneWidget);

      // Tap Next Stage
      final nextStageBtn = find.text('Next');
      await tester.tap(nextStageBtn);
      await tester.pumpAndSettle();

      // Tap Next Stage again
      await tester.tap(nextStageBtn);
      await tester.pumpAndSettle();

      expect(find.text('Restart'), findsOneWidget);
    });

    testWidgets('VisualizationRenderer renders guided_chat with progressive conversational discovery', (
      WidgetTester tester,
    ) async {
      final analysis = MaterialAnalysisResponse(
        topic: 'Artificial Intelligence',
        summary: 'AI summary',
        concepts: [],
        difficulty: 'medium',
        prerequisites: [],
        recommendedRepresentation: const RecommendedRepresentation(type: 'guided_chat', reason: 'Socratic dialogue'),
        visualizationType: 'guided_chat',
        visualizationData: {
          'steps': [
            {
              'step_number': 1,
              'title': 'What is AI?',
              'explanation': 'Artificial Intelligence is software that mimics human cognitive abilities.',
              'question': 'Which of these is an example of AI?',
              'options': ['A standard calculator', 'A movie recommendation system', 'A paper notebook'],
              'correct_index': 1,
              'feedback': 'Correct! Recommendation systems analyze user behavior to predict choices.',
            },
          ],
          'why_this_works': 'Conversational inquiry promotes deeper conceptual understanding.',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GuidedChatVisualizer), findsOneWidget);
      expect(find.text('Step 1: What is AI?'), findsOneWidget);
      expect(find.text('Which of these is an example of AI?'), findsOneWidget);
      expect(find.text('A movie recommendation system'), findsOneWidget);
      expect(find.text('Conversational inquiry promotes deeper conceptual understanding.'), findsOneWidget);

      // Select option
      await tester.tap(find.text('A movie recommendation system'));
      await tester.pumpAndSettle();

      expect(find.text('Correct! Recommendation systems analyze user behavior to predict choices.'), findsOneWidget);
      expect(find.text('Revisit Flow'), findsOneWidget);
    });

    testWidgets('VisualizationRenderer gracefully falls back to guided_chat for unsupported types', (
      WidgetTester tester,
    ) async {
      final analysis = MaterialAnalysisResponse(
        topic: 'Quantum Computing',
        summary: 'Quantum computing overview',
        concepts: [],
        difficulty: 'hard',
        prerequisites: [],
        recommendedRepresentation: const RecommendedRepresentation(type: 'unknown_type', reason: 'Fallback'),
        visualizationType: 'unknown_future_type',
        visualizationData: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Gracefully rendered guided chat fallback without throwing an exception
      expect(find.byType(GuidedChatVisualizer), findsOneWidget);
      expect(find.textContaining('Quantum Computing'), findsWidgets);
    });
  });

  group('LearnX STREAM - Topic-Aware Visualization for All 5 Methods', () {
    // 1. Binary Search across all 5 methods
    testWidgets('Binary Search dynamically adapts across Visual Explanation, Step-by-Step, Concept Map, Simulation, Guided Chat', (
      WidgetTester tester,
    ) async {
      final analysis = MaterialAnalysisResponse.fromJson(sampleBinarySearchJson);

      // Method 1: Visual Explanation -> BinarySearchVisualizer
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis, overrideMode: 'interactive_visualization'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BinarySearchVisualizer), findsOneWidget);
      expect(find.text('Target: 60'), findsWidgets);

      // Method 2: Step-by-Step -> WorkflowVisualizer with Binary Search stages
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis, overrideMode: 'step_by_step'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WorkflowVisualizer), findsOneWidget);
      expect(find.textContaining('Initialize Boundary Pointers'), findsWidgets);
      expect(find.textContaining('Calculate Middle Element'), findsWidgets);

      // Method 3: Concept Map -> ConceptMapVisualizer with Binary Search nodes
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis, overrideMode: 'concept_map'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ConceptMapVisualizer), findsOneWidget);
      expect(find.text('Sorted Array Invariant'), findsWidgets);
      expect(find.text('Middle Element (MID)'), findsWidgets);
      expect(find.text('Comparison Logic'), findsWidgets);

      // Method 4: Interactive Simulation -> SimulationVisualizer
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis, overrideMode: 'simulation'),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(SimulationVisualizer), findsOneWidget);

      // Method 5: Guided Chat -> GuidedChatVisualizer with Binary Search socratic questions
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis, overrideMode: 'guided_chat'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GuidedChatVisualizer), findsOneWidget);
      expect(find.textContaining('Why must the array be sorted?'), findsOneWidget);
    });

    // 2. Ohm's Law across methods
    testWidgets("Ohm's Law dynamically adapts across Visual Explanation, Step-by-Step, Concept Map, Simulation, Guided Chat", (
      WidgetTester tester,
    ) async {
      final analysis = MaterialAnalysisResponse(
        topic: "Ohm's Law",
        summary: "Fundamental electrical law V = I * R",
        concepts: [],
        difficulty: "easy",
        prerequisites: [],
        recommendedRepresentation: const RecommendedRepresentation(type: "simulation", reason: "Circuit simulation"),
        visualizationType: "simulation",
        visualizationData: {},
      );

      // Visual Explanation / Simulation -> SimulationVisualizer
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis, overrideMode: 'interactive_visualization'),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(SimulationVisualizer), findsOneWidget);
      expect(find.text("Ohm's Law"), findsOneWidget);
      expect(find.textContaining('V = I × R'), findsWidgets);

      // Concept Map -> ConceptMapVisualizer with Ohm's Law nodes (Voltage, Current, Resistance)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis, overrideMode: 'concept_map'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ConceptMapVisualizer), findsOneWidget);
      expect(find.text('Voltage (V)'), findsWidgets);
      expect(find.text('Current (I)'), findsWidgets);
      expect(find.text('Resistance (R)'), findsWidgets);

      // Step-by-Step -> WorkflowVisualizer with Ohm's Law stages
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis, overrideMode: 'step_by_step'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WorkflowVisualizer), findsOneWidget);
      expect(find.textContaining('Apply Potential Difference'), findsWidgets);
      expect(find.textContaining('Encounter Resistance'), findsWidgets);

      // Guided Chat -> GuidedChatVisualizer with Ohm's Law inquiry
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis, overrideMode: 'guided_chat'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GuidedChatVisualizer), findsOneWidget);
      expect(find.textContaining('Voltage, Current, and Resistance'), findsOneWidget);
    });

    // 3. OOP across methods
    testWidgets("OOP dynamically adapts across Visual Explanation, Step-by-Step, Concept Map, Simulation, Guided Chat", (
      WidgetTester tester,
    ) async {
      final analysis = MaterialAnalysisResponse(
        topic: "Object-Oriented Programming (OOP)",
        summary: "Software architecture paradigm based on objects and classes.",
        concepts: [],
        difficulty: "medium",
        prerequisites: [],
        recommendedRepresentation: const RecommendedRepresentation(type: "concept_map", reason: "OOP Hierarchy"),
        visualizationType: "concept_map",
        visualizationData: {},
      );

      // Concept Map -> ConceptMapVisualizer with OOP nodes (Class, Object, Encapsulation, Inheritance)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis, overrideMode: 'concept_map'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ConceptMapVisualizer), findsOneWidget);
      expect(find.text('Class Definition'), findsWidgets);
      expect(find.text('Object Instance'), findsWidgets);
      expect(find.text('Encapsulation'), findsWidgets);
      expect(find.text('Inheritance'), findsWidgets);

      // Step-by-Step -> WorkflowVisualizer with OOP stages
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis, overrideMode: 'step_by_step'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WorkflowVisualizer), findsOneWidget);
      expect(find.textContaining('Declare Class Blueprint'), findsWidgets);
      expect(find.textContaining('Instantiate Living Object'), findsWidgets);

      // Guided Chat -> GuidedChatVisualizer with OOP inquiry
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis, overrideMode: 'guided_chat'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GuidedChatVisualizer), findsOneWidget);
      expect(find.textContaining('Class vs Object'), findsOneWidget);
    });

    // 4. TCP Three-Way Handshake across methods
    testWidgets("TCP Three-Way Handshake dynamically adapts across Visual Explanation, Step-by-Step, Concept Map, Simulation, Guided Chat", (
      WidgetTester tester,
    ) async {
      final analysis = MaterialAnalysisResponse(
        topic: "TCP Three-Way Handshake",
        summary: "Connection establishment in transport layer",
        concepts: [],
        difficulty: "medium",
        prerequisites: [],
        recommendedRepresentation: const RecommendedRepresentation(type: "step_by_step", reason: "Protocol packets"),
        visualizationType: "step_by_step",
        visualizationData: {},
      );

      // Step-by-Step -> WorkflowVisualizer with SYN, SYN-ACK, ACK
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis, overrideMode: 'step_by_step'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WorkflowVisualizer), findsOneWidget);
      expect(find.textContaining('SYN'), findsWidgets);
      expect(find.textContaining('SYN-ACK'), findsWidgets);
      expect(find.textContaining('ACK'), findsWidgets);

      // Concept Map -> ConceptMapVisualizer with TCP nodes
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis, overrideMode: 'concept_map'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ConceptMapVisualizer), findsOneWidget);
      expect(find.text('SYN (Synchronize)'), findsWidgets);
      expect(find.text('SYN-ACK Response'), findsWidgets);
      expect(find.text('ACK (Acknowledgment)'), findsWidgets);

      // Guided Chat -> GuidedChatVisualizer with TCP inquiry
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VisualizationRenderer(analysis: analysis, overrideMode: 'guided_chat'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GuidedChatVisualizer), findsOneWidget);
      expect(find.textContaining('Why Three Steps?'), findsOneWidget);
    });
  });

  group('LearnX STREAM - Complete Binary Search Visual Explanation Journey Tests', () {
    testWidgets('Full Visual Explanation Journey: Step 1 -> Next -> Step 2 -> Next -> Step 3 -> Restart -> Previous', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final analysis = MaterialAnalysisResponse.fromJson(sampleBinarySearchJson);

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExplainScreen(
            analysis: analysis,
            originalMaterial: StudyMaterial(
              title: 'Binary Search',
              sourceType: 'Typed Text',
              rawText: 'Binary Search study notes...',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Smart Explain Studio'), findsOneWidget);
      expect(find.text('AI chose: Visual Explanation'), findsOneWidget);
      expect(find.text('Binary Search'), findsWidgets);
      expect(find.text("Let's understand it visually."), findsOneWidget);

      // ==========================================
      // STEP 1 — FIND THE MIDDLE
      // ==========================================
      expect(find.text('STEP 1 — FIND THE MIDDLE'), findsOneWidget);
      expect(find.text('Target: 60'), findsWidgets);
      expect(find.text('Step 1 of 3'), findsOneWidget);

      // Array Elements: 10, 20, 30, 40, 50, 60, 70
      for (final num in [10, 20, 30, 40, 50, 60, 70]) {
        expect(find.text('$num'), findsWidgets);
      }

      // Clearly highlight: 40 = MIDDLE
      expect(find.text('40 = MIDDLE'), findsOneWidget);

      // Small pointer labels: LOW (10), MID (40), HIGH (70)
      expect(find.text('LOW'), findsOneWidget);
      expect(find.text('MID'), findsOneWidget);
      expect(find.text('HIGH'), findsOneWidget);

      // Comparison & Arrow: Target 60 > Middle 40, 60 > 40 -> Search RIGHT HALF →
      expect(find.text('Target 60'), findsWidgets);
      expect(find.text('Middle 40'), findsWidgets);
      expect(find.text('60 > 40'), findsOneWidget);
      expect(find.text('Search RIGHT HALF →'), findsOneWidget);

      // Controls: Previous disabled, Next enabled
      final prevBtn = find.widgetWithText(OutlinedButton, 'Previous');
      final nextBtn = find.widgetWithText(ElevatedButton, 'Next');
      final restartBtn = find.widgetWithText(OutlinedButton, 'Restart');

      expect(tester.widget<OutlinedButton>(prevBtn).onPressed, isNull);
      expect(tester.widget<ElevatedButton>(nextBtn).onPressed, isNotNull);
      expect(tester.widget<OutlinedButton>(restartBtn).onPressed, isNotNull);

      // ==========================================
      // STEP 2 — CHECK THE NEW MIDDLE (via NEXT)
      // ==========================================
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      expect(find.text('STEP 2 — CHECK THE NEW MIDDLE'), findsOneWidget);
      expect(find.text('Step 2 of 3'), findsOneWidget);

      // Highlight: 60 = MIDDLE
      expect(find.text('60 = MIDDLE'), findsOneWidget);

      // Pointers update to active window: LOW at 50, MID at 60, HIGH at 70
      expect(find.text('LOW'), findsOneWidget);
      expect(find.text('MID'), findsOneWidget);
      expect(find.text('HIGH'), findsOneWidget);

      // Comparison: Target 60 = Middle 60
      expect(find.text('Target 60'), findsWidgets);
      expect(find.text('Middle 60'), findsWidgets);

      // Success State: ✓ TARGET FOUND
      expect(find.text('✓ TARGET FOUND'), findsOneWidget);

      // Controls: Previous enabled, Next enabled
      expect(tester.widget<OutlinedButton>(prevBtn).onPressed, isNotNull);
      expect(tester.widget<ElevatedButton>(nextBtn).onPressed, isNotNull);

      // ==========================================
      // STEP 3 — UNDERSTAND THE IDEA (via NEXT)
      // ==========================================
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      expect(find.text('STEP 3 — UNDERSTAND THE IDEA'), findsOneWidget);
      expect(find.text('Step 3 of 3'), findsOneWidget);

      // Visual summary reduction diagram:
      // [ 7 elements ] -> [ 3 elements ] -> [ 1 element ] -> [ FOUND ]
      expect(find.text('[ 7 elements ]'), findsOneWidget);
      expect(find.text('[ 3 elements ]'), findsOneWidget);
      expect(find.text('[ 1 element ]'), findsOneWidget);
      expect(find.text('[ FOUND ]'), findsOneWidget);

      // Short explanation quote
      expect(
        find.text('Each comparison eliminates about half of the remaining search area.'),
        findsOneWidget,
      );

      // Controls: Previous enabled, Next disabled (on last step)
      expect(tester.widget<OutlinedButton>(prevBtn).onPressed, isNotNull);
      expect(tester.widget<ElevatedButton>(nextBtn).onPressed, isNull);

      // ==========================================
      // PREVIOUS NAVIGATION: Step 3 -> Step 2 -> Step 1
      // ==========================================
      await tester.tap(prevBtn);
      await tester.pumpAndSettle();
      expect(find.text('STEP 2 — CHECK THE NEW MIDDLE'), findsOneWidget);
      expect(find.text('60 = MIDDLE'), findsOneWidget);
      expect(find.text('✓ TARGET FOUND'), findsOneWidget);

      await tester.tap(prevBtn);
      await tester.pumpAndSettle();
      expect(find.text('STEP 1 — FIND THE MIDDLE'), findsOneWidget);
      expect(find.text('40 = MIDDLE'), findsOneWidget);
      expect(find.text('Search RIGHT HALF →'), findsOneWidget);

      // ==========================================
      // RESTART NAVIGATION: Step 1 -> Next -> Step 2 -> Restart -> Step 1
      // ==========================================
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();
      expect(find.text('STEP 2 — CHECK THE NEW MIDDLE'), findsOneWidget);

      await tester.tap(restartBtn);
      await tester.pumpAndSettle();
      expect(find.text('STEP 1 — FIND THE MIDDLE'), findsOneWidget);
      expect(find.text('40 = MIDDLE'), findsOneWidget);
    });

    testWidgets('Try another way preserves Binary Search topic across Concept Map, Step-by-Step, and Simulation', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final analysis = MaterialAnalysisResponse.fromJson(sampleBinarySearchJson);

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExplainScreen(
            analysis: analysis,
            originalMaterial: StudyMaterial(
              title: 'Binary Search',
              sourceType: 'Typed Text',
              rawText: 'Binary Search study notes...',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open "Try another way"
      await tester.tap(find.text('Try another way'));
      await tester.pumpAndSettle();

      // Switch to Concept Map
      await tester.tap(find.text('Concept Map'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Showing: Concept Map'), findsOneWidget);
      expect(find.text('Binary Search'), findsWidgets);
      expect(find.text('Sorted Array Invariant'), findsWidgets);

      // Switch to Step-by-Step
      await tester.tap(find.text('Try another way'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Step-by-Step'));
      await tester.pumpAndSettle();

      expect(find.text('Showing: Step-by-Step'), findsOneWidget);
      expect(find.text('Binary Search'), findsWidgets);
      expect(find.textContaining('Initialize Boundary Pointers'), findsWidgets);

      // Switch to Interactive Simulation
      await tester.tap(find.text('Try another way'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Interactive Simulation'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Showing: Interactive Simulation'), findsOneWidget);
      expect(find.text('Binary Search'), findsWidgets);
      expect(find.textContaining('Comparisons ≈ log2(N)'), findsWidgets);

      // Switch back to Visual Explanation
      await tester.tap(find.text('Try another way'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Visual Explanation'));
      await tester.pumpAndSettle();

      expect(find.text('AI chose: Visual Explanation'), findsOneWidget);
      expect(find.text('STEP 1 — FIND THE MIDDLE'), findsOneWidget);
    });
  });

  group('LearnX STREAM - Upgraded Learning Experience Tests (Visual + Educational Content)', () {
    testWidgets('SmartExplainScreen renders Concept Introduction, Key Idea, Real-World Connection, and Quick Check', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final analysis = MaterialAnalysisResponse(
        topic: 'Photosynthesis',
        summary: 'Photosynthesis summary',
        conceptOverview: 'Photosynthesis is the biological process that plants use to convert sunlight, water, and carbon dioxide into oxygen and glucose.',
        keyIdea: 'Photosynthesis converts light energy into durable chemical energy stored in glucose molecules.',
        realWorldConnection: "Powers Earth's food chains and produces the atmospheric oxygen required by aerobic life.",
        quickCheck: const QuickCheck(
          question: 'Why do plants need sunlight during photosynthesis?',
          options: [
            'To provide energy for sugar synthesis',
            'To directly absorb water from soil',
            'To produce mineral nutrients',
          ],
          correctAnswer: 'To provide energy for sugar synthesis',
          explanation: 'Sunlight supplies the photon energy to split water and drive the synthesis of glucose.',
        ),
        concepts: [],
        difficulty: 'medium',
        prerequisites: [],
        recommendedRepresentation: const RecommendedRepresentation(type: 'workflow', reason: 'Plant process'),
        visualizationType: 'workflow',
        visualizationData: {
          'stages': [
            {'stage_number': 1, 'title': 'Light Absorption', 'description': 'Chlorophyll absorbs sunlight.'},
          ],
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExplainScreen(
            analysis: analysis,
            originalMaterial: StudyMaterial(
              title: 'Photosynthesis',
              sourceType: 'Typed Text',
              rawText: 'Photosynthesis notes...',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Concept Introduction
      expect(find.text('What is Photosynthesis?'), findsOneWidget);
      expect(find.textContaining('Photosynthesis is the biological process'), findsOneWidget);
      expect(find.text("Let's understand it visually."), findsOneWidget);

      // 2. Key Idea
      expect(find.text('Key Idea'), findsOneWidget);
      expect(find.textContaining('converts light energy into durable chemical energy'), findsOneWidget);

      // 3. Real-World Connection
      expect(find.text('Where you see this'), findsOneWidget);
      expect(find.textContaining("Powers Earth's food chains"), findsOneWidget);

      // 4. Quick Check Card
      expect(find.text('Quick Check'), findsOneWidget);
      expect(find.text('Why do plants need sunlight during photosynthesis?'), findsOneWidget);
      expect(find.text('To provide energy for sugar synthesis'), findsOneWidget);
      expect(find.text('To directly absorb water from soil'), findsOneWidget);

      // Select correct option
      await tester.tap(find.text('To provide energy for sugar synthesis'));
      await tester.pumpAndSettle();

      expect(find.text('Correct!'), findsOneWidget);
      expect(find.textContaining('Sunlight supplies the photon energy'), findsOneWidget);

      // Select wrong option
      await tester.tap(find.text('To directly absorb water from soil'));
      await tester.pumpAndSettle();

      expect(find.text('Keep learning!'), findsOneWidget);
    });

    testWidgets('SmartExplainScreen renders educational content for Ohm\'s Law, SQL JOIN, and TCP Handshake', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final ohmsAnalysis = MaterialAnalysisResponse(
        topic: "Ohm's Law",
        summary: "Fundamental electrical relationship",
        conceptOverview: "Ohm's Law describes the relationship between voltage, current, and resistance in electrical circuits.",
        keyIdea: "Voltage pushes current forward, while Resistance opposes it: I = V / R.",
        realWorldConnection: "Used to select resistors and prevent circuit overloads.",
        quickCheck: const QuickCheck(
          question: "If voltage is doubled while resistance is constant, what happens to current?",
          options: ["Current doubles", "Current halves", "Current is unchanged"],
          correctAnswer: "Current doubles",
          explanation: "Since current is directly proportional to voltage, doubling voltage doubles current.",
        ),
        concepts: [],
        difficulty: "easy",
        prerequisites: [],
        recommendedRepresentation: const RecommendedRepresentation(type: "simulation", reason: "Circuit sim"),
        visualizationType: "simulation",
        visualizationData: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExplainScreen(
            analysis: ohmsAnalysis,
            originalMaterial: StudyMaterial(
              title: "Ohm's Law",
              sourceType: "Typed Text",
              rawText: "Ohm's law notes",
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text("What is Ohm's Law?"), findsOneWidget);
      expect(find.text("Key Idea"), findsOneWidget);
      expect(find.textContaining("I = V / R"), findsWidgets);
      expect(find.text("Where you see this"), findsOneWidget);
      expect(find.text("Quick Check"), findsOneWidget);
    });

    testWidgets('SmartExplainScreen renders flexible answer sections, Recursion, Water Cycle, and OOP Inheritance', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Test Recursion with flexible answer sections
      final recursionAnalysis = MaterialAnalysisResponse(
        topic: "Explain recursion",
        summary: "Self-referential function technique",
        answer: const AnswerPayload(
          title: "Recursion: Self-Referential Problem Solving",
          summary: "Recursion is a programming technique where a function calls itself with smaller inputs.",
          sections: [
            AnswerSection(
              heading: "The Self-Referential Engine",
              content: "Functions break large tasks into identical sub-tasks.",
            ),
            AnswerSection(
              heading: "The Base Case (The Stopping Anchor)",
              content: "Without a base case, recursion causes a Stack Overflow error.",
            ),
          ],
        ),
        visualExplanation: "Watch call frames stack and unwind backwards upon reaching the base case.",
        keyTakeaway: "Recursion breaks problems into sub-problems and always requires a base case to terminate.",
        realWorldConnection: "Used in file directory traversals and JSON parsers.",
        quickCheck: const QuickCheck(
          question: "What happens if a recursive function lacks a base case?",
          options: ["Stack Overflow error", "Infinite acceleration", "Program loops backwards"],
          correctAnswer: "Stack Overflow error",
          explanation: "Memory is exhausted by infinite stack frames.",
        ),
        concepts: [],
        difficulty: "medium",
        prerequisites: [],
        recommendedRepresentation: const RecommendedRepresentation(type: "step_by_step", reason: "Stack frames"),
        visualizationType: "step_by_step",
        visualizationData: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExplainScreen(
            analysis: recursionAnalysis,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("The Self-Referential Engine"), findsOneWidget);
      expect(find.text("The Base Case (The Stopping Anchor)"), findsOneWidget);
      expect(find.text("What You Are Seeing"), findsOneWidget);
      expect(find.text("Key Idea"), findsOneWidget);
      expect(find.text("Quick Check"), findsOneWidget);

      // Test Water Cycle with Process Workflow
      final waterCycleAnalysis = MaterialAnalysisResponse(
        topic: "What is the water cycle?",
        summary: "Earth's continuous hydrologic circulation",
        answer: const AnswerPayload(
          title: "The Hydrologic Water Cycle",
          summary: "Water continuously circulates between oceans, atmosphere, and land.",
          sections: [
            AnswerSection(
              heading: "Evaporation & Transpiration",
              content: "Sunlight warms oceans and causes liquid water to evaporate.",
            ),
            AnswerSection(
              heading: "Condensation & Precipitation",
              content: "Vapor cools into clouds and precipitates as rain or snow.",
            ),
          ],
        ),
        keyTakeaway: "The water cycle is an endless solar-powered closed loop.",
        realWorldConnection: "Sustains global climate and replenishes freshwater reserves.",
        quickCheck: const QuickCheck(
          question: "What powers Earth's water cycle?",
          options: ["Solar energy from the Sun", "Geothermal vents", "Lunar gravity"],
          correctAnswer: "Solar energy from the Sun",
          explanation: "The Sun heats surface water and drives evaporation.",
        ),
        concepts: [],
        difficulty: "easy",
        prerequisites: [],
        recommendedRepresentation: const RecommendedRepresentation(type: "workflow", reason: "Cycle loop"),
        visualizationType: "workflow",
        visualizationData: {
          'stages': [
            {'stage_number': 1, 'title': 'Evaporation', 'description': 'Water turns to vapor.'},
          ],
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SmartExplainScreen(
            analysis: waterCycleAnalysis,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Evaporation & Transpiration"), findsOneWidget);
      expect(find.text("Condensation & Precipitation"), findsOneWidget);
      expect(find.text("Key Idea"), findsOneWidget);
    });
  });
}


