import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../permissions/permission_controller.dart';
import '../data/media_item.dart';
import '../data/media_repository.dart';
import '../data/video_thumbnails.dart';

/// Files of one source. Invalidating [permissionProvider] rescans every source.
final mediaProvider = FutureProvider.family<MediaFiles, MediaSource>((
  ref,
  source,
) async {
  final granted = await ref.watch(permissionProvider.future);
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

final videoThumbProvider = FutureProvider.autoDispose
    .family<String?, MediaItem>((ref, video) => VideoThumbnails.of(video));

final mediaActionsProvider = Provider(MediaActions.new);

class MediaActions {
  MediaActions(this._ref);

  final Ref _ref;

  Future<bool> save(MediaItem item) => _run(() => MediaRepository.save(item));

  Future<bool> delete(MediaItem item) =>
      _run(() => MediaRepository.delete(item));

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
