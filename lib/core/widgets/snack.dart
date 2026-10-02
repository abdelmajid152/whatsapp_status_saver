import 'package:flutter/material.dart';

import '../l10n/strings.dart';

extension SnackX on BuildContext {
  void snack(Tr message, {IconData icon = Icons.check_circle_rounded}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(tr(message))),
            ],
          ),
        ),
      );
  }
}
