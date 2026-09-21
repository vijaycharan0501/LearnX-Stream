import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../models/study_material.dart';
import 'ai_analysis_screen.dart';

class MaterialPreviewScreen extends StatefulWidget {
  final StudyMaterial material;
  final ApiService apiService;

  MaterialPreviewScreen({
    super.key,
    required this.material,
    ApiService? apiService,
  }) : apiService = apiService ?? ApiService();

  @override
  State<MaterialPreviewScreen> createState() => _MaterialPreviewScreenState();
}

class _MaterialPreviewScreenState extends State<MaterialPreviewScreen> {
  bool _isAnalyzing = false;

  StudyMaterial get material => widget.material;

  Future<void> _handleAnalyze() async {
    if (_isAnalyzing) return;

    final title = material.title.trim();
    final text = material.rawText.trim();

    if (material.isOcrPending && text.isEmpty) {
      _showErrorDialog(
        title: 'OCR Extraction Pending',
        message:
            'This image requires text extraction (OCR). Please upload extracted notes or enter text to analyze.',
        canRetry: false,
      );
      return;
    }

    final effectiveTitle = title.isNotEmpty ? title : (text.isNotEmpty ? text.split('\n').first : 'Study Topic');
    final effectiveText = text.isNotEmpty ? text : effectiveTitle;

    if (effectiveTitle.isEmpty && effectiveText.isEmpty) {
      _showErrorDialog(
        title: 'Empty Study Concept',
        message: 'Please provide a topic name or study notes to analyze.',
        canRetry: false,
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    // Show stylish analysis loading dialog
    _showLoadingDialog();

    try {
      final analysis = await widget.apiService.analyzeMaterial(effectiveTitle, effectiveText);

      if (!mounted) return;

      // Dismiss loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        _isAnalyzing = false;
      });

      // Navigate to AI Analysis screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AIAnalysisScreen(
            analysis: analysis,
            originalMaterial: material,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Dismiss loading dialog if active
      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        _isAnalyzing = false;
      });

      String errorMessage;
      if (e is ApiException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'An unexpected error occurred. Please check your connection and try again.';
      }

      _showErrorDialog(
        title: 'Analysis Error',
        message: errorMessage,
        canRetry: true,
      );
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.softShadow,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.tealBorder),
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.tealPrimary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Analyzing your material...',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connecting to LearnX AI to extract key concepts, difficulty, and the best learning representation...',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog({
    required String title,
    required String message,
    required bool canRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.coralBorder),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.coralLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.coralBorder),
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.coralPrimary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Dismiss',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    if (canRetry) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _handleAnalyze();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.tealPrimary,
                            foregroundColor: AppColors.textLight,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_rounded, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Try Again',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Material Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to Input',
        ),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                _buildHeaderCard(),
                const SizedBox(height: 16),

                // Statistics Row
                _buildStatisticsRow(),
                const SizedBox(height: 20),

                // Content Card (Text or Image)
                if (material.isOcrPending && material.fileBytes != null)
                  _buildImagePreviewCard()
                else
                  _buildContentCard(),

                const SizedBox(height: 24),

                // Analyze Material Action Button
                _buildAnalyzeButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final isPdf = material.sourceType == 'Uploaded PDF';
    final isImage = material.sourceType == 'Uploaded Image' || material.isOcrPending;
    final primaryColor = isPdf
        ? AppColors.bluePrimary
        : (isImage ? AppColors.tealPrimary : AppColors.orangePrimary);
    final lightColor = isPdf
        ? AppColors.blueLight
        : (isImage ? AppColors.tealLight : AppColors.orangeLight);
    final borderColor = isPdf
        ? AppColors.blueBorder
        : (isImage ? AppColors.tealBorder : AppColors.orangeBorder);

    final icon = isPdf
        ? Icons.picture_as_pdf_rounded
        : (isImage ? Icons.image_rounded : Icons.edit_note_rounded);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      material.sourceType,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (material.pageCount != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    '${material.pageCount} pages',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.greenBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 12,
                      color: AppColors.greenPrimary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Ready',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greenPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            material.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          if (material.fileName != null && material.fileName != material.title) ...[
            const SizedBox(height: 4),
            Text(
              material.fileName!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsRow() {
    final isImage = material.isOcrPending && material.fileBytes != null;

    if (isImage) {
      return Row(
        children: [
          Expanded(
            child: _buildStatItem(
              label: 'File Size',
              value: material.formattedFileSize.isNotEmpty
                  ? material.formattedFileSize
                  : 'Image',
              icon: Icons.folder_zip_rounded,
              color: AppColors.tealPrimary,
              bgColor: AppColors.tealLight,
              borderColor: AppColors.tealBorder,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatItem(
              label: 'OCR Status',
              value: 'Pending',
              icon: Icons.hourglass_top_rounded,
              color: AppColors.orangePrimary,
              bgColor: AppColors.orangeLight,
              borderColor: AppColors.orangeBorder,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            label: 'Characters',
            value: '${material.characterCount}',
            icon: Icons.format_size_rounded,
            color: AppColors.tealPrimary,
            bgColor: AppColors.tealLight,
            borderColor: AppColors.tealBorder,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            label: 'Words',
            value: '${material.wordCount}',
            icon: Icons.short_text_rounded,
            color: AppColors.bluePrimary,
            bgColor: AppColors.blueLight,
            borderColor: AppColors.blueBorder,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            label: 'Read Time',
            value: '~${material.estimatedReadingMinutes}m',
            icon: Icons.timer_outlined,
            color: AppColors.purplePrimary,
            bgColor: AppColors.purpleLight,
            borderColor: AppColors.purpleBorder,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 13, color: color),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.image_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6),
              Text(
                'Selected Image Preview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Notice Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.tealBorder),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.tealPrimary,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Image selected — OCR will be connected in a future phase.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tealPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Image Display Container
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 280),
              width: double.infinity,
              color: AppColors.surfaceSecondary,
              child: Image.memory(
                material.fileBytes!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: AppColors.surfaceSecondary,
                  child: const Center(
                    child: Text(
                      'Image Preview Available',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard() {
    final isPdf = material.sourceType == 'Uploaded PDF';
    final isTopicOnly = material.rawText.trim() == material.title.trim() || material.rawText.trim().isEmpty;
    final sectionTitle = isPdf
        ? 'Extracted PDF Content'
        : (isTopicOnly ? 'Study Concept' : 'Entered Study Material');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPdf
                    ? Icons.article_outlined
                    : (isTopicOnly ? Icons.lightbulb_outline_rounded : Icons.edit_note_rounded),
                size: 16,
                color: isTopicOnly ? AppColors.orangePrimary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                sectionTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isTopicOnly)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.orangeLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.orangeBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.orangePrimary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Direct Topic: ${material.title}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.orangePrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'LearnX will analyze "${material.title}", extract foundational concepts and prerequisites, and generate the most suitable visual explanation.',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textPrimary,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: SelectableText(
                material.rawText.isNotEmpty
                    ? material.rawText
                    : 'No text extracted from document.',
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textPrimary,
                  height: 1.55,
                  letterSpacing: 0.1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isAnalyzing ? null : _handleAnalyze,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tealPrimary,
          foregroundColor: AppColors.textLight,
          disabledBackgroundColor: AppColors.tealPrimary.withValues(alpha: 0.6),
          disabledForegroundColor: AppColors.textLight,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 20),
            SizedBox(width: 10),
            Text(
              'Analyze Material',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
