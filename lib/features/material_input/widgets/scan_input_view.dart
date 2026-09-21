import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ScanInputView extends StatelessWidget {
  final VoidCallback onScanPressed;

  const ScanInputView({
    super.key,
    required this.onScanPressed,
  });

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
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.tealBorder),
                ),
                child: const Icon(
                  Icons.document_scanner_rounded,
                  color: AppColors.tealPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan Material',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Capture a textbook page or notes',
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

          // Camera Viewfinder Mock Container
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.tealLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.tealBorder,
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Top-Left Corner
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildCorner(isTop: true, isLeft: true),
                ),
                // Top-Right Corner
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildCorner(isTop: true, isLeft: false),
                ),
                // Bottom-Left Corner
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: _buildCorner(isTop: false, isLeft: true),
                ),
                // Bottom-Right Corner
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: _buildCorner(isTop: false, isLeft: false),
                ),

                // Center Icon and instruction
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.tealBorder),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.tealPrimary.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.tealPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Align text inside frame',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tealPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Action button
          ElevatedButton(
            onPressed: onScanPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealPrimary,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'Open Camera',
                  style: TextStyle(
                    fontSize: 14,
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

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: AppColors.tealPrimary, width: 3)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: AppColors.tealPrimary, width: 3)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: AppColors.tealPrimary, width: 3)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: AppColors.tealPrimary, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }
}
