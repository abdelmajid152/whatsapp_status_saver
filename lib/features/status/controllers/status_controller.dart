import 'package:get/get.dart';
import '../../../data/models/status_item.dart';
import '../../../data/services/status_service.dart';
import '../../../core/utils/permission_utils.dart';

/// Filter type for status tabs
enum FilterType { all, images, videos }

/// GetX Controller for Status Management
class StatusController extends GetxController {
  // Service
  final StatusService _statusService = StatusService.instance;

  // Observable states
  final RxList<StatusItem> images = <StatusItem>[].obs;
  final RxList<StatusItem> videos = <StatusItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasPermission = false.obs;
  final Rx<FilterType> activeTab = FilterType.all.obs;

  // Computed properties
  List<StatusItem> get allStatuses =>
      [...images, ...videos]
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  List<StatusItem> get filteredStatuses {
    switch (activeTab.value) {
      case FilterType.images:
        return images;
      case FilterType.videos:
        return videos;
      case FilterType.all:
        return allStatuses;
    }
  }

  int get allCount => allStatuses.length;
  int get imageCount => images.length;
  int get videoCount => videos.length;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  /// Initialize controller - request permissions and load statuses
  Future<void> _initialize() async {
    await requestPermissions();
  }

  /// Request storage permissions
  Future<void> requestPermissions() async {
    final granted = await PermissionUtils.requestStoragePermissions();
    hasPermission.value = granted;

    if (granted) {
      await loadStatuses();
    }
  }

  /// Load statuses from WhatsApp directory
  Future<void> loadStatuses() async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final result = await _statusService.loadStatuses();
      images.value = result.images;
      videos.value = result.videos;
    } catch (e) {
      // Error is logged in service
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh statuses
  @override
  Future<void> refresh() async {
    await loadStatuses();
  }

  /// Save a status to gallery
  Future<bool> saveStatus(StatusItem status) async {
    final success = await _statusService.saveStatus(status);
    if (success) {
      // Update saved state in list
      final imageIndex = images.indexWhere((s) => s.path == status.path);
      if (imageIndex != -1) {
        images[imageIndex].saved = true;
        images.refresh();
      }

      final videoIndex = videos.indexWhere((s) => s.path == status.path);
      if (videoIndex != -1) {
        videos[videoIndex].saved = true;
        videos.refresh();
      }
    }
    return success;
  }

  /// Change active tab
  void setActiveTab(FilterType tab) {
    activeTab.value = tab;
  }

  /// Open app settings
  Future<void> openSettings() async {
    await PermissionUtils.openSettings();
  }
}
