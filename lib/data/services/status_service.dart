import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import '../models/status_item.dart';
import '../../core/constants/app_constants.dart';

/// Service for loading and saving WhatsApp statuses
class StatusService {
  StatusService._();
  static final StatusService instance = StatusService._();

  /// Load all statuses from WhatsApp directories
  Future<({List<StatusItem> images, List<StatusItem> videos})>
  loadStatuses() async {
    final List<StatusItem> allImages = [];
    final List<StatusItem> allVideos = [];

    try {
      // Base WhatsApp path
      const basePath = AppConstants.whatsappBasePath;

      // Possible status paths
      List<String> possiblePaths = [
        '$basePath/${AppConstants.whatsappStatusPath}',
      ];

      // Check for accounts folder (multiple WhatsApp accounts)
      final accountsDir = Directory('$basePath/${AppConstants.accountsFolder}');
      if (await accountsDir.exists()) {
        final accountFolders = accountsDir.listSync();
        for (var folder in accountFolders) {
          if (folder is Directory) {
            final statusesPath =
                '${folder.path}/${AppConstants.whatsappStatusPath}';
            if (await Directory(statusesPath).exists()) {
              possiblePaths.add(statusesPath);
            }
          }
        }
      }

      // Scan all possible paths
      for (String path in possiblePaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          try {
            final files = dir.listSync();

            // Filter images
            final images = files
                .where((file) {
                  final filePath = file.path.toLowerCase();
                  return AppConstants.imageExtensions.any(
                    (ext) => filePath.endsWith(ext),
                  );
                })
                .map((file) => StatusItem.fromFile(file));

            // Filter videos
            final videos = files
                .where((file) {
                  final filePath = file.path.toLowerCase();
                  return AppConstants.videoExtensions.any(
                    (ext) => filePath.endsWith(ext),
                  );
                })
                .map((file) => StatusItem.fromFile(file));

            allImages.addAll(images);
            allVideos.addAll(videos);
          } catch (e) {
            if (kDebugMode) {
              print('Error reading path $path: $e');
            }
          }
        }
      }

      // Sort by timestamp (newest first)
      allImages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      allVideos.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading statuses: $e');
      }
    }

    return (images: allImages, videos: allVideos);
  }

  /// Save a status to gallery
  Future<bool> saveStatus(StatusItem status) async {
    try {
      bool? result;
      if (status.isVideo) {
        result = await GallerySaver.saveVideo(status.path);
      } else {
        result = await GallerySaver.saveImage(status.path);
      }
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving status: $e');
      }
      return false;
    }
  }

  /// Check if any status path exists
  Future<bool> hasStatusDirectory() async {
    const basePath = AppConstants.whatsappBasePath;

    // Check main path
    final mainDir = Directory('$basePath/${AppConstants.whatsappStatusPath}');
    if (await mainDir.exists()) return true;

    // Check accounts folder
    final accountsDir = Directory('$basePath/${AppConstants.accountsFolder}');
    if (await accountsDir.exists()) {
      final accountFolders = accountsDir.listSync();
      for (var folder in accountFolders) {
        if (folder is Directory) {
          final statusesPath =
              '${folder.path}/${AppConstants.whatsappStatusPath}';
          if (await Directory(statusesPath).exists()) {
            return true;
          }
        }
      }
    }

    return false;
  }
}
