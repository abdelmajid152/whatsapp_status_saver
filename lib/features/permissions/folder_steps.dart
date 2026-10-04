import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../media/data/media_item.dart';

/// Manual path to the WhatsApp folder, for pickers that ignore the
/// requested starting folder. Any folder from `com.whatsapp` down works.
class FolderSteps extends StatelessWidget {
  const FolderSteps({super.key, required this.source});

  final MediaSource source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    Widget chip(String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );

    final parts = ['Android', 'media', source.package];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(context.tr(Tr.folderStepsTitle), style: muted),
          const SizedBox(height: 10),
          // Folder names read left-to-right in every language.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 6,
              children: [
                for (final (i, part) in parts.indexed) ...[
                  if (i > 0) Text('›', style: muted),
                  chip(part),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.tr(Tr.folderStepsTap),
            style: muted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
