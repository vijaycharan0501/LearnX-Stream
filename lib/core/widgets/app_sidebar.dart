import 'package:flutter/material.dart';
import '../models/conversation_session.dart';
import '../theme/app_colors.dart';

/// Reusable LearnX STREAM Left Sidebar Component.
///
/// Matches Screenshot 1 exact design system:
/// - Brand Header with emblem logo + LEARNX STREAM
/// - [+ New Chat] button
/// - Navigation links: Home, Learning, Documents, Saved
/// - 📌 PINNED section with overflow actions (Rename, Pin/Unpin, Delete)
/// - RECENT CHATS section with overflow actions
/// - 100% theme-adaptive for pristine Light and deep Dark modes.
class AppSidebar extends StatelessWidget {
  final List<ConversationSession> sessions;
  final ConversationSession? activeSession;
  final int activeNavIndex;
  final VoidCallback onNewChat;
  final ValueChanged<ConversationSession>? onSelectSession;
  final ValueChanged<ConversationSession>? onTogglePinSession;
  final ValueChanged<ConversationSession>? onRenameSession;
  final ValueChanged<ConversationSession>? onDeleteSession;
  final ValueChanged<int>? onNavigateTab;
  final bool isDrawer;

  const AppSidebar({
    super.key,
    required this.sessions,
    this.activeSession,
    this.activeNavIndex = 0,
    required this.onNewChat,
    this.onSelectSession,
    this.onTogglePinSession,
    this.onRenameSession,
    this.onDeleteSession,
    this.onNavigateTab,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pinnedSessions = sessions.where((s) => s.isPinned).toList();
    final recentSessions = sessions.where((s) => !s.isPinned).toList();

    return Container(
      color: AppColors.getSurface(isDark),
      padding: EdgeInsets.symmetric(
        horizontal: isDrawer ? 16 : 14,
        vertical: isDrawer ? 16 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BRAND HEADER
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

          // 2. + NEW CHAT BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNewChat,
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

          // 3. NAVIGATION LINKS
          _buildSidebarNavItem(
            context: context,
            index: 0,
            icon: Icons.home_rounded,
            label: 'Home',
            isSelected: activeNavIndex == 0,
            onTap: () => onNavigateTab?.call(0),
          ),
          const SizedBox(height: 2),
          _buildSidebarNavItem(
            context: context,
            index: 1,
            icon: Icons.auto_stories_rounded,
            label: 'Learning',
            isSelected: activeNavIndex == 1,
            onTap: () => onNavigateTab?.call(1),
          ),
          const SizedBox(height: 2),
          _buildSidebarNavItem(
            context: context,
            index: 2,
            icon: Icons.description_rounded,
            label: 'Documents',
            isSelected: activeNavIndex == 2,
            onTap: () => onNavigateTab?.call(2),
          ),
          const SizedBox(height: 2),
          _buildSidebarNavItem(
            context: context,
            index: 3,
            icon: Icons.star_rounded,
            label: 'Saved',
            isSelected: activeNavIndex == 3,
            onTap: () => onNavigateTab?.call(3),
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.getCardBorder(isDark)),
          const SizedBox(height: 12),

          // 4. CONVERSATION HISTORY (PINNED & RECENT)
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Text(
                        'No pinned conversations yet.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.getTextMuted(isDark),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    ...pinnedSessions.map((session) => _buildSessionTile(context, session, isDark)),

                  const SizedBox(height: 16),

                  // RECENT CHATS SECTION
                  Text(
                    'RECENT CHATS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.getTextMuted(isDark),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (recentSessions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Text(
                        'No recent chats yet.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.getTextMuted(isDark),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    ...recentSessions.map((session) => _buildSessionTile(context, session, isDark)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

  Widget _buildSessionTile(BuildContext context, ConversationSession session, bool isDark) {
    final isActive = activeSession?.id == session.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: () => onSelectSession?.call(session),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.getTealLight(isDark) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? AppColors.getTealBorder(isDark) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                session.isPinned ? Icons.push_pin_rounded : Icons.chat_bubble_outline_rounded,
                size: 13,
                color: session.isPinned
                    ? AppColors.orangePrimary
                    : (isActive ? AppColors.tealPrimary : AppColors.getTextMuted(isDark)),
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
                padding: EdgeInsets.zero,
                iconSize: 15,
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.getTextMuted(isDark),
                ),
                color: AppColors.getSurface(isDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.getCardBorder(isDark)),
                ),
                onSelected: (value) {
                  if (value == 'rename') {
                    onRenameSession?.call(session);
                  } else if (value == 'pin') {
                    onTogglePinSession?.call(session);
                  } else if (value == 'delete') {
                    onDeleteSession?.call(session);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 15, color: AppColors.tealPrimary),
                        const SizedBox(width: 8),
                        Text('Rename', style: TextStyle(fontSize: 12.5, color: AppColors.getTextPrimary(isDark))),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'pin',
                    child: Row(
                      children: [
                        Icon(
                          session.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                          size: 15,
                          color: AppColors.orangePrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          session.isPinned ? 'Unpin' : 'Pin',
                          style: TextStyle(fontSize: 12.5, color: AppColors.getTextPrimary(isDark)),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded, size: 15, color: AppColors.coralPrimary),
                        const SizedBox(width: 8),
                        Text('Delete', style: TextStyle(fontSize: 12.5, color: AppColors.coralPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
