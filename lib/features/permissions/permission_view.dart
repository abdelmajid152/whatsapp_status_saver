import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/l10n/strings.dart';
import '../../core/platform/native_storage.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/snack.dart';
import '../media/data/media_item.dart';
import 'folder_steps.dart';
import 'storage_access.dart';

class PermissionView extends ConsumerWidget {
  const PermissionView({super.key, required this.source});

  final MediaSource source;

  Future<void> _request(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(storageAccessProvider(source).notifier)
        .request();
    if (context.mounted) showPickFeedback(context, result, source);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EmptyView(
      icon: AppIcons.folderOpen,
      title: context.tr(
        source == MediaSource.business
            ? Tr.permissionTitleBusiness
            : Tr.permissionTitle,
      ),
      message: context.tr(Tr.permissionBody),
      action: Column(
        children: [
          FilledButton.icon(
            onPressed: () => _request(context, ref),
            icon: const HugeIcon(
              icon: AppIcons.lock,
              color: Colors.white,
              size: 20,
            ),
            label: Text(context.tr(Tr.grantPermission)),
          ),
          const SizedBox(height: 24),
          FolderSteps(source: source),
        ],
      ),
    );
  }
}

/// Explains a folder pick that didn't grant [source].
void showPickFeedback(
  BuildContext context,
  PickResult result,
  MediaSource source,
) {
  switch (result) {
    case PickResult.wrong:
      context.snack(Tr.wrongFolder, icon: AppIcons.error);
    case PickResult.other:
      context.snack(
        source == MediaSource.whatsapp
            ? Tr.pickedBusinessInstead
            : Tr.pickedWhatsappInstead,
        icon: AppIcons.info,
      );
    case PickResult.ok || PickResult.cancelled:
  }
}
