import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// WhatsApp-styled header widget
class StatusHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onRefresh;
  final VoidCallback? onMenuPressed;
  final bool isRefreshing;

  const StatusHeader({
    super.key,
    required this.onRefresh,
    this.onMenuPressed,
    this.isRefreshing = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.secondary,
      elevation: 2,
      title: Row(
        children: [
          // WhatsApp Logo
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.message, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          // Title and subtitle
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Status Saver',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryForeground,
                  ),
                ),
                Text(
                  'Save WhatsApp Statuses',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xB3FAFAFA), // 70% opacity
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Refresh button
        IconButton(
          onPressed: isRefreshing ? null : onRefresh,
          icon: AnimatedRotation(
            turns: isRefreshing ? 1 : 0,
            duration: const Duration(seconds: 1),
            child: Icon(
              Icons.refresh,
              color: isRefreshing
                  ? AppColors.secondaryForeground.withValues(alpha: 0.5)
                  : AppColors.secondaryForeground,
            ),
          ),
        ),
        // Menu button
        IconButton(
          onPressed: onMenuPressed,
          icon: const Icon(
            Icons.more_vert,
            color: AppColors.secondaryForeground,
          ),
        ),
      ],
    );
  }
}
