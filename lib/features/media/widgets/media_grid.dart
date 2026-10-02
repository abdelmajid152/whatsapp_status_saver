import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/widgets/empty_view.dart';
import '../../viewer/media_viewer_page.dart';
import '../data/media_item.dart';
import '../providers/media_providers.dart';
import 'media_tile.dart';

class MediaGrid extends ConsumerWidget {
  const MediaGrid({super.key, required this.source, required this.type});

  final MediaSource source;
  final MediaType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuilds only when this tab's list actually changes, not on every
    // loading/refresh state flip.
    final items = ref.watch(
      mediaProvider(source).select(
        (s) => s.value?.of(type) ?? (s.hasError ? const <MediaItem>[] : null),
      ),
    );

    if (items == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isSaved = source == MediaSource.saved;
    return RefreshIndicator(
      onRefresh: () => ref.refresh(mediaProvider(source).future),
      child: items.isEmpty
          ? EmptyView(
              icon: isSaved
                  ? Icons.download_for_offline_outlined
                  : Icons.photo_library_outlined,
              title: context.tr(isSaved ? Tr.noSaved : Tr.noStatus),
              message: context.tr(isSaved ? Tr.noSavedHint : Tr.noStatusHint),
            )
          : GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 140),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.72,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => MediaTile(
                key: ValueKey(items[i].path),
                item: items[i],
                showSave: !isSaved,
                onTap: () => MediaViewerPage.open(context, items, i, source),
              ),
            ),
    );
  }
}
