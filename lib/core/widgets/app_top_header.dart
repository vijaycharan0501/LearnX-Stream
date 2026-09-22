import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/theme_controller.dart';

/// Universal Top Header for LearnX STREAM pages.
///
/// Provides:
/// - Left action / title / back button
/// - Right ☀️ Light ↔ 🌙 Dark theme toggle button that works universally.
class AppTopHeader extends StatelessWidget {
  final Widget? leading;
  final String? title;
  final VoidCallback? onBack;

  const AppTopHeader({
    super.key,
    this.leading,
    this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: leading ??
              (onBack != null
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: onBack,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.getSurface(isDark),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.getCardBorder(isDark)),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black26
                                    : const Color(0xFF0F172A).withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 13,
                                color: AppColors.getTextPrimary(isDark),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  title ?? 'Back to answer',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.getTextPrimary(isDark),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.tealPrimary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            title ?? 'Turn questions into understanding.',
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
                    )),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => ThemeController.toggleTheme(),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.getCardBorder(isDark)),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black26
                      : const Color(0xFF0F172A).withValues(alpha: 0.02),
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
                Flexible(
                  child: Text(
                    isDark ? 'Dark' : 'Light',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
