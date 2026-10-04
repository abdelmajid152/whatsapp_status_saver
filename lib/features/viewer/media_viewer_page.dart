import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/l10n/strings.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/snack.dart';
import '../media/data/media_item.dart';
import '../media/providers/media_providers.dart';
import '../media/widgets/media_thumbnail.dart';
import '../media/widgets/save_button.dart';
import '../media/widgets/share_button.dart';
import 'widgets/video_view.dart';

/// Full-screen swipeable viewer for images and videos.
class MediaViewerPage extends StatefulWidget {
  const MediaViewerPage({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.source,
  });

  final List<MediaItem> items;
  final int initialIndex;
  final MediaSource source;

  static Future<void> open(
    BuildContext context,
    List<MediaItem> items,
    int index,
    MediaSource source,
  ) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) =>
            MediaViewerPage(items: items, initialIndex: index, source: source),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late final _page = PageController(initialPage: widget.initialIndex);
  // Only the counter and the action bar listen to this — swiping doesn't
  // rebuild the PageView.
  late final _index = ValueNotifier(widget.initialIndex);

  @override
  void dispose() {
    _page.dispose();
    _index.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xAA000000), Colors.transparent],
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: HugeIcon(icon: AppIcons.back(context), color: Colors.white),
        ),
        title: ValueListenableBuilder(
          valueListenable: _index,
          builder: (_, i, _) => Text(
            '${i + 1} / ${widget.items.length}',
            textDirection: TextDirection.ltr,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      body: PageView.builder(
        controller: _page,
        itemCount: widget.items.length,
        onPageChanged: (i) => _index.value = i,
        itemBuilder: (_, i) {
          final item = widget.items[i];
          return item.isVideo
              ? VideoView(key: ValueKey(item.path), item: item)
              : _ImageView(item);
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: ValueListenableBuilder(
          valueListenable: _index,
          builder: (_, i, _) => Row(
            children: [
              Expanded(
                child: widget.source == MediaSource.saved
                    ? _DeleteButton(widget.items[i])
                    : SaveButton(widget.items[i], expanded: true),
              ),
              const SizedBox(width: 12),
              ShareButton(widget.items[i], large: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends ConsumerWidget {
  const _DeleteButton(this.item);

  final MediaItem item;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr(Tr.deleteConfirm)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr(Tr.cancel)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr(Tr.delete)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await ref.read(mediaActionsProvider).delete(item);
    if (!context.mounted) return;
    Navigator.pop(context);
    context.snack(ok ? Tr.deleted : Tr.saveFailed);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
      onPressed: () => _delete(context, ref),
      icon: const HugeIcon(
        icon: AppIcons.delete,
        color: Colors.white,
        size: 20,
      ),
      label: Text(context.tr(Tr.delete)),
    );
  }
}

/// Zoomable full-size image. SAF images are copied to a local file first;
/// the grid thumbnail is shown meanwhile.
class _ImageView extends ConsumerWidget {
  const _ImageView(this.item);

  final MediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = item.isContent
        ? ref.watch(localFileProvider(item)).value
        : item.path;
    return InteractiveViewer(
      maxScale: 4,
      child: Center(
        child: path == null
            ? MediaThumbnail(item, fit: BoxFit.contain)
            : Image.file(File(path), gaplessPlayback: true),
      ),
    );
  }
}
