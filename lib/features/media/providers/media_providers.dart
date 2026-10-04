import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../permissions/storage_access.dart';
import '../data/media_item.dart';
import '../data/media_repository.dart';

/// Files of one source; rescans whenever its [storageAccessProvider] does.
final mediaProvider = FutureProvider.family<MediaFiles, MediaSource>((
  ref,
  source,
) async {
  final granted = await ref.watch(storageAccessProvider(source).future);
  return granted ? MediaRepository.scan(source) : MediaFiles.empty;
});

/// Names already in the saved folder — tiles `select` their own entry, so
/// saving one status rebuilds only that tile.
final savedNamesProvider = Provider<Set<String>>((ref) {
  final saved = ref.watch(mediaProvider(MediaSource.saved)).value;
  if (saved == null) return const {};
  return {
    for (final item in [...saved.images, ...saved.videos]) item.name,
  };
});

/// Cached preview file for videos and SAF images.
final thumbProvider = FutureProvider.autoDispose.family<String?, MediaItem>(
  (ref, item) => MediaRepository.thumbnail(item),
);

/// A real file for [MediaItem] (full-size image of a SAF item).
final localFileProvider = FutureProvider.autoDispose.family<String, MediaItem>(
  (ref, item) => MediaRepository.localFile(item),
);

final mediaActionsProvider = Provider(MediaActions.new);

class MediaActions {
  MediaActions(this._ref);

  final Ref _ref;

  Future<bool> save(MediaItem item) => _run(() => MediaRepository.save(item));

  Future<bool> delete(MediaItem item) =>
      _run(() => MediaRepository.delete(item));

  /// Opens the system share sheet (WhatsApp, Telegram, …) with the file.
  Future<void> share(MediaItem item) async {
    final path = await MediaRepository.localFile(item);
    await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
  }

  Future<bool> _run(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } catch (_) {
      return false;
    } finally {
      _ref.invalidate(mediaProvider(MediaSource.saved));
    }
  }
}
