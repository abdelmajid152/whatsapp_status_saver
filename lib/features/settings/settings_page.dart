import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/l10n/strings.dart';
import '../../core/widgets/app_icons.dart';
import '../media/data/media_repository.dart';
import 'settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const appVersion = '2.0.0';

  static const _themeLabels = {
    ThemeMode.system: Tr.themeSystem,
    ThemeMode.light: Tr.themeLight,
    ThemeMode.dark: Tr.themeDark,
  };
  static const _languages = {'ar': 'العربية', 'en': 'English'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr(Tr.settings))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
        children: [
          _Section(
            title: context.tr(Tr.appearance),
            children: [
              _Tile(
                icon: AppIcons.theme,
                title: context.tr(Tr.theme),
                value: context.tr(_themeLabels[settings.themeMode]!),
                onTap: () => _choose(
                  context,
                  title: context.tr(Tr.theme),
                  current: settings.themeMode,
                  options: {
                    for (final e in _themeLabels.entries)
                      e.key: context.tr(e.value),
                  },
                  onSelected: controller.setThemeMode,
                ),
              ),
              _Tile(
                icon: AppIcons.language,
                title: context.tr(Tr.language),
                value: _languages[settings.locale.languageCode],
                onTap: () => _choose(
                  context,
                  title: context.tr(Tr.language),
                  current: settings.locale.languageCode,
                  options: _languages,
                  onSelected: (code) => controller.setLocale(Locale(code)),
                ),
              ),
            ],
          ),
          _Section(
            title: context.tr(Tr.general),
            children: [
              _Tile(
                icon: AppIcons.help,
                title: context.tr(Tr.howToUse),
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(context.tr(Tr.howToUse)),
                    content: Text(context.tr(Tr.howToUseBody)),
                  ),
                ),
              ),
              _Tile(
                icon: AppIcons.folder,
                title: context.tr(Tr.downloadLocation),
                // LTR isolate so the path doesn't get reordered in Arabic.
                subtitle: '\u2066${MediaRepository.savedDir}\u2069',
              ),
              _Tile(
                icon: AppIcons.shield,
                title: context.tr(Tr.appPermissions),
                subtitle: context.tr(Tr.appPermissionsHint),
                onTap: openAppSettings,
              ),
            ],
          ),
          _Section(
            title: context.tr(Tr.about),
            children: [
              _Tile(
                icon: AppIcons.info,
                title: context.tr(Tr.appName),
                subtitle: '${context.tr(Tr.version)} $appVersion',
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _choose<T>(
    BuildContext context, {
    required String title,
    required T current,
    required Map<T, String> options,
    required ValueChanged<T> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(sheet).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final MapEntry(:key, :value) in options.entries)
              ListTile(
                title: Text(value),
                trailing: key == current
                    ? HugeIcon(
                        icon: AppIcons.success,
                        color: Theme.of(sheet).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  Navigator.pop(sheet);
                  onSelected(key);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8, bottom: 8),
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                for (final (i, child) in children.indexed) ...[
                  if (i > 0) const Divider(height: 1, indent: 64),
                  child,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
  });

  final AppIconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: primary.withValues(alpha: 0.12),
        child: HugeIcon(icon: icon, color: primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: value == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value!, style: TextStyle(color: primary)),
                HugeIcon(
                  icon: AppIcons.forward(context),
                  color: primary,
                  size: 18,
                ),
              ],
            ),
    );
  }
}
