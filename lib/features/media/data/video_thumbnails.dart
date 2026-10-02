import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

import 'media_item.dart';

/// Generates small JPEG thumbnails for videos and caches them on disk.
/// At most [_maxParallel] run at once, so scrolling a long grid can't
/// flood the native side with decoders.
abstract final class VideoThumbnails {
  static const _maxParallel = 2;
  static final _plugin = FcNativeVideoThumbnail();
  static final _queue = Queue<Completer<void>>();
  static int _running = 0;
  static final Future<String> _cacheDir = getApplicationCacheDirectory()
      .then((d) => Directory('${d.path}/thumbs').create(recursive: true))
      .then((d) => d.path);

  static Future<String?> of(MediaItem video) async {
    final dest =
        '${await _cacheDir}/${video.path.hashCode}_${video.modified.millisecondsSinceEpoch}.jpg';
    if (File(dest).existsSync()) return dest;

    return _limited(() async {
      try {
        final ok = await _plugin.saveThumbnailToFile(
          srcFile: video.path,
          destFile: dest,
          width: 360,
          height: 360,
          quality: 70,
        );
        return ok ? dest : null;
      } catch (_) {
        return null;
      }
    });
  }

  static Future<T> _limited<T>(Future<T> Function() task) async {
    if (_running >= _maxParallel) {
      final slot = Completer<void>();
      _queue.add(slot);
      await slot.future;
    }
    _running++;
    try {
      return await task();
    } finally {
      _running--;
      if (_queue.isNotEmpty) _queue.removeFirst().complete();
    }
  }
}
