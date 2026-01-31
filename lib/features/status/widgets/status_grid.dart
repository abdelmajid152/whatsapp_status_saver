import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/status_item.dart';
import 'status_card.dart';

/// Grid widget for displaying statuses
class StatusGrid extends StatelessWidget {
  final List<StatusItem> statuses;
  final Function(StatusItem, int) onStatusTap;
  final Function(StatusItem)? onDownload;

  const StatusGrid({
    super.key,
    required this.statuses,
    required this.onStatusTap,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    if (statuses.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.gridPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppConstants.gridCrossAxisCount,
        crossAxisSpacing: AppConstants.gridSpacing,
        mainAxisSpacing: AppConstants.gridSpacing,
        childAspectRatio: AppConstants.statusCardAspectRatio,
      ),
      itemCount: statuses.length,
      itemBuilder: (context, index) {
        final status = statuses[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: StatusCard(
            status: status,
            onTap: () => onStatusTap(status, index),
            onDownload: onDownload != null ? () => onDownload!(status) : null,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // WhatsApp icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.muted.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.message, size: 40, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          const Text(
            'No statuses found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap refresh to scan for new statuses',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
