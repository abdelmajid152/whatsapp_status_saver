import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/status_controller.dart';

/// Tab bar widget for filtering statuses
class StatusTabBar extends StatelessWidget {
  final FilterType activeTab;
  final Function(FilterType) onTabChange;
  final int allCount;
  final int imageCount;
  final int videoCount;

  const StatusTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChange,
    required this.allCount,
    required this.imageCount,
    required this.videoCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondary.withValues(alpha: 0.95),
      child: Row(
        children: [
          _buildTab(label: 'All', count: allCount, type: FilterType.all),
          _buildTab(
            label: 'Images',
            count: imageCount,
            type: FilterType.images,
          ),
          _buildTab(
            label: 'Videos',
            count: videoCount,
            type: FilterType.videos,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required int count,
    required FilterType type,
  }) {
    final isActive = activeTab == type;

    return Expanded(
      child: InkWell(
        onTap: () => onTabChange(type),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primaryLight : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? AppColors.secondaryForeground
                      : AppColors.secondaryForeground.withValues(alpha: 0.7),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isActive
                        ? AppColors.secondaryForeground
                        : AppColors.secondaryForeground.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
