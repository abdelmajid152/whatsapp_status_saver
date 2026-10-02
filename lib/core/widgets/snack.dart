import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../l10n/strings.dart';
import 'app_icons.dart';

extension SnackX on BuildContext {
  void snack(Tr message, {AppIconData icon = AppIcons.success}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              HugeIcon(icon: icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(tr(message))),
            ],
          ),
        ),
      );
  }
}
