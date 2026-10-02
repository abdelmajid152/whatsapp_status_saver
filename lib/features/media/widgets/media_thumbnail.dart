import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../data/media_item.dart';
import '../providers/media_providers.dart';

/// Downscaled preview: images are decoded at grid size (not full
/// resolution), videos use a cached native thumbnail. Shimmers until ready.
class MediaThumbnail extends ConsumerWidget {
  const MediaThumbnail(this.item, {super.key, this.fit = BoxFit.cover});

  static const _decodeWidth = 320;

  final MediaItem item;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumb = item.isVideo ? ref.watch(videoThumbProvider(item)) : null;
    if (thumb != null && thumb.isLoading) return const ShimmerBox();

    final path = item.isVideo ? thumb!.value : item.path;
    if (path == null) return _Broken(item);

    return Image.file(
      File(path),
      fit: fit,
      cacheWidth: _decodeWidth,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) => _Broken(item),
      frameBuilder: (_, child, frame, sync) =>
          sync || frame != null ? child : const ShimmerBox(),
    );
  }
}

class _Broken extends StatelessWidget {
  const _Broken(this.item);

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: HugeIcon(
          icon: item.isVideo ? AppIcons.brokenVideo : AppIcons.brokenImage,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
