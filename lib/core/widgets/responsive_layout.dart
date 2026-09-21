import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Responsive container that centers content on wide screens (desktop/web)
/// and keeps mobile-first aesthetics crisp.
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.background,
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
