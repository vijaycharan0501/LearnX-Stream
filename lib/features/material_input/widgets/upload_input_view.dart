import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/services/file_picker_service.dart';
import '../../../core/services/pdf_extraction_service.dart';
import '../../../core/theme/app_colors.dart';
import '../models/study_material.dart';

class UploadInputView extends StatefulWidget {
  final ValueChanged<StudyMaterial> onMaterialReady;
  final FilePickerService? filePickerService;
  final PdfExtractionService? pdfExtractionService;

  const UploadInputView({
    super.key,
    required this.onMaterialReady,
    this.filePickerService,
    this.pdfExtractionService,
  });

  @override
  State<UploadInputView> createState() => _UploadInputViewState();
}

class _UploadInputViewState extends State<UploadInputView> {
  late final FilePickerService _filePickerService;
  late final PdfExtractionService _pdfExtractionService;

  PickedStudyFile? _selectedFile;
  bool _isProcessing = false;
  String? _extractedText;
  int? _pageCount;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _filePickerService = widget.filePickerService ?? FilePickerService();
    _pdfExtractionService = widget.pdfExtractionService ?? PdfExtractionService();
  }

  Future<void> _pickFile() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final picked = await _filePickerService.pickStudyFile();
      if (picked == null) return; // Cancelled

      await _processFile(picked);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _processFile(PickedStudyFile file) async {
    setState(() {
      _selectedFile = file;
      _isProcessing = true;
      _extractedText = null;
      _pageCount = null;
      _errorMessage = null;
    });

    if (file.isPdf) {
      final extraction = await _pdfExtractionService.extractText(file.bytes);
      if (!mounted) return;

      if (!extraction.success) {
        setState(() {
          _isProcessing = false;
          _errorMessage = extraction.errorMessage ?? 'Failed to parse PDF document.';
        });
        return;
      }

      setState(() {
        _isProcessing = false;
        _pageCount = extraction.pageCount;
        if (extraction.hasText) {
          _extractedText = extraction.text;
        } else {
          _extractedText =
              'Note: No text layer detected in this PDF (likely a scanned document). Optical Character Recognition (OCR) will be connected in the next phase.';
        }
      });
    } else {
      // Image file
      setState(() {
        _isProcessing = false;
        _extractedText =
            'Image document selected. Optical Character Recognition (OCR) will extract text from this image in the next phase.';
      });
    }
  }

  void _applySampleFile({
    required String name,
    required String extension,
    required String text,
    int size = 1024 * 340,
    int pageCount = 6,
  }) {
    final sampleFile = PickedStudyFile(
      name: name,
      extension: extension,
      sizeInBytes: size,
      bytes: Uint8List.fromList(text.codeUnits),
    );

    setState(() {
      _selectedFile = sampleFile;
      _extractedText = text;
      _pageCount = pageCount;
      _isProcessing = false;
      _errorMessage = null;
    });
  }

  void _continueToPreview() {
    if (_selectedFile == null) {
      setState(() {
        _errorMessage = 'Please select a PDF or Image file to continue.';
      });
      return;
    }

    final file = _selectedFile!;
    final isPdf = file.isPdf;

    final studyMaterial = StudyMaterial(
      title: file.name,
      sourceType: isPdf ? 'Uploaded PDF' : 'Uploaded Image',
      rawText: _extractedText ?? '',
      fileBytes: file.bytes,
      fileName: file.name,
      fileSizeBytes: file.sizeInBytes,
      pageCount: _pageCount,
      isOcrPending: !isPdf,
    );

    widget.onMaterialReady(studyMaterial);
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
          // Header info
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.blueLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.blueBorder),
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  color: AppColors.bluePrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload PDF / Image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Choose study material from your device',
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
          const SizedBox(height: 18),

          // Upload Zone / Drag & Drop Target
          InkWell(
            onTap: _isProcessing ? null : _pickFile,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.blueLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.blueBorder,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: _isProcessing
                    ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColors.bluePrimary,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Reading and extracting text...',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.bluePrimary,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.blueBorder),
                            ),
                            child: const Icon(
                              Icons.cloud_upload_outlined,
                              color: AppColors.bluePrimary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap to browse files from device',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Accepts PDF, PNG, JPG, JPEG (up to 25MB)',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Error Message Display
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.coralLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.coralBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 16,
                    color: AppColors.coralPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.coralPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Selected File Card
          if (_selectedFile != null) ...[
            _buildSelectedFileDetails(),
            const SizedBox(height: 16),
          ],

          // Quick Sample Materials Presets
          const Text(
            'Quick Sample Materials:',
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
              _SampleFileChip(
                fileName: 'OS_Concurrency.pdf',
                icon: Icons.picture_as_pdf_rounded,
                onTap: () => _applySampleFile(
                  name: 'Operating_Systems_Concurrency.pdf',
                  extension: 'pdf',
                  pageCount: 14,
                  text:
                      'CHAPTER 4: CONCURRENCY & SYNCHRONIZATION\n\n1. Critical Section Problem:\nWhen multiple threads execute concurrently, the critical section refers to the piece of code accessing shared resources (e.g. memory, files, hardware). Mutual exclusion guarantees that only one thread enters the critical section at any given time.\n\n2. Synchronization Mechanisms:\n- Mutex Locks: Binary semaphore used for exclusive mutual access.\n- Counting Semaphores: Integer variable initialized to maximum allowed concurrent accesses.\n- Condition Variables: Allow threads to suspend execution until a particular condition is met.\n\n3. Classic Synchronization Problems:\n- The Dining Philosophers Problem\n- The Producer-Consumer Problem\n- The Readers-Writers Problem',
                ),
              ),
              _SampleFileChip(
                fileName: 'Lecture_Graphs.pdf',
                icon: Icons.picture_as_pdf_rounded,
                onTap: () => _applySampleFile(
                  name: 'Lecture_Notes_Graphs.pdf',
                  extension: 'pdf',
                  pageCount: 8,
                  text:
                      'LECTURE 7: GRAPH THEORY & TRAVERSAL ALGORITHMS\n\nGraph Representations:\n1. Adjacency Matrix: 2D array of size V x V. O(1) edge lookup, O(V^2) space complexity.\n2. Adjacency List: Array of linked lists or vectors. Space complexity O(V + E).\n\nTraversals:\n- Breadth-First Search (BFS): Uses a FIFO queue. Finds shortest path in unweighted graphs. Time: O(V + E).\n- Depth-First Search (DFS): Uses recursion/call stack. Useful for topological sorting, cycle detection, and strongly connected components.',
                ),
              ),
              _SampleFileChip(
                fileName: 'Logic_Gate_Diagram.png',
                icon: Icons.image_rounded,
                onTap: () => _applySampleFile(
                  name: 'Digital_Logic_Gates.png',
                  extension: 'png',
                  size: 1024 * 180,
                  text:
                      'Digital logic gates schematic diagram showing AND, OR, XOR, NAND truth tables and circuit layout.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action Button
          ElevatedButton(
            onPressed: _isProcessing
                ? null
                : (_selectedFile == null ? _pickFile : _continueToPreview),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bluePrimary,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedFile == null
                      ? Icons.folder_open_rounded
                      : Icons.arrow_forward_rounded,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedFile == null ? 'Choose File' : 'Continue to Preview',
                  style: const TextStyle(
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

  Widget _buildSelectedFileDetails() {
    final file = _selectedFile!;
    final isPdf = file.isPdf;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blueBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isPdf ? AppColors.blueLight : AppColors.tealLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                  color: isPdf ? AppColors.bluePrimary : AppColors.tealPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${file.typeLabel} • ${file.formattedSize}${_pageCount != null ? ' • $_pageCount pages' : ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.greenBorder),
                ),
                child: const Text(
                  'Ready',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greenPrimary,
                  ),
                ),
              ),
            ],
          ),

          if (!isPdf) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.tealBorder),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: AppColors.tealPrimary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Image selected — OCR will be connected in the next phase.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tealPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (isPdf && _extractedText != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                _extractedText!.length > 180
                    ? '${_extractedText!.substring(0, 180)}...'
                    : _extractedText!,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SampleFileChip extends StatelessWidget {
  final String fileName;
  final IconData icon;
  final VoidCallback onTap;

  const _SampleFileChip({
    required this.fileName,
    required this.icon,
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
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.bluePrimary),
            const SizedBox(width: 5),
            Text(
              fileName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
