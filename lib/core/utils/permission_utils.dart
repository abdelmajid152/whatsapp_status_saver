import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// Permission Utilities for Android Storage Access
class PermissionUtils {
  PermissionUtils._();

  /// Request storage permissions based on Android version
  static Future<bool> requestStoragePermissions() async {
    if (!Platform.isAndroid) return false;

    // For Android 13+ (API 33+), request specific media permissions
    if (await _isAndroid13OrAbove()) {
      final photosStatus = await Permission.photos.request();
      final videosStatus = await Permission.videos.request();
      final manageStorageStatus = await Permission.manageExternalStorage
          .request();

      return photosStatus.isGranted ||
          videosStatus.isGranted ||
          manageStorageStatus.isGranted;
    }

    // For older Android versions
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    return status.isGranted;
  }

  /// Check if all required permissions are granted
  static Future<bool> hasStoragePermissions() async {
    if (!Platform.isAndroid) return false;

    if (await _isAndroid13OrAbove()) {
      return await Permission.photos.isGranted ||
          await Permission.videos.isGranted ||
          await Permission.manageExternalStorage.isGranted;
    }

    return await Permission.storage.isGranted;
  }

  /// Open app settings page
  static Future<bool> openSettings() {
    return openAppSettings();
  }

  /// Check if Android 13 or above
  static Future<bool> _isAndroid13OrAbove() async {
    // Android 13 is API 33
    // We check using a simple heuristic based on Permission.photos availability
    final status = await Permission.photos.status;
    // If permission.photos returns a valid status, it's Android 13+
    return !status.isPermanentlyDenied || status.isGranted || status.isDenied;
  }
}
