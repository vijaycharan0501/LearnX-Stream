import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../models/material_input_data.dart';
import '../models/study_material.dart';
import '../widgets/scan_input_view.dart';
import '../widgets/topic_input_view.dart';
import '../widgets/upload_input_view.dart';
import '../widgets/voice_input_view.dart';
import 'material_preview_screen.dart';

class MaterialInputScreen extends StatefulWidget {
  final InputMethod initialMethod;
  final String? initialTopic;

  const MaterialInputScreen({
    super.key,
    this.initialMethod = InputMethod.scan,
    this.initialTopic,
  });

  @override
  State<MaterialInputScreen> createState() => _MaterialInputScreenState();
}

class _MaterialInputScreenState extends State<MaterialInputScreen> {
  late InputMethod _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialMethod;
  }

  void _onMethodChanged(InputMethod method) {
    setState(() {
      _selectedMethod = method;
    });
  }

  void _handleScanAction() {
    _showFeedbackSnackBar(
      message: 'Camera capture activated. Capture document or textbook page.',
      icon: Icons.camera_alt_outlined,
      color: AppColors.tealPrimary,
    );
  }

  void _handleMaterialSubmitted(StudyMaterial material) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MaterialPreviewScreen(material: material),
      ),
    );
  }

  void _showFeedbackSnackBar({
    required String message,
    required IconData icon,
    required Color color,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.textLight, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Study Material Input'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to Home',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              _showFeedbackSnackBar(
                message: 'LearnX STREAM turns any study format into deep understanding.',
                icon: Icons.lightbulb_outline_rounded,
                color: AppColors.tealPrimary,
              );
            },
            tooltip: 'About Input Methods',
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Tab / Method Switcher
                _buildMethodSelector(),
                const SizedBox(height: 20),

                // Active Input Method Card
                _buildActiveInputView(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: InputMethod.values.map((method) {
          final isSelected = _selectedMethod == method;
          return Expanded(
            child: InkWell(
              onTap: () => _onMethodChanged(method),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? method.lightColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: method.borderColor, width: 1)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      method.icon,
                      size: 15,
                      color: isSelected
                          ? method.accentColor
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        method.shortLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? method.accentColor
                              : AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveInputView() {
    switch (_selectedMethod) {
      case InputMethod.scan:
        return ScanInputView(
          onScanPressed: _handleScanAction,
        );
      case InputMethod.upload:
        return UploadInputView(
          onMaterialReady: _handleMaterialSubmitted,
        );
      case InputMethod.topic:
        return TopicInputView(
          initialTopic: widget.initialTopic ?? '',
          onMaterialSubmitted: _handleMaterialSubmitted,
        );
      case InputMethod.voice:
        return VoiceInputView(
          onMaterialSubmitted: _handleMaterialSubmitted,
        );
    }
  }
}
