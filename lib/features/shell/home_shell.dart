import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/widgets/app_icons.dart';
import '../media/data/media_item.dart';
import '../media/widgets/media_page.dart';
import '../permissions/storage_access.dart';
import '../settings/settings_page.dart';
import 'nav_index.dart';
import 'widgets/curved_nav_bar.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  // Coming back from WhatsApp (or system settings) re-checks permission,
  // which in turn rescans every source.
  late final _lifecycle = AppLifecycleListener(onResume: _refresh);

  void _refresh() => ref.invalidate(storageAccessProvider);

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: const _Pages(),
      bottomNavigationBar: CurvedNavBar(
        onCenterTap: _refresh,
        items: const [
          NavItem(AppIcons.status, Tr.status),
          NavItem(AppIcons.business, Tr.business),
          NavItem(AppIcons.saved, Tr.saved),
          NavItem(AppIcons.settings, Tr.settings),
        ],
      ),
    );
  }
}

/// Keeps every page alive (no rescans when switching tabs); only this
/// widget rebuilds on tab change.
class _Pages extends ConsumerWidget {
  const _Pages();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IndexedStack(
      index: ref.watch(navIndexProvider),
      children: const [
        MediaPage(source: MediaSource.whatsapp, title: Tr.appName),
        MediaPage(source: MediaSource.business, title: Tr.business),
        MediaPage(source: MediaSource.saved, title: Tr.saved),
        SettingsPage(),
      ],
    );
  }
}
