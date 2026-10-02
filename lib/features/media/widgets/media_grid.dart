import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../viewer/media_viewer_page.dart';
import '../data/media_item.dart';
import '../providers/media_providers.dart';
import 'media_tile.dart';

const _gridPadding = EdgeInsets.fromLTRB(12, 8, 12, 140);
const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  childAspectRatio: 0.72,
);

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

    if (items == null) return const _LoadingGrid();

    final isSaved = source == MediaSource.saved;
    return RefreshIndicator(
      onRefresh: () => ref.refresh(mediaProvider(source).future),
      child: items.isEmpty
          ? EmptyView(
              icon: isSaved
                  ? AppIcons.saved
                  : (type == MediaType.image ? AppIcons.image : AppIcons.video),
              title: context.tr(isSaved ? Tr.noSaved : Tr.noStatus),
              message: context.tr(isSaved ? Tr.noSavedHint : Tr.noStatusHint),
            )
          : GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: _gridPadding,
              gridDelegate: _gridDelegate,
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

/// Same layout as the real grid, one shared shimmer animation.
class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: _gridPadding,
        gridDelegate: _gridDelegate,
        itemCount: 15,
        itemBuilder: (_, _) => const ShimmerBox.plain(radius: 16),
      ),
    );
  }
}
