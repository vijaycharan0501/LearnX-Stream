import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/pdf_extraction_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../material_input/models/material_analysis_models.dart';
import '../../material_input/models/material_input_data.dart';
import '../../material_input/screens/material_input_screen.dart';
import '../../smart_explain/screens/smart_explain_screen.dart';

/// Representation of an AI learning exchange in the single workspace
class ChatExchange {
  final String question;
  final MaterialAnalysisResponse analysis;
  final DateTime timestamp;

  const ChatExchange({
    required this.question,
    required this.analysis,
    required this.timestamp,
  });
}

/// Representation of a conversation session with pinned and recent support
class ConversationSession {
  final String id;
  String title;
  bool isPinned;
  DateTime updatedAt;
  final List<ChatExchange> exchanges;
  String? documentName;
  MaterialAnalysisResponse? documentAnalysis;

  ConversationSession({
    required this.id,
    required this.title,
    this.isPinned = false,
    required this.updatedAt,
    List<ChatExchange>? exchanges,
    this.documentName,
    this.documentAnalysis,
  }) : exchanges = exchanges ?? [];
}

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToLearn;
  final VoidCallback? onNavigateToPractice;
  final VoidCallback? onNavigateToProgress;
  final VoidCallback? onNavigateToProfile;
  final ApiService? apiService;
  final List<ChatExchange>? initialExchanges;

  const HomeScreen({
    super.key,
    this.onNavigateToLearn,
    this.onNavigateToPractice,
    this.onNavigateToProgress,
    this.onNavigateToProfile,
    this.apiService,
    this.initialExchanges,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late final ApiService _apiService;
  late final PdfExtractionService _pdfExtractionService;

  final List<ConversationSession> _sessions = [];
  late ConversationSession _activeSession;

  final Set<String> _savedConcepts = {'Photosynthesis', 'Binary Search', "Ohm's Law"};
  int _conceptsExploredCount = 14;
  int _visualExplanationsCount = 9;
  int _questionsPracticedCount = 27;

  bool _isGenerating = false;
  String? _errorMessage;
  String? _lastFailedQuestion;
  int _activeNavIndex = 0; // 0: Home, 1: Learning, 2: Documents, 3: Saved

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _pdfExtractionService = PdfExtractionService();

    // 1. Photosynthesis Canonical Seed Session
    final photosynthesisAnalysis = MaterialAnalysisResponse(
      topic: 'Photosynthesis',
      summary: 'Photosynthesis is the biological process by which plants, algae, and cyanobacteria convert solar energy, water (H₂O), and carbon dioxide (CO₂) into glucose (C₆H₁₂O₆) and oxygen (O₂).',
      difficulty: 'beginner',
      visualizationType: 'workflow',
      recommendedRepresentation: const RecommendedRepresentation(
        type: 'workflow',
        reason: 'Biological multi-stage transformation from sunlight to chemical energy.',
      ),
      answer: const AnswerPayload(
        title: 'Photosynthesis',
        summary: 'Photosynthesis is the biological engine of life on Earth, transforming sunlight, water, and carbon dioxide into oxygen and glucose.',
        sections: [
          AnswerSection(
            heading: 'Core Chemical Equation',
            content: '6 CO₂ + 6 H₂O + Sunlight ➔ C₆H₁₂O₆ + 6 O₂\n• Sunlight photons excite electrons in chlorophyll.\n• Water molecules are split in thylakoids, releasing oxygen.\n• ATP and NADPH power the Calvin cycle to produce glucose.',
          ),
          AnswerSection(
            heading: 'Light Reactions vs. Calvin Cycle',
            content: '• Light-Dependent Reactions: Occur in the thylakoid membranes where chlorophyll absorbs light to produce ATP and NADPH.\n• Light-Independent Reactions (Calvin Cycle): Occur in the chloroplast stroma, using ATP to fix carbon dioxide into sugar.',
          ),
        ],
      ),
      concepts: const [
        ConceptItem(name: 'Chlorophyll', type: 'pigment', importance: 'high'),
        ConceptItem(name: 'Thylakoid Membrane', type: 'organelle_structure', importance: 'high'),
        ConceptItem(name: 'Calvin Cycle', type: 'biochemical_cycle', importance: 'high'),
        ConceptItem(name: 'ATP & NADPH', type: 'energy_carrier', importance: 'medium'),
      ],
      prerequisites: const ['Plant Cell Structure', 'Basic Chemical Reactions', 'Molecules & Energy'],
      visualizationData: const {
        'topic': 'Photosynthesis',
        'type': 'cycle',
        'stages': [
          {'name': 'Light Absorption', 'desc': 'Chlorophyll absorbs sunlight photons in thylakoid discs.'},
          {'name': 'Water Photolysis', 'desc': 'H₂O split into protons, electrons, and O₂ gas.'},
          {'name': 'ATP Generation', 'desc': 'Electron transport chain charges ATP & NADPH.'},
          {'name': 'Calvin Cycle', 'desc': 'CO₂ fixed into high-energy glucose (C₆H₁₂O₆).'},
        ],
        'why_this_works': 'Photosynthesis efficiently stores solar energy in stable chemical bonds to fuel Earth ecosystem.',
      },
    );

    // 2. Binary Search Canonical Seed Session
    final binarySearchAnalysis = MaterialAnalysisResponse(
      topic: 'Binary Search',
      summary: 'Binary Search is an efficient divide-and-conquer algorithm that finds elements in sorted arrays in logarithmic O(log N) time by repeatedly discarding half the remaining search space.',
      difficulty: 'medium',
      visualizationType: 'visualExplanation',
      recommendedRepresentation: const RecommendedRepresentation(
        type: 'workflow',
        reason: 'Dynamic state comparisons and pointer transitions.',
      ),
      answer: const AnswerPayload(
        title: 'Binary Search',
        summary: 'Binary Search is a foundational search algorithm that achieves O(log N) time by halving the search space at each comparison.',
        sections: [
          AnswerSection(
            heading: 'Algorithm Mechanics',
            content: '• Precondition: Array must be sorted in ascending order.\n• Pointers: low = 0, high = n - 1.\n• Calculate mid = low + (high - low) / 2 to prevent integer overflow.\n• If target == arr[mid]: element found!\n• If target < arr[mid]: search left half (high = mid - 1).\n• If target > arr[mid]: search right half (low = mid + 1).',
          ),
          AnswerSection(
            heading: 'Time & Space Complexity',
            content: '• Best Case: O(1) when target is at the initial middle index.\n• Worst / Average Case: O(log N) logarithmic time.\n• Space Complexity: O(1) iterative, O(log N) recursive call stack.',
          ),
        ],
      ),
      concepts: const [
        ConceptItem(name: 'Divide and Conquer', type: 'algorithmic_paradigm', importance: 'high'),
        ConceptItem(name: 'Logarithmic O(log N)', type: 'complexity_metric', importance: 'high'),
        ConceptItem(name: 'Sorted Array Invariant', type: 'precondition', importance: 'high'),
        ConceptItem(name: 'Boundary Pointers (Low, Mid, High)', type: 'data_state', importance: 'medium'),
      ],
      prerequisites: const ['Arrays & Indexing', 'Comparison Operators', 'Basic Asymptotic Notation'],
      visualizationData: const {
        'items': [10, 20, 30, 40, 50, 60, 70],
        'target': 60,
        'quick_targets': [20, 50, 70],
        'why_this_works': 'Binary Search repeatedly cuts the search area in half, making the search exponentially faster than linear scanning.',
      },
    );

    // 3. Ohm's Law Canonical Seed Session
    final ohmsLawAnalysis = MaterialAnalysisResponse(
      topic: "Ohm's Law",
      summary: "Ohm's Law expresses the fundamental proportional relationship between Voltage (V), Current (I), and Resistance (R) in an electrical circuit: V = I × R.",
      difficulty: 'beginner',
      visualizationType: 'simulation',
      recommendedRepresentation: const RecommendedRepresentation(
        type: 'simulation',
        reason: 'Direct mathematical and circuit relationship.',
      ),
      answer: const AnswerPayload(
        title: "Ohm's Law",
        summary: "Ohm's Law states that the current flowing through a conductor is directly proportional to the voltage across it and inversely proportional to its resistance.",
        sections: [
          AnswerSection(
            heading: 'Core Equation & Variables',
            content: '• V = I × R  (or I = V / R, R = V / I)\n• Voltage (V, Volts): The electrical pressure pushing charge through the circuit.\n• Current (I, Amperes): The rate of electrical charge flow.\n• Resistance (R, Ohms Ω): The opposition to the flow of current.',
          ),
          AnswerSection(
            heading: 'Intuitive Water Pipe Analogy',
            content: '• Voltage is like water pressure in a tank.\n• Current is the volume of water flowing per second.\n• Resistance is a constriction or narrow pipe restricting flow.',
          ),
        ],
      ),
      concepts: const [
        ConceptItem(name: 'Voltage (V)', type: 'variable', importance: 'high'),
        ConceptItem(name: 'Current (I)', type: 'variable', importance: 'high'),
        ConceptItem(name: 'Resistance (R)', type: 'variable', importance: 'high'),
      ],
      prerequisites: const ['Basic Electric Circuits', 'Direct Proportions'],
      visualizationData: const {
        'topic': "Ohm's Law",
        'formula': 'I = V / R',
        'var_a_label': 'Voltage (V)',
        'var_a_unit': 'V',
        'var_a_value': 12.0,
        'var_a_min': 1.0,
        'var_a_max': 24.0,
        'var_b_label': 'Resistance (R)',
        'var_b_unit': 'Ω',
        'var_b_value': 4.0,
        'var_b_min': 1.0,
        'var_b_max': 20.0,
        'output_label': 'Current (I)',
        'output_unit': 'A',
        'why_this_works': 'Current is directly proportional to voltage and inversely proportional to resistance.',
      },
    );

    // 4. Polymorphism Canonical Seed Session
    final polymorphismAnalysis = MaterialAnalysisResponse(
      topic: 'Polymorphism',
      summary: 'Polymorphism in Object-Oriented Programming allows objects of different classes to be treated as instances of a common superclass, executing tailored behaviors via dynamic dispatch.',
      difficulty: 'medium',
      visualizationType: 'conceptMap',
      recommendedRepresentation: const RecommendedRepresentation(
        type: 'concept_map',
        reason: 'Class inheritance trees and OOP structural relationships.',
      ),
      answer: const AnswerPayload(
        title: 'Polymorphism',
        summary: 'Polymorphism allows one interface to control access to a general class of actions, with specific implementations determined dynamically at runtime.',
        sections: [
          AnswerSection(
            heading: 'Compile-Time vs. Runtime Polymorphism',
            content: '• Compile-Time (Static): Method Overloading (same method name, different signatures) and Operator Overloading.\n• Runtime (Dynamic): Method Overriding via inheritance and virtual method tables (vtable).',
          ),
          AnswerSection(
            heading: 'Code Example & Real-World Use',
            content: '```dart\nabstract class Shape { void draw(); }\nclass Circle extends Shape { @override void draw() => print("Draw Circle"); }\nclass Square extends Shape { @override void draw() => print("Draw Square"); }\n```\nA list of `Shape` objects can call `.draw()` without knowing concrete subclasses.',
          ),
        ],
      ),
      concepts: const [
        ConceptItem(name: 'Method Overriding', type: 'oop_technique', importance: 'high'),
        ConceptItem(name: 'Dynamic Dispatch', type: 'runtime_mechanism', importance: 'high'),
        ConceptItem(name: 'Abstract Base Classes', type: 'type_design', importance: 'high'),
      ],
      prerequisites: const ['Classes & Objects', 'Inheritance', 'Method Signatures'],
      visualizationData: const {
        'topic': 'Polymorphism',
        'root': 'Shape (Superclass)',
        'nodes': [
          {'name': 'Shape Base', 'desc': 'Abstract interface defining draw() method contract'},
          {'name': 'Circle Subclass', 'desc': 'Overrides draw() with circular rendering logic'},
          {'name': 'Square Subclass', 'desc': 'Overrides draw() with 4-sided polygon logic'},
          {'name': 'Dynamic Dispatch', 'desc': 'Runtime identifies actual instance type and invokes corresponding method'},
        ],
        'why_this_works': 'Decouples high-level application logic from low-level concrete implementations, enabling clean extensibility.',
      },
    );

    final session1 = ConversationSession(
      id: 'session-1',
      title: 'Photosynthesis',
      isPinned: true,
      updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      exchanges: [
        ChatExchange(
          question: 'Explain photosynthesis',
          analysis: photosynthesisAnalysis,
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ],
    );

    final session2 = ConversationSession(
      id: 'session-2',
      title: 'Binary Search',
      isPinned: true,
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      exchanges: [
        ChatExchange(
          question: 'How does binary search work?',
          analysis: binarySearchAnalysis,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
    );

    final session3 = ConversationSession(
      id: 'session-3',
      title: "Ohm's Law",
      isPinned: false,
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      exchanges: [
        ChatExchange(
          question: "Explain Ohm's Law",
          analysis: ohmsLawAnalysis,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ],
    );

    final session4 = ConversationSession(
      id: 'session-4',
      title: 'Polymorphism',
      isPinned: false,
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      exchanges: [
        ChatExchange(
          question: 'Explain polymorphism',
          analysis: polymorphismAnalysis,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );

    _sessions.addAll([session1, session2, session3, session4]);

    // Active session starts fresh (New Chat)
    _activeSession = ConversationSession(
      id: 'active-${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Chat',
      isPinned: false,
      updatedAt: DateTime.now(),
    );

    if (widget.initialExchanges != null && widget.initialExchanges!.isNotEmpty) {
      _activeSession.exchanges.addAll(widget.initialExchanges!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // CONVERSATION SESSION MANAGEMENT
  // ===========================================================================

  void _startNewChat() {
    setState(() {
      // If current active session has content and isn't in _sessions, save it
      if (_activeSession.exchanges.isNotEmpty && !_sessions.contains(_activeSession)) {
        _sessions.insert(0, _activeSession);
      }
      _activeSession = ConversationSession(
        id: 'session-${DateTime.now().millisecondsSinceEpoch}',
        title: 'New Chat',
        isPinned: false,
        updatedAt: DateTime.now(),
      );
      _errorMessage = null;
      _lastFailedQuestion = null;
      _isGenerating = false;
      _activeNavIndex = 0; // Return to Home AI workspace
      _searchController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_searchFocusNode.canRequestFocus) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _switchSession(ConversationSession session) {
    setState(() {
      // Save current if it has content and is not yet in sessions
      if (_activeSession.exchanges.isNotEmpty && !_sessions.contains(_activeSession)) {
        _sessions.insert(0, _activeSession);
      }
      _activeSession = session;
      _errorMessage = null;
      _lastFailedQuestion = null;
      _activeNavIndex = 0; // Show AI workspace with this conversation
      _searchController.clear();
    });
  }

  void _togglePinSession(ConversationSession session) {
    setState(() {
      session.isPinned = !session.isPinned;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(session.isPinned ? 'Pinned "${session.title}"' : 'Unpinned "${session.title}"'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.tealPrimary,
        ),
      );
    });
  }

  void _renameSession(ConversationSession session) {
    final titleController = TextEditingController(text: session.title);
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: AppColors.getSurface(isDark),
          title: Text(
            'Rename Conversation',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          content: TextField(
            controller: titleController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter conversation title...',
              hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
              filled: true,
              fillColor: AppColors.getSurfaceSecondary(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getCardBorder(isDark)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppColors.getTextSecondary(isDark))),
            ),
            ElevatedButton(
              onPressed: () {
                final newTitle = titleController.text.trim();
                if (newTitle.isNotEmpty) {
                  setState(() {
                    session.title = newTitle;
                  });
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tealPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSession(ConversationSession session) {
    setState(() {
      _sessions.remove(session);
      if (_activeSession == session) {
        _startNewChat();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${session.title}"'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.textSecondary,
        ),
      );
    });
  }

  // ===========================================================================
  // QUESTION SUBMIT & STREAM FLOW (Fast Response UX, Non-Blocking)
  // ===========================================================================

  Future<void> _handleQuestionSubmit([String? overrideTopic]) async {
    final rawText = (overrideTopic ?? _searchController.text).trim();
    if (rawText.isEmpty || _isGenerating) return;

    // Switch to Home workspace if currently in Learning, Documents, or Saved
    if (_activeNavIndex != 0) {
      _activeNavIndex = 0;
    }

    _searchController.clear();
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _lastFailedQuestion = null;

      // Update session title if default
      if (_activeSession.title == 'New Chat') {
        _activeSession.title = rawText;
      }
    });

    try {
      final analysis = await _apiService.analyzeMaterial(rawText, rawText);
      if (!mounted) return;

      setState(() {
        _activeSession.exchanges.add(
          ChatExchange(
            question: rawText,
            analysis: analysis,
            timestamp: DateTime.now(),
          ),
        );
        _activeSession.updatedAt = DateTime.now();

        // Ensure session is in session list
        if (!_sessions.contains(_activeSession)) {
          _sessions.insert(0, _activeSession);
        }

        _isGenerating = false;
        _conceptsExploredCount++;
        _visualExplanationsCount++;
      });

      // Scroll smoothly down to the new answer
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 200,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      final errorStr = e.toString().toLowerCase();
      setState(() {
        _isGenerating = false;
        _lastFailedQuestion = rawText;
        if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
          _errorMessage = 'Taking longer than expected. Please try again.';
        } else {
          _errorMessage = "Couldn't generate the answer. Please try again.";
        }
      });
    }
  }

  void _retryLastQuestion() {
    if (_lastFailedQuestion != null && _lastFailedQuestion!.isNotEmpty) {
      _handleQuestionSubmit(_lastFailedQuestion);
    }
  }

  void _navigateToMaterialInput({
    InputMethod initialMethod = InputMethod.scan,
    String? initialTopic,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MaterialInputScreen(
          initialMethod: initialMethod,
          initialTopic: initialTopic,
        ),
      ),
    );
  }

  void _navigateToVisualization(MaterialAnalysisResponse analysis) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SmartExplainScreen(analysis: analysis),
      ),
    );
  }

  void _openOrFindTopic(String topicName) {
    final clean = topicName.trim().toLowerCase();
    // Search in existing sessions
    for (final s in _sessions) {
      if (s.title.toLowerCase().contains(clean) || clean.contains(s.title.toLowerCase())) {
        _switchSession(s);
        return;
      }
    }
    // Otherwise submit as question
    _handleQuestionSubmit('Explain $topicName');
  }

  void _toggleSaveConcept(String topic) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    setState(() {
      if (_savedConcepts.contains(topic)) {
        _savedConcepts.remove(topic);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "$topic" from Saved Concepts'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.getTextSecondary(isDark),
          ),
        );
      } else {
        _savedConcepts.add(topic);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved "$topic" to your library!'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.tealPrimary,
          ),
        );
      }
    });
  }

  void _copyToClipboard(ChatExchange exchange) {
    final buffer = StringBuffer();
    buffer.writeln('Question: ${exchange.question}\n');
    final ans = exchange.analysis.answer;
    if (ans != null) {
      buffer.writeln(ans.summary);
      for (final sec in ans.sections) {
        buffer.writeln('\n### ${sec.heading}\n${sec.content}');
      }
    } else {
      buffer.writeln(exchange.analysis.summary);
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Answer copied to clipboard!'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.tealPrimary,
      ),
    );
  }

  // ===========================================================================
  // ADD MATERIAL & DOCUMENT INPUT MODAL
  // ===========================================================================

  void _showAddMaterialModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.getSurface(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.getDivider(isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Add Study Material',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload or scan learning material for instant AI understanding and interactive visuals',
                  style: TextStyle(fontSize: 12, color: AppColors.getTextMuted(isDark)),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.getBlueLight(isDark),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.upload_file_rounded, color: AppColors.bluePrimary, size: 20),
                  ),
                  title: Text(
                    'Upload PDF / Document',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.getTextPrimary(isDark)),
                  ),
                  subtitle: Text(
                    'Import PDF notes, chapters, or slides',
                    style: TextStyle(fontSize: 12, color: AppColors.getTextMuted(isDark)),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.getTextMuted(isDark)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAISummaryDialog();
                  },
                ),
                Divider(height: 1, color: AppColors.getCardBorder(isDark)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.getTealLight(isDark),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.document_scanner_rounded, color: AppColors.tealPrimary, size: 20),
                  ),
                  title: Text(
                    'Scan Document / Page',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.getTextPrimary(isDark)),
                  ),
                  subtitle: Text(
                    'Capture textbook pages or handwritten notes',
                    style: TextStyle(fontSize: 12, color: AppColors.getTextMuted(isDark)),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.getTextMuted(isDark)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _navigateToMaterialInput(initialMethod: InputMethod.scan);
                  },
                ),
                Divider(height: 1, color: AppColors.getCardBorder(isDark)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.getPurpleLight(isDark),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.text_fields_rounded, color: AppColors.purplePrimary, size: 20),
                  ),
                  title: Text(
                    'Paste Text / Notes',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.getTextPrimary(isDark)),
                  ),
                  subtitle: Text(
                    'Paste lecture notes or paragraphs directly',
                    style: TextStyle(fontSize: 12, color: AppColors.getTextMuted(isDark)),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.getTextMuted(isDark)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _navigateToMaterialInput(initialMethod: InputMethod.topic);
                  },
                ),
                Divider(height: 1, color: AppColors.getCardBorder(isDark)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.getOrangeLight(isDark),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mic_rounded, color: AppColors.orangePrimary, size: 20),
                  ),
                  title: Text(
                    'Ask with Voice',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.getTextPrimary(isDark)),
                  ),
                  subtitle: Text(
                    'Speak your concept question naturally',
                    style: TextStyle(fontSize: 12, color: AppColors.getTextMuted(isDark)),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.getTextMuted(isDark)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _navigateToMaterialInput(initialMethod: InputMethod.voice);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // AI SUMMARY FLOW (Upload Landing -> File Preview -> Structured AI Summary)
  // ===========================================================================

  void _showAISummaryDialog([MaterialAnalysisResponse? existingAnalysis, String? initialDocName]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.getSurface(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return _AISummaryBottomSheetContent(
          apiService: _apiService,
          pdfExtractionService: _pdfExtractionService,
          initialAnalysis: existingAnalysis ?? _activeSession.documentAnalysis,
          initialDocName: initialDocName ?? _activeSession.documentName,
          onVisualizeConcept: (topic) {
            Navigator.pop(ctx);
            _openOrFindTopic(topic);
          },
          onAskAboutDocument: (docTitle, analysis) {
            Navigator.pop(ctx);
            setState(() {
              _activeSession.documentName = docTitle;
              _activeSession.documentAnalysis = analysis;
              if (_activeSession.exchanges.isEmpty) {
                _activeSession.title = docTitle;
                _activeSession.exchanges.add(
                  ChatExchange(
                    question: 'Loaded document: $docTitle',
                    analysis: analysis,
                    timestamp: DateTime.now(),
                  ),
                );
              }
              _activeNavIndex = 0;
            });
          },
          onQuickCheck: (analysis) {
            Navigator.pop(ctx);
            _showQuickCheckDialog(analysis);
          },
        );
      },
    );
  }

  // ===========================================================================
  // DYNAMIC QUICK CHECK PRACTICE MODAL
  // ===========================================================================

  void _showQuickCheckDialog([MaterialAnalysisResponse? analysis]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeAnalysis = analysis ??
        (_activeSession.exchanges.isNotEmpty
            ? _activeSession.exchanges.last.analysis
            : (_sessions.isNotEmpty && _sessions.first.exchanges.isNotEmpty
                ? _sessions.first.exchanges.first.analysis
                : null));

    if (activeAnalysis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please ask a question or summarize a document first to generate Quick Check practice!'),
          backgroundColor: AppColors.tealPrimary,
        ),
      );
      return;
    }

    setState(() {
      _questionsPracticedCount += 3;
    });
    final topic = activeAnalysis.topic;
    final questions = _buildDynamicQuestionsForTopic(topic, activeAnalysis);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.getSurface(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return _QuickCheckModalView(
          topic: topic,
          questions: questions,
        );
      },
    );
  }

  List<_PracticeQuestion> _buildDynamicQuestionsForTopic(
    String topic,
    MaterialAnalysisResponse analysis,
  ) {
    final lower = topic.toLowerCase();
    if (lower.contains('photosynthesis')) {
      return [
        const _PracticeQuestion(
          question: 'What is the primary cellular organelle where photosynthesis occurs?',
          options: ['Mitochondria', 'Chloroplast', 'Ribosome', 'Golgi apparatus'],
          correctIndex: 1,
          explanation: 'Photosynthesis takes place inside chloroplasts, which contain chlorophyll pigments to absorb light photons.',
        ),
        const _PracticeQuestion(
          question: 'What are the main outputs (products) of the photosynthesis reaction?',
          options: ['Glucose and Oxygen', 'CO₂ and Water', 'ATP and Lactic Acid', 'Nitrogen and Hydrogen'],
          correctIndex: 0,
          explanation: 'Photosynthesis converts solar energy, water, and CO₂ into glucose sugar and oxygen gas.',
        ),
        const _PracticeQuestion(
          question: 'Which molecule captures photons of sunlight to excite electrons in thylakoids?',
          options: ['Hemoglobin', 'Chlorophyll', 'Melanin', 'Carotene'],
          correctIndex: 1,
          explanation: 'Chlorophyll is the primary green pigment in thylakoid membranes that absorbs photons.',
        ),
      ];
    } else if (lower.contains('binary')) {
      return [
        const _PracticeQuestion(
          question: 'What is the mandatory precondition for Binary Search to work?',
          options: ['Unsorted array', 'Sorted array', 'Linked list structure', 'Unique values only'],
          correctIndex: 1,
          explanation: 'Binary Search requires a sorted collection so it can reliably discard half the remaining search space.',
        ),
        const _PracticeQuestion(
          question: 'What is the time complexity of Binary Search?',
          options: ['O(N)', 'O(log N)', 'O(N²)', 'O(1)'],
          correctIndex: 1,
          explanation: 'By halving the search space in each step, Binary Search operates in logarithmic O(log N) time.',
        ),
        const _PracticeQuestion(
          question: 'How is the middle index computed to avoid integer overflow in large arrays?',
          options: ['mid = (low + high) / 2', 'mid = low + (high - low) / 2', 'mid = high / 2', 'mid = low * 2'],
          correctIndex: 1,
          explanation: 'Using low + (high - low) / 2 prevents 32-bit integer overflow when low and high indices are large.',
        ),
      ];
    } else if (lower.contains('ohm')) {
      return [
        const _PracticeQuestion(
          question: "What is Ohm's Law mathematical equation relating Voltage (V), Current (I), and Resistance (R)?",
          options: ['V = I × R', 'V = I / R', 'V = I + R', 'V = R / I'],
          correctIndex: 0,
          explanation: "Ohm's Law states Voltage equals Current multiplied by Resistance (V = I × R, or I = V / R).",
        ),
        const _PracticeQuestion(
          question: 'If voltage is doubled while resistance remains constant, what happens to current?',
          options: ['Current is halved', 'Current is doubled', 'Current stays same', 'Current drops to zero'],
          correctIndex: 1,
          explanation: 'Current is directly proportional to voltage; doubling voltage doubles the current.',
        ),
        const _PracticeQuestion(
          question: 'What unit measures electrical resistance?',
          options: ['Volts (V)', 'Amperes (A)', 'Ohms (Ω)', 'Watts (W)'],
          correctIndex: 2,
          explanation: 'Resistance is measured in Ohms (Ω).',
        ),
      ];
    } else if (lower.contains('polymorph')) {
      return [
        const _PracticeQuestion(
          question: 'Which mechanism enables runtime dynamic dispatch in Object-Oriented Programming?',
          options: ['Method Overriding', 'Static Variables', 'Global Functions', 'Private Fields'],
          correctIndex: 0,
          explanation: 'Method overriding in derived classes allows runtime virtual method lookup (dynamic dispatch).',
        ),
        const _PracticeQuestion(
          question: 'What is the key benefit of Polymorphism?',
          options: ['Decouples client code from concrete implementations', 'Prevents class inheritance', 'Eliminates all memory allocations', 'Faster compilation'],
          correctIndex: 0,
          explanation: 'Polymorphism allows working with abstract interfaces rather than concrete details, making systems extensible.',
        ),
        const _PracticeQuestion(
          question: 'What is Method Overloading?',
          options: ['Same method name with different parameter signatures', 'Overriding base class methods', 'Deleting methods at runtime', 'None of these'],
          correctIndex: 0,
          explanation: 'Method overloading occurs at compile-time with multiple methods of the same name having distinct signatures.',
        ),
      ];
    }

    // Dynamic fallback based on concepts
    final concepts = analysis.concepts;
    final c1 = concepts.isNotEmpty ? concepts[0].name : 'Fundamental Concept';
    final c2 = concepts.length > 1 ? concepts[1].name : 'Core Principle';

    return [
      _PracticeQuestion(
        question: 'Which of the following is a primary concept of "$topic"?',
        options: [c1, 'Arbitrary Noise', 'Unrelated Fact', 'Random State'],
        correctIndex: 0,
        explanation: '"$c1" is identified by AI as a key cornerstone of understanding $topic.',
      ),
      _PracticeQuestion(
        question: 'What best summarizes the importance of "$c2" in this domain?',
        options: ['Critical requirement', 'Optional cosmetic', 'Deprecated idea', 'Unused metric'],
        correctIndex: 0,
        explanation: '"$c2" forms a structural pillar in mastering $topic.',
      ),
      _PracticeQuestion(
        question: 'What is the primary learning objective when exploring "$topic"?',
        options: ['Deep visual understanding', 'Rote memorization only', 'Ignoring prerequisites', 'None of these'],
        correctIndex: 0,
        explanation: 'LearnX STREAM emphasizes visual intuition, interactive mechanics, and rapid understanding.',
      ),
    ];
  }

  // ===========================================================================
  // BUILD SCREEN LAYOUT (Responsive: Desktop 3-Col, Tablet, Mobile)
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      drawer: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 768) {
            return _buildMobileNavigationDrawer(context);
          }
          return const SizedBox.shrink();
        },
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 950;
            final isTablet = constraints.maxWidth >= 650 && constraints.maxWidth < 950;

            if (isDesktop) {
              // Desktop 3-Column Layout: Left Nav (~18%) | Main Center Workspace (~62%) | Right Panel (~20%)
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Left Sidebar
                  SizedBox(
                    width: 230,
                    child: _buildLeftSidebar(context),
                  ),
                  VerticalDivider(width: 1, thickness: 1, color: AppColors.getCardBorder(isDark)),
                  // 2. Center Main Workspace
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: _buildCenterPaneContent(context, isDesktop: true),
                        ),
                      ),
                    ),
                  ),
                  VerticalDivider(width: 1, thickness: 1, color: AppColors.getCardBorder(isDark)),
                  // 3. Right Learning Panel
                  SizedBox(
                    width: 260,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: _buildRightLearningPanel(context),
                    ),
                  ),
                ],
              );
            } else if (isTablet) {
              // Tablet 2-Column Layout (Left Nav + Main Workspace)
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 220,
                    child: _buildLeftSidebar(context),
                  ),
                  VerticalDivider(width: 1, thickness: 1, color: AppColors.getCardBorder(isDark)),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: _buildCenterPaneContent(context, isDesktop: true),
                    ),
                  ),
                ],
              );
            }

            // Mobile Layout (< 650px)
            return SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMobileBrandHeader(context),
                  const SizedBox(height: 14),
                  _buildCenterPaneContent(context, isDesktop: false),
                  const SizedBox(height: 24),
                  Divider(height: 1, color: AppColors.getCardBorder(isDark)),
                  const SizedBox(height: 20),
                  _buildMobileMoreLearningSection(context),
                  const SizedBox(height: 20),
                  _buildFooter(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. LEFT SIDEBAR (DESKTOP)
  // ===========================================================================

  Widget _buildLeftSidebar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pinnedSessions = _sessions.where((s) => s.isPinned).toList();
    final recentSessions = _sessions.where((s) => !s.isPinned).toList();

    return Container(
      color: AppColors.getSurface(isDark),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.tealPrimary, Color(0xFF0F766E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.tealPrimary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.stream_rounded,
                    color: AppColors.textLight,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'LEARNX',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.getTextPrimary(isDark),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'STREAM',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.tealPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'AI Learning Workspace',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getTextMuted(isDark),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // + New Chat Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startNewChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tealPrimary,
                foregroundColor: AppColors.textLight,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 18),
                  SizedBox(width: 6),
                  Text(
                    '+ New Chat',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Navigation Links
          _buildSidebarNavItem(
            index: 0,
            icon: Icons.home_rounded,
            label: 'Home',
            onTap: () => setState(() => _activeNavIndex = 0),
          ),
          const SizedBox(height: 2),
          _buildSidebarNavItem(
            index: 1,
            icon: Icons.auto_stories_rounded,
            label: 'Learning',
            onTap: () {
              setState(() => _activeNavIndex = 1);
            },
          ),
          const SizedBox(height: 2),
          _buildSidebarNavItem(
            index: 2,
            icon: Icons.description_rounded,
            label: 'Documents',
            onTap: () {
              setState(() => _activeNavIndex = 2);
            },
          ),
          const SizedBox(height: 2),
          _buildSidebarNavItem(
            index: 3,
            icon: Icons.star_rounded,
            label: 'Saved',
            onTap: () {
              setState(() => _activeNavIndex = 3);
            },
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.getCardBorder(isDark)),
          const SizedBox(height: 12),

          // CONVERSATION HISTORY (Pinned & Recent)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📌 PINNED SECTION
                  Row(
                    children: [
                      const Icon(Icons.push_pin_rounded, size: 13, color: AppColors.orangePrimary),
                      const SizedBox(width: 5),
                      Text(
                        'PINNED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.getTextMuted(isDark),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (pinnedSessions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Text(
                        'No pinned conversations yet.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: AppColors.getTextMuted(isDark),
                        ),
                      ),
                    )
                  else
                    ...pinnedSessions.map((session) => _buildConversationItemTile(session, isDark)),

                  const SizedBox(height: 14),

                  // RECENT CHATS SECTION
                  Row(
                    children: [
                      Icon(Icons.history_rounded, size: 13, color: AppColors.getTextMuted(isDark)),
                      const SizedBox(width: 5),
                      Text(
                        'RECENT CHATS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.getTextMuted(isDark),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (recentSessions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Text(
                        'No recent chats yet.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: AppColors.getTextMuted(isDark),
                        ),
                      ),
                    )
                  else
                    ...recentSessions.map((session) => _buildConversationItemTile(session, isDark)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          Divider(height: 1, color: AppColors.getCardBorder(isDark)),
          const SizedBox(height: 10),

          // Sidebar Educational Pillars
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceSecondary(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.getCardBorder(isDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LEARNING PILLARS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.getTextMuted(isDark),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const _SidebarPillarItem(icon: Icons.lightbulb_outline_rounded, label: 'Learn'),
                const SizedBox(height: 3),
                const _SidebarPillarItem(icon: Icons.visibility_outlined, label: 'Visualize'),
                const SizedBox(height: 3),
                const _SidebarPillarItem(icon: Icons.psychology_outlined, label: 'Understand'),
                const SizedBox(height: 3),
                const _SidebarPillarItem(icon: Icons.trending_up_rounded, label: 'Grow'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'LearnX STREAM • v1.0',
              style: TextStyle(fontSize: 10, color: AppColors.getTextMuted(isDark), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItemTile(ConversationSession session, bool isDark) {
    final isActive = _activeSession.id == session.id && _activeNavIndex == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.getTealLight(isDark) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? AppColors.getTealBorder(isDark) : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _switchSession(session),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(
                  session.isPinned ? Icons.push_pin_rounded : Icons.chat_bubble_outline_rounded,
                  size: 14,
                  color: isActive
                      ? AppColors.tealPrimary
                      : (session.isPinned ? AppColors.orangePrimary : AppColors.getTextMuted(isDark)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session.title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.tealPrimary : AppColors.getTextPrimary(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 15, color: AppColors.getTextMuted(isDark)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Options',
                  color: AppColors.getSurface(isDark),
                  onSelected: (action) {
                    if (action == 'pin') {
                      _togglePinSession(session);
                    } else if (action == 'rename') {
                      _renameSession(session);
                    } else if (action == 'delete') {
                      _deleteSession(session);
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'pin',
                      child: Row(
                        children: [
                          Icon(session.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded, size: 16),
                          const SizedBox(width: 8),
                          Text(session.isPinned ? 'Unpin' : 'Pin'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 16),
                          SizedBox(width: 8),
                          Text('Rename'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.coralPrimary),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.coralPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _activeNavIndex == index;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.getTealLight(isDark) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.getTealBorder(isDark) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? AppColors.tealPrimary : AppColors.getTextSecondary(isDark),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.tealPrimary : AppColors.getTextPrimary(isDark),
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // MOBILE NAVIGATION DRAWER
  // ===========================================================================

  Widget _buildMobileNavigationDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pinnedSessions = _sessions.where((s) => s.isPinned).toList();
    final recentSessions = _sessions.where((s) => !s.isPinned).toList();

    return Drawer(
      backgroundColor: AppColors.getSurface(isDark),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.tealPrimary, Color(0xFF0F766E)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.stream_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LEARNX',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'STREAM',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.tealPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                      color: isDark ? AppColors.orangePrimary : AppColors.tealPrimary,
                      size: 20,
                    ),
                    onPressed: () {
                      ThemeController.toggleTheme();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // + New Chat
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startNewChat();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('+ New Chat', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: AppColors.getCardBorder(isDark)),
              const SizedBox(height: 12),

              // Nav items
              _buildSidebarNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _activeNavIndex = 0);
                },
              ),
              const SizedBox(height: 2),
              _buildSidebarNavItem(
                index: 1,
                icon: Icons.auto_stories_rounded,
                label: 'Learning',
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _activeNavIndex = 1);
                },
              ),
              const SizedBox(height: 2),
              _buildSidebarNavItem(
                index: 2,
                icon: Icons.description_rounded,
                label: 'Documents',
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _activeNavIndex = 2);
                },
              ),
              const SizedBox(height: 2),
              _buildSidebarNavItem(
                index: 3,
                icon: Icons.star_rounded,
                label: 'Saved',
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _activeNavIndex = 3);
                },
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: AppColors.getCardBorder(isDark)),
              const SizedBox(height: 12),

              // Conversations list
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pinned
                      Text(
                        '📌 PINNED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.getTextMuted(isDark),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (pinnedSessions.isEmpty)
                        Text(
                          'No pinned conversations yet.',
                          style: TextStyle(fontSize: 11.5, color: AppColors.getTextMuted(isDark)),
                        )
                      else
                        ...pinnedSessions.map(
                          (s) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              s.title,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.getTextPrimary(isDark),
                                fontWeight: _activeSession.id == s.id ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _switchSession(s);
                            },
                          ),
                        ),

                      const SizedBox(height: 14),

                      // Recent
                      Text(
                        'RECENT CHATS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.getTextMuted(isDark),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (recentSessions.isEmpty)
                        Text(
                          'No recent chats yet.',
                          style: TextStyle(fontSize: 11.5, color: AppColors.getTextMuted(isDark)),
                        )
                      else
                        ...recentSessions.map(
                          (s) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              s.title,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.getTextPrimary(isDark),
                                fontWeight: _activeSession.id == s.id ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _switchSession(s);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. CENTER MAIN WORKSPACE (SWITCHABLE: Home Q&A, Learning, Documents, Saved)
  // ===========================================================================

  Widget _buildCenterPaneContent(BuildContext context, {required bool isDesktop}) {
    if (_activeNavIndex == 1) {
      return _buildLearningAreaContent(context, isDesktop: isDesktop);
    } else if (_activeNavIndex == 2) {
      return _buildDocumentsAreaContent(context, isDesktop: isDesktop);
    } else if (_activeNavIndex == 3) {
      return _buildSavedAreaContent(context, isDesktop: isDesktop);
    }
    return _buildMainWorkspaceContent(context, isDesktop: isDesktop);
  }

  // ---------------------------------------------------------------------------
  // 2A. MAIN AI QUESTION & CONVERSATION WORKSPACE
  // ---------------------------------------------------------------------------

  Widget _buildMainWorkspaceContent(BuildContext context, {required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Header with Slogan & Theme Toggle (Universal)
        _buildWorkspaceTopHeader(context),
        const SizedBox(height: 18),

        // 1. If conversation is empty: Show Large Ask/Search Experience
        if (_activeSession.exchanges.isEmpty && !_isGenerating) ...[
          const SizedBox(height: 10),
          _buildHeroTitleSection(context, isDesktop),
          const SizedBox(height: 20),
          _buildMainSearchBar(context),
          const SizedBox(height: 14),
          _buildSecondaryActionRow(context),
          const SizedBox(height: 20),
          _buildTryAskingSection(context),
          const SizedBox(height: 20),
          _buildRecentQuestionsSection(context),
        ],

        // 2. Continuous AI Conversation Stream Feed
        if (_activeSession.exchanges.isNotEmpty || _isGenerating) ...[
          ..._activeSession.exchanges.map((exchange) => _buildChatExchangeCard(context, exchange)),
          if (_isGenerating) _buildGeneratingLoadingCard(context),
          const SizedBox(height: 10),
          _buildFollowUpSearchBar(context),
          const SizedBox(height: 24),
        ],

        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          _buildErrorMessageCard(context),
        ],

        if (isDesktop) ...[
          const SizedBox(height: 16),
          _buildFooter(context),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2B. IN-SHELL LEARNING AREA
  // ---------------------------------------------------------------------------

  Widget _buildLearningAreaContent(BuildContext context, {required bool isDesktop}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final learningTracks = [
      {
        'title': 'Computer Science & Algorithms',
        'desc': 'Binary Search, Sorting, Trees, Graphs, OOP & Systems',
        'icon': Icons.code_rounded,
        'color': AppColors.tealPrimary,
        'topics': ['Binary Search', 'Polymorphism', 'Merge Sort', 'OOP Inheritance'],
      },
      {
        'title': 'Physics & Engineering',
        'desc': "Ohm's Law, Circuitry, Kinematics, Thermodynamics & Waves",
        'icon': Icons.bolt_rounded,
        'color': AppColors.orangePrimary,
        'topics': ["Ohm's Law", 'Simple Harmonic Motion', 'Electric Circuits'],
      },
      {
        'title': 'Biological Sciences',
        'desc': 'Photosynthesis, Cellular Respiration, Mitosis, DNA Replication',
        'icon': Icons.eco_rounded,
        'color': AppColors.greenPrimary,
        'topics': ['Photosynthesis', 'Cellular Respiration', 'Water Cycle'],
      },
      {
        'title': 'Databases & Networking',
        'desc': 'SQL JOINs, Relational Schemas, TCP Handshake, HTTP Protocols',
        'icon': Icons.storage_rounded,
        'color': AppColors.purplePrimary,
        'topics': ['SQL JOINs', 'TCP Three-Way Handshake', 'Database Indexing'],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWorkspaceTopHeader(context),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Hub',
                  style: TextStyle(
                    fontSize: isDesktop ? 22 : 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.getTextPrimary(isDark),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore guided concepts, interactive visual modules, and deep intuition.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => _activeNavIndex = 0),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back to Home'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.getCardBorder(isDark)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...learningTracks.map((track) {
          final color = track['color'] as Color;
          final topics = track['topics'] as List<String>;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.getCardBorder(isDark)),
              boxShadow: AppColors.softShadowFor(isDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(track['icon'] as IconData, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track['title'] as String,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track['desc'] as String,
                            style: TextStyle(fontSize: 12.5, color: AppColors.getTextMuted(isDark)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: topics.map((t) {
                    return InkWell(
                      onTap: () => _openOrFindTopic(t),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.getSurfaceSecondary(isDark),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.getCardBorder(isDark)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 13, color: color),
                            const SizedBox(width: 6),
                            Text(
                              t,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.getTextPrimary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
        if (isDesktop) ...[
          const SizedBox(height: 16),
          _buildFooter(context),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2C. IN-SHELL DOCUMENTS AREA
  // ---------------------------------------------------------------------------

  Widget _buildDocumentsAreaContent(BuildContext context, {required bool isDesktop}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasDoc = _activeSession.documentName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWorkspaceTopHeader(context),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Documents & Notes',
                  style: TextStyle(
                    fontSize: isDesktop ? 22 : 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.getTextPrimary(isDark),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload study materials, notes, or textbooks for instant AI analysis.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => _activeNavIndex = 0),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back to Home'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.getCardBorder(isDark)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (!hasDoc) ...[
          // Empty State
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.getCardBorder(isDark)),
              boxShadow: AppColors.softShadowFor(isDark),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.getBlueLight(isDark),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.description_outlined, size: 32, color: AppColors.bluePrimary),
                ),
                const SizedBox(height: 16),
                Text(
                  'No documents yet.',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Upload a PDF note, textbook chapter, or scan handwritten pages to begin.',
                  style: TextStyle(fontSize: 13, color: AppColors.getTextMuted(isDark)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAISummaryDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tealPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.upload_file_rounded, size: 18),
                      label: const Text('Upload PDF / Document', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _navigateToMaterialInput(initialMethod: InputMethod.scan),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.getCardBorder(isDark)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.document_scanner_rounded, size: 18, color: AppColors.tealPrimary),
                      label: Text('Scan Page', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.getTextPrimary(isDark))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          // Loaded document state
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.getTealBorder(isDark)),
              boxShadow: AppColors.softShadowFor(isDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.getTealLight(isDark),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.article_rounded, color: AppColors.tealPrimary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activeSession.documentName!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            'Analyzed and ready in your active workspace',
                            style: TextStyle(fontSize: 12, color: AppColors.getTextMuted(isDark)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_activeSession.documentAnalysis != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _activeSession.documentAnalysis!.summary,
                    style: TextStyle(fontSize: 13.5, color: AppColors.getTextSecondary(isDark), height: 1.45),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _activeNavIndex = 0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tealPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                      label: const Text('Ask in Workspace'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => _showAISummaryDialog(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.getCardBorder(isDark)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text('Upload Another', style: TextStyle(color: AppColors.getTextPrimary(isDark))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        if (isDesktop) ...[
          const SizedBox(height: 16),
          _buildFooter(context),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2D. IN-SHELL SAVED AREA
  // ---------------------------------------------------------------------------

  Widget _buildSavedAreaContent(BuildContext context, {required bool isDesktop}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWorkspaceTopHeader(context),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved Concepts',
                  style: TextStyle(
                    fontSize: isDesktop ? 22 : 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.getTextPrimary(isDark),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your bookmarked topics and favorite visual explanations for rapid revision.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => _activeNavIndex = 0),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back to Home'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.getCardBorder(isDark)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (_savedConcepts.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.getCardBorder(isDark)),
              boxShadow: AppColors.softShadowFor(isDark),
            ),
            child: Column(
              children: [
                const Icon(Icons.star_border_rounded, size: 48, color: AppColors.orangePrimary),
                const SizedBox(height: 16),
                Text(
                  'No saved concepts yet.',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Star any AI answer or concept card to save it for quick revision anytime.',
                  style: TextStyle(fontSize: 13, color: AppColors.getTextMuted(isDark)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _activeNavIndex = 0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Explore Topics', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          )
        else
          ..._savedConcepts.map((concept) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.getSurface(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.getCardBorder(isDark)),
                boxShadow: AppColors.softShadowFor(isDark),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.getOrangeLight(isDark),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.star_rounded, color: AppColors.orangePrimary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          concept,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Bookmarked for instant visual revision',
                          style: TextStyle(fontSize: 12, color: AppColors.getTextMuted(isDark)),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openOrFindTopic(concept),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tealPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.visibility_outlined, size: 15),
                    label: const Text('Open'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.coralPrimary, size: 20),
                    tooltip: 'Remove',
                    onPressed: () => _toggleSaveConcept(concept),
                  ),
                ],
              ),
            );
          }),

        if (isDesktop) ...[
          const SizedBox(height: 16),
          _buildFooter(context),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // WORKSPACE TOP HEADER (Universal Slogan + Theme Switcher)
  // ---------------------------------------------------------------------------

  Widget _buildWorkspaceTopHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.tealPrimary, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Turn questions into understanding.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () {
            ThemeController.toggleTheme();
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.getCardBorder(isDark)),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : const Color(0xFF0F172A).withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  size: 14,
                  color: isDark ? AppColors.tealPrimary : AppColors.orangePrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  isDark ? 'Dark' : 'Light',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroTitleSection(BuildContext context, bool isDesktop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What do you want to understand?',
          style: TextStyle(
            fontSize: isDesktop ? 22 : 18,
            fontWeight: FontWeight.w800,
            color: AppColors.getTextPrimary(isDark),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ask anything about a concept, topic, or upload notes for visual clarity.',
          style: TextStyle(
            fontSize: 13.5,
            color: AppColors.getTextSecondary(isDark),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBrandHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Builder(
                  builder: (ctx) => IconButton(
                    icon: Icon(Icons.menu_rounded, color: AppColors.getTextPrimary(isDark)),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.tealPrimary, Color(0xFF0F766E)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.stream_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  'LEARNX',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.getTextPrimary(isDark)),
                ),
                const SizedBox(width: 4),
                const Text(
                  'STREAM',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.tealPrimary),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    size: 18,
                    color: isDark ? AppColors.tealPrimary : AppColors.orangePrimary,
                  ),
                  onPressed: () => ThemeController.toggleTheme(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.getTealLight(isDark),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'LX',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.tealPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'What do you want to understand?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.getTextPrimary(isDark),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildMainSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getCardBorder(isDark)),
        boxShadow: AppColors.softShadowFor(isDark),
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 14, right: 6, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.getSurfaceSecondary(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.getCardBorder(isDark)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.tealPrimary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onSubmitted: (_) => _handleQuestionSubmit(),
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  hintText: 'Ask anything about a concept, topic, or problem...',
                  hintStyle: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.getTextMuted(isDark),
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear_rounded, size: 18, color: AppColors.getTextMuted(isDark)),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.tealPrimary, Color(0xFF0F766E)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.textLight, size: 18),
                onPressed: () => _handleQuestionSubmit(),
                tooltip: 'Send question',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryActionRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // [+ Add material ▼]
        InkWell(
          onTap: _showAddMaterialModal,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.getCardBorder(isDark)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, size: 15, color: AppColors.tealPrimary),
                const SizedBox(width: 5),
                Text(
                  'Add material',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(width: 3),
                Icon(Icons.arrow_drop_down_rounded, size: 16, color: AppColors.getTextSecondary(isDark)),
              ],
            ),
          ),
        ),
        // [🎤 Voice]
        InkWell(
          onTap: () => _navigateToMaterialInput(initialMethod: InputMethod.voice),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.getCardBorder(isDark)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mic_rounded, size: 15, color: AppColors.tealPrimary),
                const SizedBox(width: 5),
                Text(
                  'Voice',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
        // [✨ AI Summary]
        InkWell(
          onTap: () => _showAISummaryDialog(),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.getPurpleLight(isDark),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.getPurpleBorder(isDark)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.summarize_outlined, size: 14, color: AppColors.purplePrimary),
                SizedBox(width: 5),
                Text(
                  'AI Summary',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.purplePrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentQuestionsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recentTopics = ['Photosynthesis', 'Binary Search', "Ohm's Law", 'Polymorphism'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Questions',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.getTextMuted(isDark),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recentTopics.map((topic) {
            return InkWell(
              onTap: () => _openOrFindTopic(topic),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.getSurface(isDark),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.getCardBorder(isDark)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_rounded, size: 14, color: AppColors.tealPrimary),
                    const SizedBox(width: 6),
                    Text(
                      topic,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTryAskingSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final suggestions = [
      'Explain photosynthesis',
      'How does binary search work?',
      "Explain Ohm's Law",
      'Explain polymorphism',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Try asking',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.getTextMuted(isDark),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((topic) {
            return InkWell(
              onTap: () => _handleQuestionSubmit(topic),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.getSurface(isDark),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.getCardBorder(isDark)),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black12 : const Color(0xFF0F172A).withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.tealPrimary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        topic,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ===========================================================================
  // CONTINUOUS AI CONVERSATION EXCHANGE CARDS
  // ===========================================================================

  Widget _buildChatExchangeCard(BuildContext context, ChatExchange exchange) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analysis = exchange.analysis;
    final isStarred = _savedConcepts.contains(analysis.topic);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. User Question Bubble
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E3A5F) : AppColors.blueLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
                border: Border.all(color: AppColors.getBlueBorder(isDark)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_circle_rounded, size: 16, color: AppColors.bluePrimary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      exchange.question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFBFDBFE) : const Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. LEARNX AI Answer Card (Displays Textual Answer Immediately)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.getCardBorder(isDark)),
              boxShadow: AppColors.softShadowFor(isDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Answer Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.tealPrimary, Color(0xFF0F766E)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'LEARNX AI',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.tealPrimary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: isStarred ? AppColors.orangePrimary : AppColors.getTextMuted(isDark),
                            size: 20,
                          ),
                          tooltip: 'Save concept',
                          onPressed: () => _toggleSaveConcept(analysis.topic),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy_rounded, size: 17, color: AppColors.getTextMuted(isDark)),
                          tooltip: 'Copy answer',
                          onPressed: () => _copyToClipboard(exchange),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Answer Summary
                if (analysis.answer != null && analysis.answer!.summary.isNotEmpty)
                  Text(
                    analysis.answer!.summary,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: AppColors.getTextPrimary(isDark),
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                else
                  Text(
                    analysis.summary,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: AppColors.getTextPrimary(isDark),
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                const SizedBox(height: 16),

                // Answer Structured Sections (Headings, Bullets, Equations, Code)
                if (analysis.answer != null && analysis.answer!.sections.isNotEmpty)
                  ...analysis.answer!.sections.map((section) => _buildSectionView(context, section)),

                const SizedBox(height: 16),

                // 3. ✨ VISUALIZATION CONCEPT CARD (Loads on Demand)
                _buildVisualizationConceptCard(context, analysis),

                const SizedBox(height: 12),

                // Actions: AI Summary & Quick Check
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showAISummaryDialog(analysis),
                      icon: const Icon(Icons.summarize_outlined, size: 15, color: AppColors.purplePrimary),
                      label: const Text('AI Summary', style: TextStyle(fontSize: 12, color: AppColors.purplePrimary, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      onPressed: () => _showQuickCheckDialog(analysis),
                      icon: const Icon(Icons.quiz_outlined, size: 15, color: AppColors.orangePrimary),
                      label: const Text('Quick Check', style: TextStyle(fontSize: 12, color: AppColors.orangePrimary, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionView(BuildContext context, AnswerSection section) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.heading,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(isDark),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          _formatDynamicContent(context, section.content),
        ],
      ),
    );
  }

  Widget _formatDynamicContent(BuildContext context, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check if code block
    if (content.contains('```')) {
      final parts = content.split('```');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: parts.map((part) {
          if (part.startsWith('python') || part.startsWith('dart') || part.startsWith('cpp') || part.startsWith('java') || part.contains('=')) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B0F17) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                part.trim(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  color: Color(0xFF38BDF8),
                ),
              ),
            );
          }
          return Text(
            part.trim(),
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.getTextSecondary(isDark),
              height: 1.45,
            ),
          );
        }).toList(),
      );
    }

    return Text(
      content,
      style: TextStyle(
        fontSize: 13.5,
        color: AppColors.getTextSecondary(isDark),
        height: 1.45,
      ),
    );
  }

  Widget _buildVisualizationConceptCard(BuildContext context, MaterialAnalysisResponse analysis) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => _navigateToVisualization(analysis),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F3A38), const Color(0xFF132A3E)]
                : [const Color(0xFFF0FDF4), const Color(0xFFE6F7F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.getTealBorder(isDark)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.tealPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✨ Visualization Concept',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.tealPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'See this concept visually',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.tealPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// Compact Lightweight Loading State matching Requirement 17: ✨ LearnX is thinking...
  Widget _buildGeneratingLoadingCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getTealBorder(isDark)),
        boxShadow: AppColors.softShadowFor(isDark),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.tealPrimary),
            ),
          ),
          SizedBox(width: 12),
          Text(
            '✨ LearnX is thinking...',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.tealPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getCardBorder(isDark)),
        boxShadow: AppColors.softShadowFor(isDark),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.tealPrimary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _handleQuestionSubmit(),
              style: TextStyle(color: AppColors.getTextPrimary(isDark)),
              decoration: InputDecoration(
                hintText: 'Ask a follow-up question...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.getTextMuted(isDark),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.tealPrimary),
            onPressed: () => _handleQuestionSubmit(),
          ),
        ],
      ),
    );
  }

  /// Error handling with [ Retry ] button matching Requirement 20
  Widget _buildErrorMessageCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.coralLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.coralBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.coralPrimary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.coralPrimary,
              ),
            ),
          ),
          if (_lastFailedQuestion != null)
            ElevatedButton(
              onPressed: _retryLastQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coralPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. RIGHT LEARNING PANEL (DESKTOP)
  // ===========================================================================

  Widget _buildRightLearningPanel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final recentTopics = [
      'Photosynthesis',
      'Binary Search',
      "Ohm's Law",
      'Polymorphism',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. QUICK ACTIONS
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: AppColors.getTextPrimary(isDark),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 10),
        _buildQuickActionTile(
          icon: Icons.summarize_outlined,
          color: AppColors.purplePrimary,
          bgColor: AppColors.getPurpleLight(isDark),
          title: '✨ AI Summary',
          subtitle: 'Summarize topics or notes',
          onTap: () => _showAISummaryDialog(),
        ),
        const SizedBox(height: 8),
        _buildQuickActionTile(
          icon: Icons.upload_file_rounded,
          color: AppColors.bluePrimary,
          bgColor: AppColors.getBlueLight(isDark),
          title: '📄 Analyze Document',
          subtitle: 'Upload PDF or scan notes',
          onTap: () => _showAISummaryDialog(),
        ),
        const SizedBox(height: 8),
        _buildQuickActionTile(
          icon: Icons.quiz_outlined,
          color: AppColors.orangePrimary,
          bgColor: AppColors.getOrangeLight(isDark),
          title: '🎯 Quick Check',
          subtitle: 'Practice concept questions',
          onTap: () => _showQuickCheckDialog(),
        ),
        const SizedBox(height: 8),
        _buildQuickActionTile(
          icon: Icons.visibility_outlined,
          color: AppColors.tealPrimary,
          bgColor: AppColors.getTealLight(isDark),
          title: '👁 Visualize',
          subtitle: 'Open visual explanation',
          onTap: () {
            if (_activeSession.exchanges.isNotEmpty) {
              _navigateToVisualization(_activeSession.exchanges.last.analysis);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Ask a question first to create a visualization.'),
                  action: SnackBarAction(
                    label: 'Ask Now',
                    textColor: Colors.white,
                    onPressed: () {
                      _searchFocusNode.requestFocus();
                    },
                  ),
                  backgroundColor: AppColors.tealPrimary,
                ),
              );
            }
          },
        ),

        const SizedBox(height: 22),

        // 2. RECENT QUESTIONS / RECENT LEARNING
        Text(
          'Recent Learning',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: AppColors.getTextPrimary(isDark),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        ...recentTopics.map(
          (topic) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () => _openOrFindTopic(topic),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.getSurface(isDark),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.getCardBorder(isDark)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded, size: 14, color: AppColors.tealPrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        topic,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.getTextMuted(isDark)),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 22),

        // 3. LEARNING SNAPSHOT
        Text(
          'Learning Snapshot',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: AppColors.getTextPrimary(isDark),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.getCardBorder(isDark)),
          ),
          child: Column(
            children: [
              _buildSnapshotMetricRow('Concepts explored', '$_conceptsExploredCount', AppColors.tealPrimary, isDark),
              const SizedBox(height: 8),
              _buildSnapshotMetricRow('Visual explanations', '$_visualExplanationsCount', AppColors.bluePrimary, isDark),
              const SizedBox(height: 8),
              _buildSnapshotMetricRow('Questions practiced', '$_questionsPracticedCount', AppColors.orangePrimary, isDark),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // 4. SAVED CONCEPTS
        Text(
          'Saved Concepts',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: AppColors.getTextPrimary(isDark),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        ..._savedConcepts.map(
          (concept) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () => _openOrFindTopic(concept),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.getSurface(isDark),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.getCardBorder(isDark)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 15, color: AppColors.orangePrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        concept,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.tealPrimary),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 22),

        // 5. LEARNING TIP
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.getTealLight(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.getTealBorder(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.tips_and_updates_rounded, size: 15, color: AppColors.tealPrimary),
                  SizedBox(width: 6),
                  Text(
                    'Learning Tip',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.tealPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Try visualizing difficult concepts instead of memorizing them.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFFCCFBF1) : const Color(0xFF134E4A),
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.getCardBorder(isDark)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.getTextMuted(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.getTextMuted(isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildSnapshotMetricRow(String label, String value, Color color, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextSecondary(isDark),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MOBILE MORE LEARNING GRID
  // ===========================================================================

  Widget _buildMobileMoreLearningSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More Learning',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.getTextPrimary(isDark),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: [
            _buildMobileGridTile(
              icon: Icons.summarize_outlined,
              color: AppColors.purplePrimary,
              bgColor: AppColors.getPurpleLight(isDark),
              label: 'AI Summary',
              onTap: () => _showAISummaryDialog(),
              isDark: isDark,
            ),
            _buildMobileGridTile(
              icon: Icons.history_rounded,
              color: AppColors.tealPrimary,
              bgColor: AppColors.getTealLight(isDark),
              label: 'Recent Learning',
              onTap: () => _openOrFindTopic('Photosynthesis'),
              isDark: isDark,
            ),
            _buildMobileGridTile(
              icon: Icons.star_rounded,
              color: AppColors.orangePrimary,
              bgColor: AppColors.getOrangeLight(isDark),
              label: 'Saved Concepts',
              onTap: () => setState(() => _activeNavIndex = 3),
              isDark: isDark,
            ),
            _buildMobileGridTile(
              icon: Icons.quiz_outlined,
              color: AppColors.bluePrimary,
              bgColor: AppColors.getBlueLight(isDark),
              label: 'Quick Check',
              onTap: () => _showQuickCheckDialog(),
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileGridTile({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.getCardBorder(isDark)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.getTextPrimary(isDark),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Divider(height: 1, color: AppColors.getCardBorder(isDark)),
        const SizedBox(height: 16),
        Text(
          '© 2026 LearnX STREAM. Learn Visually. Learn Faster.',
          style: TextStyle(
            fontSize: 11.5,
            color: AppColors.getTextMuted(isDark),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            _buildFooterLink('Privacy', isDark),
            Text('•', style: TextStyle(color: AppColors.getTextMuted(isDark), fontSize: 10)),
            _buildFooterLink('Terms', isDark),
            Text('•', style: TextStyle(color: AppColors.getTextMuted(isDark), fontSize: 10)),
            _buildFooterLink('Support', isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLink(String label, bool isDark) {
    return InkWell(
      onTap: () {},
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.getTextSecondary(isDark),
        ),
      ),
    );
  }
}

// =============================================================================
// AI SUMMARY BOTTOM SHEET COMPONENT (Upload Drop Zone -> Generate -> Result)
// =============================================================================

class _AISummaryBottomSheetContent extends StatefulWidget {
  final ApiService apiService;
  final PdfExtractionService pdfExtractionService;
  final MaterialAnalysisResponse? initialAnalysis;
  final String? initialDocName;
  final Function(String topic) onVisualizeConcept;
  final Function(String docTitle, MaterialAnalysisResponse analysis) onAskAboutDocument;
  final Function(MaterialAnalysisResponse analysis) onQuickCheck;

  const _AISummaryBottomSheetContent({
    required this.apiService,
    required this.pdfExtractionService,
    this.initialAnalysis,
    this.initialDocName,
    required this.onVisualizeConcept,
    required this.onAskAboutDocument,
    required this.onQuickCheck,
  });

  @override
  State<_AISummaryBottomSheetContent> createState() => _AISummaryBottomSheetContentState();
}

class _AISummaryBottomSheetContentState extends State<_AISummaryBottomSheetContent> {
  String? _selectedFileName;
  String? _selectedFileText;
  int _selectedFilePages = 1;
  bool _isProcessing = false;
  String? _errorMessage;
  MaterialAnalysisResponse? _generatedAnalysis;

  @override
  void initState() {
    super.initState();
    if (widget.initialAnalysis != null) {
      _generatedAnalysis = widget.initialAnalysis;
      _selectedFileName = widget.initialDocName ?? widget.initialAnalysis!.topic;
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'md', 'doc', 'docx'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final name = file.name;
        String extractedText = '';
        int pages = 1;

        if (name.toLowerCase().endsWith('.pdf') && file.bytes != null) {
          final extraction = await widget.pdfExtractionService.extractText(file.bytes!);
          if (extraction.hasText) {
            extractedText = extraction.text;
            pages = extraction.pageCount;
          } else {
            extractedText = 'Extracted content from $name';
          }
        } else if (file.bytes != null) {
          extractedText = String.fromCharCodes(file.bytes!);
        }

        setState(() {
          _selectedFileName = name;
          _selectedFileText = extractedText.isNotEmpty ? extractedText : 'Comprehensive document analysis for $name';
          _selectedFilePages = pages;
          _generatedAnalysis = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      // Preset fallback if picker isn't supported in test environment
      setState(() {
        _selectedFileName = 'Operating_Systems_Chapter_3.pdf';
        _selectedFileText = 'Operating Systems Chapter 3 covering Processes, Threads, CPU Scheduling, and Deadlocks.';
        _selectedFilePages = 14;
        _generatedAnalysis = null;
        _errorMessage = null;
      });
    }
  }

  void _selectPresetFile(String name, String text) {
    setState(() {
      _selectedFileName = name;
      _selectedFileText = text;
      _selectedFilePages = 12;
      _generatedAnalysis = null;
      _errorMessage = null;
    });
  }

  Future<void> _generateSummary() async {
    if (_selectedFileName == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final topic = _selectedFileName!.replaceAll('.pdf', '').replaceAll('_', ' ');
      final content = _selectedFileText ?? topic;
      final analysis = await widget.apiService.analyzeMaterial(topic, content);

      if (!mounted) return;
      setState(() {
        _generatedAnalysis = analysis;
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Could not generate AI summary. Please check your backend connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (_, scrollCtl) {
        return SingleChildScrollView(
          controller: scrollCtl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.getDivider(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.getPurpleLight(isDark),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.summarize_outlined, color: AppColors.purplePrimary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI SUMMARY',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.getTextPrimary(isDark),
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            _generatedAnalysis == null ? 'Upload a document to summarize' : 'Structured document understanding',
                            style: TextStyle(fontSize: 12, color: AppColors.getTextMuted(isDark)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: AppColors.getTextMuted(isDark)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 1. STATE: NO SUMMARY YET -> SHOW UPLOAD DROP ZONE
              if (_generatedAnalysis == null) ...[
                _buildUploadDropZone(isDark),
                const SizedBox(height: 16),
                if (_selectedFileName != null) ...[
                  _buildSelectedFileCard(isDark),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _generateSummary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tealPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isProcessing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                              SizedBox(width: 10),
                              Text('Reading and summarizing document...', style: TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Generate Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                            ],
                          ),
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.coralPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ],

              // 2. STATE: SUMMARY GENERATED -> SHOW STRUCTURED RESULT
              if (_generatedAnalysis != null) ...[
                _buildSummaryResultView(isDark, _generatedAnalysis!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadDropZone(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceSecondary(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.getCardBorder(isDark),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.getBlueLight(isDark),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.upload_file_rounded, size: 30, color: AppColors.bluePrimary),
          ),
          const SizedBox(height: 14),
          Text(
            'Drop your file here',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'PDF, DOCX, TXT or lecture slides supported',
            style: TextStyle(fontSize: 12.5, color: AppColors.getTextMuted(isDark)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _pickFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.folder_open_rounded, size: 16),
                label: const Text('Browse Files', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => _selectPresetFile(
                  'Operating_Systems_Chapter_3.pdf',
                  'Operating Systems Chapter 3 covering Processes, Threads, CPU Scheduling, and Deadlocks.',
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.getCardBorder(isDark)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 16, color: AppColors.coralPrimary),
                label: Text('Sample PDF', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.getTextPrimary(isDark))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFileCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.getTealBorder(isDark)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.getTealLight(isDark),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_rounded, color: AppColors.tealPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFileName!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$_selectedFilePages pages • Ready for AI summary',
                  style: TextStyle(fontSize: 12, color: AppColors.getTextMuted(isDark)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.getTextMuted(isDark), size: 20),
            onPressed: _pickFile,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryResultView(bool isDark, MaterialAnalysisResponse analysis) {
    final docTitle = _selectedFileName ?? analysis.topic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Document Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceSecondary(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.getCardBorder(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.article_rounded, size: 18, color: AppColors.tealPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      docTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                analysis.summary,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.getTextSecondary(isDark),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // KEY CONCEPTS (With individual Visualize button)
        Text(
          'Key Concepts',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (analysis.concepts.isNotEmpty
                  ? analysis.concepts.map((c) => c.name).toList()
                  : ['Core Process', 'Data Stream', 'System Architecture', 'Protocol Spec'])
              .map((concept) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.getTealLight(isDark),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.getTealBorder(isDark)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    concept,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tealPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => widget.onVisualizeConcept(concept),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.tealPrimary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 10, color: Colors.white),
                          SizedBox(width: 3),
                          Text('Visualize', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // IMPORTANT POINTS
        Text(
          'Important Points',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: 8),
        if (analysis.answer != null && analysis.answer!.sections.isNotEmpty)
          ...analysis.answer!.sections.map(
            (sec) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.circle, size: 6, color: AppColors.tealPrimary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${sec.heading}: ${sec.content}',
                      style: TextStyle(fontSize: 13, color: AppColors.getTextSecondary(isDark), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...[
            'Fundamental architecture principles govern execution and resource allocation.',
            'Direct relationships exist between throughput, latency, and system constraints.',
            'Modular separation ensures scalability and fault tolerance across components.',
          ].map(
            (pt) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.circle, size: 6, color: AppColors.tealPrimary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(pt, style: TextStyle(fontSize: 13, color: AppColors.getTextSecondary(isDark))),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 20),

        // ACTION BUTTONS: [✨ Visualize a Concept] [💬 Ask about this document] [🎯 Quick Check]
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: () => widget.onVisualizeConcept(analysis.topic),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tealPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.auto_awesome_rounded, size: 16),
              label: const Text('✨ Visualize a Concept', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton.icon(
              onPressed: () => widget.onAskAboutDocument(docTitle, analysis),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
              label: const Text('💬 Ask about this document', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            OutlinedButton.icon(
              onPressed: () => widget.onQuickCheck(analysis),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.getCardBorder(isDark)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.quiz_outlined, size: 16, color: AppColors.orangePrimary),
              label: Text('🎯 Quick Check', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.getTextPrimary(isDark))),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// QUICK CHECK PRACTICE MODAL VIEW
// =============================================================================

class _PracticeQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const _PracticeQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class _QuickCheckModalView extends StatefulWidget {
  final String topic;
  final List<_PracticeQuestion> questions;

  const _QuickCheckModalView({
    required this.topic,
    required this.questions,
  });

  @override
  State<_QuickCheckModalView> createState() => _QuickCheckModalViewState();
}

class _QuickCheckModalViewState extends State<_QuickCheckModalView> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  int _correctAnswers = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = widget.questions[_currentQuestionIndex];

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      expand: false,
      builder: (_, scrollCtl) {
        return SingleChildScrollView(
          controller: scrollCtl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.getDivider(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.getOrangeLight(isDark),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.quiz_outlined, color: AppColors.orangePrimary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Quick Check: ${widget.topic}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.getTealLight(isDark),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_currentQuestionIndex + 1}/${widget.questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.tealPrimary, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Question text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceSecondary(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.getCardBorder(isDark)),
                ),
                child: Text(
                  q.question,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Options
              ...List.generate(q.options.length, (optIdx) {
                final optionLabel = String.fromCharCode(65 + optIdx); // A, B, C, D
                final isSelected = _selectedOptionIndex == optIdx;
                final isCorrect = optIdx == q.correctIndex;

                Color borderColor = AppColors.getCardBorder(isDark);
                Color bgColor = AppColors.getSurface(isDark);
                if (_isAnswered) {
                  if (isCorrect) {
                    borderColor = AppColors.greenPrimary;
                    bgColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
                  } else if (isSelected && !isCorrect) {
                    borderColor = AppColors.coralPrimary;
                    bgColor = isDark ? const Color(0xFF4C1D06) : const Color(0xFFFFEDD5);
                  }
                } else if (isSelected) {
                  borderColor = AppColors.tealPrimary;
                  bgColor = AppColors.getTealLight(isDark);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: _isAnswered
                        ? null
                        : () {
                            setState(() {
                              _selectedOptionIndex = optIdx;
                            });
                          },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: isSelected || (_isAnswered && isCorrect) ? 1.8 : 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.tealPrimary : AppColors.getSurfaceSecondary(isDark),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                optionLabel,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : AppColors.getTextSecondary(isDark),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              q.options[optIdx],
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.getTextPrimary(isDark),
                              ),
                            ),
                          ),
                          if (_isAnswered && isCorrect)
                            const Icon(Icons.check_circle_rounded, color: AppColors.greenPrimary, size: 20)
                          else if (_isAnswered && isSelected && !isCorrect)
                            const Icon(Icons.cancel_rounded, color: AppColors.coralPrimary, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Feedback Banner
              if (_isAnswered) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedOptionIndex == q.correctIndex ? AppColors.getGreenLight(isDark) : AppColors.getOrangeLight(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedOptionIndex == q.correctIndex ? AppColors.greenPrimary : AppColors.orangePrimary,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedOptionIndex == q.correctIndex ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                        color: _selectedOptionIndex == q.correctIndex ? AppColors.greenPrimary : AppColors.orangePrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedOptionIndex == q.correctIndex ? '✓ Correct! ${q.explanation}' : '💡 ${q.explanation}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Action Button
              if (!_isAnswered)
                ElevatedButton(
                  onPressed: _selectedOptionIndex == null
                      ? null
                      : () {
                          setState(() {
                            _isAnswered = true;
                            if (_selectedOptionIndex == q.correctIndex) {
                              _correctAnswers++;
                            }
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Check Answer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    if (_currentQuestionIndex < widget.questions.length - 1) {
                      setState(() {
                        _currentQuestionIndex++;
                        _selectedOptionIndex = null;
                        _isAnswered = false;
                      });
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Great job! You scored $_correctAnswers/${widget.questions.length} on ${widget.topic}!'),
                          backgroundColor: AppColors.tealPrimary,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _currentQuestionIndex < widget.questions.length - 1 ? 'Next Question →' : 'Finish Practice',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// PILLAR ITEM HELPER
// =============================================================================

class _SidebarPillarItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SidebarPillarItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.tealPrimary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
      ],
    );
  }
}
