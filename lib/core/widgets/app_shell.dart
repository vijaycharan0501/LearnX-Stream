import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/theme_controller.dart';
import 'app_right_panel.dart';
import 'app_sidebar.dart';

/// Universal Responsive Application Shell for LearnX STREAM.
///
/// Ensures 100% visual consistency across all pages (Home, SmartExplain/Visualization,
/// Documents, AI Summary, Learning, Progress):
/// - Desktop (>= 950px): 3-column layout (Left Sidebar ~18%, Main Workspace ~62%, Right Learning Panel ~20%)
/// - Tablet (650–950px): 2-column layout (Left Sidebar, Main Workspace)
/// - Mobile (< 650px): Single-column layout with Navigation Drawer and Bottom Navigation
class AppShell extends StatelessWidget {
  final Widget child;
  final AppSidebar? sidebar;
  final AppRightPanel? rightPanel;
  final Widget? mobileBrandHeader;
  final Widget? bottomNavigationBar;
  final ScrollController? scrollController;
  final bool showRightPanelOnDesktop;
  final double maxWorkspaceWidth;
  final EdgeInsetsGeometry contentPadding;

  const AppShell({
    super.key,
    required this.child,
    this.sidebar,
    this.rightPanel,
    this.mobileBrandHeader,
    this.bottomNavigationBar,
    this.scrollController,
    this.showRightPanelOnDesktop = true,
    this.maxWorkspaceWidth = 860,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      drawer: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650 && sidebar != null) {
            return Drawer(
              backgroundColor: AppColors.getSurface(isDark),
              child: SafeArea(
                child: sidebar!,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 950;
            final isTablet = constraints.maxWidth >= 650 && constraints.maxWidth < 950;

            if (isDesktop) {
              // 3-Column Desktop Layout
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Left Sidebar
                  if (sidebar != null) ...[
                    SizedBox(
                      width: 230,
                      child: sidebar!,
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: AppColors.getCardBorder(isDark),
                    ),
                  ],

                  // 2. Center Main AI Workspace
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: maxWorkspaceWidth),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: contentPadding,
                          child: child,
                        ),
                      ),
                    ),
                  ),

                  // 3. Right Learning Panel
                  if (showRightPanelOnDesktop && rightPanel != null) ...[
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: AppColors.getCardBorder(isDark),
                    ),
                    SizedBox(
                      width: 260,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: rightPanel!,
                      ),
                    ),
                  ],
                ],
              );
            } else if (isTablet) {
              // 2-Column Tablet Layout
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sidebar != null) ...[
                    SizedBox(
                      width: 220,
                      child: sidebar!,
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: AppColors.getCardBorder(isDark),
                    ),
                  ],
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: child,
                    ),
                  ),
                ],
              );
            }

            // Mobile Single-Column Layout (< 650px)
            return SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  mobileBrandHeader ?? _buildDefaultMobileBrandHeader(context, isDark),
                  const SizedBox(height: 14),
                  child,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDefaultMobileBrandHeader(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Builder(
                  builder: (ctx) => InkWell(
                    onTap: () => Scaffold.of(ctx).openDrawer(),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.menu_rounded, color: AppColors.getTextPrimary(isDark), size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.tealPrimary, Color(0xFF0F766E)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.stream_rounded, color: Colors.white, size: 15),
                ),
                const SizedBox(width: 6),
                Text(
                  'LEARNX',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(width: 3),
                const Text(
                  'STREAM',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.tealPrimary,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => ThemeController.toggleTheme(),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                      size: 18,
                      color: isDark ? AppColors.tealPrimary : AppColors.orangePrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.getTealLight(isDark),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'LX',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.tealPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(height: 1, color: AppColors.getCardBorder(isDark)),
      ],
    );
  }
}
