import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/study_material.dart';

class TopicInputView extends StatefulWidget {
  final String initialTopic;
  final String initialMaterial;
  final ValueChanged<StudyMaterial> onMaterialSubmitted;

  const TopicInputView({
    super.key,
    this.initialTopic = '',
    this.initialMaterial = '',
    required this.onMaterialSubmitted,
  });

  @override
  State<TopicInputView> createState() => _TopicInputViewState();
}

class _TopicInputViewState extends State<TopicInputView> {
  late final TextEditingController _topicController;
  late final TextEditingController _materialController;

  String? _topicError;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(text: widget.initialTopic);
    _materialController = TextEditingController(text: widget.initialMaterial);
  }

  @override
  void dispose() {
    _topicController.dispose();
    _materialController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final topic = _topicController.text.trim();
    final material = _materialController.text.trim();

    // If both are empty, require at least a topic or notes
    if (topic.isEmpty && material.isEmpty) {
      setState(() {
        _topicError = 'Topic / Concept Name is required';
      });
      return;
    }

    setState(() {
      _topicError = null;
    });

    String finalTitle;
    String finalText;

    if (topic.isNotEmpty && material.isNotEmpty) {
      // Both topic and notes provided
      finalTitle = topic;
      finalText = material;
    } else if (topic.isNotEmpty && material.isEmpty) {
      // Only topic provided -> Topic is sufficient by itself!
      finalTitle = topic;
      finalText = topic;
    } else {
      // Only notes provided -> infer title from notes
      final lines = material
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      if (lines.isNotEmpty && lines.first.length <= 60) {
        finalTitle = lines.first.replaceAll(RegExp(r'^[#*\-\d\.\s]+'), '');
      } else {
        final words = material.split(RegExp(r'\s+'));
        finalTitle = words.take(5).join(' ');
      }
      if (finalTitle.isEmpty) {
        finalTitle = 'Study Topic';
      }
      finalText = material;
    }

    final studyMaterial = StudyMaterial(
      title: finalTitle,
      sourceType: 'Typed Text',
      rawText: finalText,
    );
    widget.onMaterialSubmitted(studyMaterial);
  }

  void _applyPreset({required String topic, required String notes}) {
    setState(() {
      _topicController.text = topic;
      _materialController.text = notes;
      _topicError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.orangeBorder),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.orangePrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Topic & Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Type a concept name or paste your study material',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Field 1: Topic Name
          Row(
            children: [
              const Text(
                'Topic / Concept Name',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.orangeBorder, width: 0.8),
                ),
                child: const Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orangePrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _topicController,
            onChanged: (val) {
              if (_topicError != null && val.trim().isNotEmpty) {
                setState(() => _topicError = null);
              }
            },
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Binary Search',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              errorText: _topicError,
              filled: true,
              fillColor: AppColors.surfaceSecondary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.orangePrimary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.coralPrimary, width: 1.2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.coralPrimary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Field 2: Study Material (Multiline, Optional)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Study Material / Notes',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _materialController,
            minLines: 4,
            maxLines: 8,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
            decoration: InputDecoration(
              hintText: 'Paste your notes or leave blank to generate explanation from the topic name',
              hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surfaceSecondary,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.orangePrimary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Quick Presets
          const Text(
            'Quick Concept Presets:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _PresetChip(
                label: 'Binary Search',
                isHighlighted: true,
                onTap: () => _applyPreset(
                  topic: 'Binary Search',
                  notes:
                      'Binary Search is a search algorithm that finds the position of a target value within a sorted array. It compares the target value to the middle element of the array. If they are not equal, the half in which the target cannot lie is eliminated and the search continues on the remaining half until it is successful.\n\nTime Complexity:\n- Best Case: O(1)\n- Average/Worst Case: O(log N)\n\nSpace Complexity: O(1) iterative, O(log N) recursive.',
                ),
              ),
              _PresetChip(
                label: 'OOP Polymorphism',
                onTap: () => _applyPreset(
                  topic: 'Object-Oriented Programming: Polymorphism',
                  notes:
                      'Polymorphism in OOP describes situations where something occurs in several different forms. In programming, it is the ability for different underlying forms or data types to be accessed through a uniform interface.\n\nKey Concepts:\n1. Compile-time Polymorphism (Method Overloading)\n2. Runtime Polymorphism (Method Overriding with dynamic dispatch & vtables)\n3. Subtyping / Interface implementation.',
                ),
              ),
              _PresetChip(
                label: 'TCP Three-Way Handshake',
                onTap: () => _applyPreset(
                  topic: 'TCP Three-Way Handshake',
                  notes:
                      'The TCP 3-way handshake establishes a reliable connection between a client and server over an IP network.\n\nSteps:\n1. SYN: Client sends SYN packet with Initial Sequence Number (ISN).\n2. SYN-ACK: Server responds with SYN-ACK, acknowledging client ISN and sending server ISN.\n3. ACK: Client sends ACK acknowledging server ISN. Connection is now ESTABLISHED.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Continue Button
          ElevatedButton(
            onPressed: _validateAndSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangePrimary,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_forward_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.orangeLight : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHighlighted ? AppColors.orangeBorder : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isHighlighted ? Icons.star_rounded : Icons.lightbulb_outline_rounded,
              size: 13,
              color: isHighlighted ? AppColors.orangePrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                color: isHighlighted ? AppColors.orangePrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
