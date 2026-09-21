import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/study_material.dart';

/// Voice Input View for Study Material Input
/// Allows student to ask questions or state concepts using voice input.
class VoiceInputView extends StatefulWidget {
  final ValueChanged<StudyMaterial> onMaterialSubmitted;

  const VoiceInputView({
    super.key,
    required this.onMaterialSubmitted,
  });

  @override
  State<VoiceInputView> createState() => _VoiceInputViewState();
}

class _VoiceInputViewState extends State<VoiceInputView> with SingleTickerProviderStateMixin {
  bool _isListening = false;
  String _transcribedText = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _sampleQuestions = [
    'How does Binary Search find elements in logarithmic O(log N) time?',
    'Explain Ohm\'s Law with voltage, current, and resistance relationship.',
    'What is Polymorphism and Encapsulation in OOP?',
    'How does TCP Three-Way Handshake establish reliable connections?',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _pulseController.repeat(reverse: true);
        _transcribedText = 'How does Binary Search work and why is it O(log N)?';
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    });
  }

  void _selectSampleQuestion(String question) {
    setState(() {
      _transcribedText = question;
      _isListening = false;
      _pulseController.stop();
      _pulseController.reset();
    });
  }

  void _submitVoiceQuestion() {
    final text = _transcribedText.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please speak or select a question to analyze.'),
          backgroundColor: AppColors.coralPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Extract title from question
    String title = text;
    if (text.toLowerCase().contains('binary search')) {
      title = 'Binary Search';
    } else if (text.toLowerCase().contains('ohm')) {
      title = 'Ohm\'s Law';
    } else if (text.toLowerCase().contains('polymorphism') || text.toLowerCase().contains('oop')) {
      title = 'Object-Oriented Programming (OOP)';
    } else if (text.toLowerCase().contains('tcp')) {
      title = 'TCP Three-Way Handshake';
    }

    final material = StudyMaterial(
      title: title,
      sourceType: 'Voice Input',
      rawText: text,
    );

    widget.onMaterialSubmitted(material);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.mic_rounded, size: 22, color: AppColors.purplePrimary),
              SizedBox(width: 10),
              Text(
                'Voice Question',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask a question or name a concept. LearnX will analyze the question and construct an interactive visual explanation.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Central Microphone Pulse Button
          Center(
            child: GestureDetector(
              onTap: _toggleListening,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isListening ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isListening
                              ? [AppColors.coralPrimary, const Color(0xFFC2410C)]
                              : [AppColors.purplePrimary, const Color(0xFF6D28D9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? AppColors.coralPrimary : AppColors.purplePrimary)
                                .withValues(alpha: 0.35),
                            blurRadius: _isListening ? 24 : 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                        color: AppColors.textLight,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              _isListening ? 'Listening... Tap to stop' : 'Tap microphone to speak',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _isListening ? AppColors.coralPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Transcription Text Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _transcribedText.isNotEmpty ? AppColors.purpleBorder : AppColors.cardBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.transcribe_rounded, size: 14, color: AppColors.textMuted),
                    SizedBox(width: 6),
                    Text(
                      'Voice Transcription:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _transcribedText.isEmpty
                      ? 'Your question transcription will appear here...'
                      : '"$_transcribedText"',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontStyle: _transcribedText.isEmpty ? FontStyle.italic : FontStyle.normal,
                    fontWeight: _transcribedText.isEmpty ? FontWeight.w400 : FontWeight.w600,
                    color: _transcribedText.isEmpty ? AppColors.textMuted : AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Suggestion Chips
          const Text(
            'Or select a sample question:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sampleQuestions.map((q) {
              return InkWell(
                onTap: () => _selectSampleQuestion(q),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.purpleLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.purpleBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.psychology_rounded, size: 14, color: AppColors.purplePrimary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          q,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.purplePrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Submit Action Button
          ElevatedButton(
            onPressed: _submitVoiceQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purplePrimary,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Preview Material',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
