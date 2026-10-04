import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/strings.dart';
import '../../permissions/storage_access.dart';
import '../../permissions/permission_view.dart';
import '../data/media_item.dart';
import 'media_grid.dart';

/// One page per source (WhatsApp, Business, Saved): Photos / Videos tabs.
class MediaPage extends StatelessWidget {
  const MediaPage({super.key, required this.source, required this.title});

  final MediaSource source;
  final Tr title;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: MediaType.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr(title)),
          bottom: TabBar(
            tabs: [
              Tab(text: context.tr(Tr.photos)),
              Tab(text: context.tr(Tr.videos)),
            ],
          ),
        ),
        body: _PermissionGate(
          source: source,
          child: TabBarView(
            children: [
              for (final type in MediaType.values)
                MediaGrid(source: source, type: type),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionGate extends ConsumerWidget {
  const _PermissionGate({required this.source, required this.child});

  final MediaSource source;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `value` stays set while re-checking, so the grid doesn't flicker.
    final granted = ref.watch(
      storageAccessProvider(source).select((s) => s.value),
    );
    return switch (granted) {
      null => const Center(child: CircularProgressIndicator()),
      false => PermissionView(source: source),
      true => child,
    };
  }
}
