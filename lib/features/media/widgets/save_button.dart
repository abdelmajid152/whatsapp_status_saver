import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/snack.dart';
import '../data/media_item.dart';
import '../providers/media_providers.dart';

/// Download button that turns into a check once the item is saved.
/// Watches only its own "is saved" flag.
class SaveButton extends ConsumerWidget {
  const SaveButton(this.item, {super.key, this.expanded = false});

  final MediaItem item;
  final bool expanded;

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(mediaActionsProvider).save(item);
    if (context.mounted) {
      context.snack(
        ok ? Tr.savedOk : Tr.saveFailed,
        icon: ok ? Icons.check_circle_rounded : Icons.error_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(
      savedNamesProvider.select((names) => names.contains(item.name)),
    );
    final onPressed = saved ? null : () => _save(context, ref);
    final icon = Icon(
      saved ? Icons.check_rounded : Icons.download_rounded,
      color: Colors.white,
      size: expanded ? 22 : 18,
    );

    if (expanded) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          disabledBackgroundColor: AppColors.teal,
          disabledForegroundColor: Colors.white,
        ),
        icon: icon,
        label: Text(context.tr(saved ? Tr.saved : Tr.save)),
      );
    }

    return Material(
      color: saved ? AppColors.teal : AppColors.green,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(padding: const EdgeInsets.all(7), child: icon),
      ),
    );
  }
}
