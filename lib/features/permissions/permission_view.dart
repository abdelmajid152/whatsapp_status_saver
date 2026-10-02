import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/widgets/empty_view.dart';
import 'permission_controller.dart';

class PermissionView extends ConsumerWidget {
  const PermissionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EmptyView(
      icon: Icons.folder_open_rounded,
      title: context.tr(Tr.permissionTitle),
      message: context.tr(Tr.permissionBody),
      action: FilledButton.icon(
        onPressed: ref.read(permissionProvider.notifier).request,
        icon: const Icon(Icons.lock_open_rounded),
        label: Text(context.tr(Tr.grantPermission)),
      ),
    );
  }
}
