import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/media_item.dart';
import '../providers/media_providers.dart';

/// Downscaled preview: images are decoded at grid size (not full
/// resolution), videos use a cached native thumbnail.
class MediaThumbnail extends ConsumerWidget {
  const MediaThumbnail(this.item, {super.key});

  static const _decodeWidth = 320;

  final MediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = item.isVideo
        ? ref.watch(videoThumbProvider(item)).value
        : item.path;

    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        item.isVideo ? Icons.movie_outlined : Icons.image_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
    if (path == null) return placeholder;

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      cacheWidth: _decodeWidth,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) => placeholder,
      frameBuilder: (_, child, frame, sync) => sync
          ? child
          : AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: child,
            ),
    );
  }
}
