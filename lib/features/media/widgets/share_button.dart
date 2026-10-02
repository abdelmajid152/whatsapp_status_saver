import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/widgets/app_icons.dart';
import '../data/media_item.dart';
import '../providers/media_providers.dart';

/// Shares the file through the system sheet. Small glass circle on tiles,
/// larger one next to the main action in the viewer.
class ShareButton extends ConsumerWidget {
  const ShareButton(this.item, {super.key, this.large = false});

  final MediaItem item;
  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: context.tr(Tr.share),
      child: Material(
        color: Colors.black.withValues(alpha: large ? 0.0 : 0.45),
        shape: large
            ? const CircleBorder(side: BorderSide(color: Colors.white38))
            : const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => ref.read(mediaActionsProvider).share(item),
          child: Padding(
            padding: EdgeInsets.all(large ? 15 : 7),
            child: HugeIcon(
              icon: AppIcons.share,
              color: Colors.white,
              size: large ? 22 : 18,
            ),
          ),
        ),
      ),
    );
  }
}
