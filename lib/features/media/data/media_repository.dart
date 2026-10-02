import 'dart:io';
import 'dart:isolate';

import 'media_item.dart';

/// File-system access for statuses and saved files.
/// Scanning runs in a background isolate so the UI never freezes.
abstract final class MediaRepository {
  static const _root = '/storage/emulated/0';
  static const savedDir = '$_root/Download/StatusSaver';

  static const _images = {'jpg', 'jpeg', 'png', 'webp'};
  static const _videos = {'mp4', 'mkv', 'mov', '3gp'};

  static Future<MediaFiles> scan(MediaSource source) =>
      Isolate.run(() => _scanSync(source));

  static Future<void> save(MediaItem item) async {
    await Directory(savedDir).create(recursive: true);
    await File(item.path).copy('$savedDir/${item.name}');
  }

  static Future<void> delete(MediaItem item) => File(item.path).delete();

  static List<String> _dirsFor(MediaSource source) {
    if (source == MediaSource.saved) return [savedDir];

    const statuses = 'Media/.Statuses';
    final base = '$_root/Android/media/${source.package}/${source.folder}';
    final accounts = Directory('$base/accounts');
    return [
      '$base/$statuses',
      '$_root/${source.folder}/$statuses', // Legacy (Android ≤ 10) location.
      if (accounts.existsSync())
        for (final dir in accounts.listSync().whereType<Directory>())
          '${dir.path}/$statuses',
    ];
  }

  static MediaFiles _scanSync(MediaSource source) {
    final images = <MediaItem>[];
    final videos = <MediaItem>[];

    for (final path in _dirsFor(source)) {
      final dir = Directory(path);
      if (!dir.existsSync()) continue;
      try {
        for (final file in dir.listSync().whereType<File>()) {
          final ext = file.path.substring(file.path.lastIndexOf('.') + 1);
          final type = switch (ext.toLowerCase()) {
            final e when _images.contains(e) => MediaType.image,
            final e when _videos.contains(e) => MediaType.video,
            _ => null,
          };
          if (type == null) continue;
          final item = MediaItem(file.path, type, file.lastModifiedSync());
          (type == MediaType.image ? images : videos).add(item);
        }
      } on FileSystemException {
        // Folder not readable (missing permission) — skip it.
      }
    }

    int newestFirst(MediaItem a, MediaItem b) => b.modified.compareTo(a.modified);
    return MediaFiles(images..sort(newestFirst), videos..sort(newestFirst));
  }
}
