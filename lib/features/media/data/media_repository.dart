import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:path_provider/path_provider.dart';

import '../../../core/platform/native_storage.dart';
import 'media_item.dart';

/// Reads statuses and manages saved files.
///
/// Android 11+: WhatsApp folders are read through SAF (`content://` URIs) in
/// the folders the user granted. Android ≤ 10 and the saved folder use plain
/// files, scanned in a background isolate so the UI never freezes.
abstract final class MediaRepository {
  static const _root = '/storage/emulated/0';
  static const savedDir = '$_root/Download/StatusSaver';

  static const _images = {'jpg', 'jpeg', 'png', 'webp'};
  static const _videos = {'mp4', 'mkv', 'mov', '3gp'};

  static final Future<String> _cacheDir = getApplicationCacheDirectory().then(
    (d) => d.path,
  );

  /// SAF document id of a source's WhatsApp folder (`…/WhatsApp`).
  static String rootDocId(MediaSource source) =>
      'primary:Android/media/${source.package}/${source.folder}';

  /// SAF document id of a source's statuses folder — the picker opens here.
  static String statusesDocId(MediaSource source) =>
      '${rootDocId(source)}/Media/.Statuses';

  static Future<MediaFiles> scan(MediaSource source) async =>
      source != MediaSource.saved && await NativeStorage.usesSaf
      ? _scanSaf(source)
      : Isolate.run(() => _scanFiles(source));

  static Future<void> save(MediaItem item) =>
      _copy(item, '$savedDir/${item.name}');

  static Future<void> delete(MediaItem item) => File(item.path).delete();

  /// A real file for [item] (sharing, full-size image). SAF items are copied
  /// into the cache once; status names are unique so the name is the key.
  static Future<String> localFile(MediaItem item) async {
    if (!item.isContent) return item.path;
    final dest = '${await _cacheDir}/media/${item.name}';
    if (!File(dest).existsSync()) await _copy(item, dest);
    return dest;
  }

  /// Cached JPEG preview for videos and SAF images; `null` if unavailable.
  static Future<String?> thumbnail(MediaItem item) async {
    final dest =
        '${await _cacheDir}/thumbs/'
        '${item.path.hashCode}_${item.modified.millisecondsSinceEpoch}.jpg';
    if (File(dest).existsSync()) return dest;
    final ok = await _limited(
      () => NativeStorage.thumbnail(item.path, dest, video: item.isVideo),
    );
    return ok ? dest : null;
  }

  static Future<void> _copy(MediaItem item, String dest) async {
    if (item.isContent) return NativeStorage.copy(item.path, dest);
    await File(dest).parent.create(recursive: true);
    await File(item.path).copy(dest);
  }

  static MediaType? _typeOf(String name) =>
      switch (name.substring(name.lastIndexOf('.') + 1).toLowerCase()) {
        final e when _images.contains(e) => MediaType.image,
        final e when _videos.contains(e) => MediaType.video,
        _ => null,
      };

  static MediaFiles _sorted(Iterable<MediaItem> items) {
    int newestFirst(MediaItem a, MediaItem b) =>
        b.modified.compareTo(a.modified);
    final images = [
      for (final i in items)
        if (!i.isVideo) i,
    ]..sort(newestFirst);
    final videos = [
      for (final i in items)
        if (i.isVideo) i,
    ]..sort(newestFirst);
    return MediaFiles(images, videos);
  }

  // ---- SAF (Android 11+) ---------------------------------------------------

  static Future<MediaFiles> _scanSaf(MediaSource source) async {
    final statuses = statusesDocId(source);
    final tree = await NativeStorage.grantedTree(statuses);
    if (tree == null) return MediaFiles.empty;

    final folders = [statuses];
    // Multi-account installs keep extra folders under `WhatsApp/accounts`;
    // only reachable if the user granted the WhatsApp folder itself.
    final accounts = '${rootDocId(source)}/accounts';
    if (await NativeStorage.grantedTree(accounts) == tree) {
      for (final dir in await NativeStorage.list(tree, accounts)) {
        if (dir.dir) folders.add('${dir.docId}/Media/.Statuses');
      }
    }

    final items = <MediaItem>[];
    for (final folder in folders) {
      for (final e in await NativeStorage.list(tree, folder)) {
        final type = e.dir ? null : _typeOf(e.name);
        if (type != null) {
          items.add(MediaItem(e.uri, type, e.modified, displayName: e.name));
        }
      }
    }
    return _sorted(items);
  }

  // ---- Plain files (Android ≤ 10, saved folder) ----------------------------

  static List<String> _dirsFor(MediaSource source) {
    if (source == MediaSource.saved) return [savedDir];

    const statuses = 'Media/.Statuses';
    final base = '$_root/Android/media/${source.package}/${source.folder}';
    final accounts = Directory('$base/accounts');
    return [
      '$base/$statuses',
      '$_root/${source.folder}/$statuses', // Legacy location.
      if (accounts.existsSync())
        for (final dir in accounts.listSync().whereType<Directory>())
          '${dir.path}/$statuses',
    ];
  }

  static MediaFiles _scanFiles(MediaSource source) {
    final items = <MediaItem>[];
    for (final path in _dirsFor(source)) {
      final dir = Directory(path);
      if (!dir.existsSync()) continue;
      try {
        for (final file in dir.listSync().whereType<File>()) {
          final type = _typeOf(file.path);
          if (type != null) {
            items.add(MediaItem(file.path, type, file.lastModifiedSync()));
          }
        }
      } on FileSystemException {
        // Folder not readable — skip it.
      }
    }
    return _sorted(items);
  }

  // ---- Throttling ----------------------------------------------------------

  /// At most two thumbnails decode at once, so fast scrolling can't flood
  /// the native side with decoders.
  static const _maxParallel = 2;
  static final _queue = Queue<Completer<void>>();
  static int _running = 0;

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
