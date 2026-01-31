import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/status_controller.dart';
import '../widgets/status_header.dart';
import '../widgets/status_tab_bar.dart';
import '../widgets/status_grid.dart';
import '../widgets/status_preview_modal.dart';
import '../../../core/theme/app_colors.dart';
import 'video_player_screen.dart';

/// Main home screen for Status Saver app
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StatusController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Obx(
                () => StatusHeader(
                  onRefresh: controller.refresh,
                  isRefreshing: controller.isLoading.value,
                  onMenuPressed: () => _showMenu(context),
                ),
              ),

              // Tab Bar
              Obx(
                () => StatusTabBar(
                  activeTab: controller.activeTab.value,
                  onTabChange: controller.setActiveTab,
                  allCount: controller.allCount,
                  imageCount: controller.imageCount,
                  videoCount: controller.videoCount,
                ),
              ),

              // Content
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.allStatuses.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (!controller.hasPermission.value) {
                    return _buildPermissionRequest(controller);
                  }

                  return RefreshIndicator(
                    onRefresh: controller.refresh,
                    color: AppColors.primary,
                    child: StatusGrid(
                      statuses: controller.filteredStatuses,
                      onStatusTap: (status, index) {
                        _openPreview(context, controller, index);
                      },
                      onDownload: (status) async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final success = await controller.saveStatus(status);
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              success ? 'تم الحفظ بنجاح ✓' : 'فشل الحفظ',
                            ),
                            backgroundColor: success
                                ? Colors.green
                                : Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // Floating refresh button
        floatingActionButton: Obx(
          () => FloatingActionButton(
            onPressed: controller.isLoading.value ? null : controller.refresh,
            backgroundColor: AppColors.primary,
            elevation: 6,
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionRequest(StatusController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'صلاحيات مطلوبة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'يحتاج التطبيق إلى صلاحية الوصول للملفات لعرض الاستوريهات',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: controller.requestPermissions,
              icon: const Icon(Icons.security),
              label: const Text('منح الصلاحيات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: controller.openSettings,
              child: const Text(
                'فتح الإعدادات',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPreview(
    BuildContext context,
    StatusController controller,
    int index,
  ) {
    final status = controller.filteredStatuses[index];

    if (status.isVideo) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoPath: status.path,
            onSave: () async {
              final success = await controller.saveStatus(status);
              if (context.mounted) {
                _showSaveResult(context, success);
              }
            },
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StatusPreviewModal(
            statuses: controller.filteredStatuses,
            initialIndex: index,
            onSave: (status) async {
              final success = await controller.saveStatus(status);
              if (context.mounted) {
                _showSaveResult(context, success);
              }
            },
          ),
        ),
      );
    }
  }

  void _showSaveResult(BuildContext context, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'تم الحفظ بنجاح ✓' : 'فشل الحفظ'),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('حول التطبيق'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('الإعدادات'),
              onTap: () {
                Navigator.pop(context);
                Get.find<StatusController>().openSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.message, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Status Saver'),
          ],
        ),
        content: const Text(
          'تطبيق لحفظ استوريهات الواتساب بسهولة.\n\nتطوير: abdelmajidDev\nالإصدار: 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
