import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Android 11+ hides `Android/media/*/.Statuses` from normal storage access,
/// so "All files access" is the only reliable option there.
final Future<Permission> _required = () async {
  if (!Platform.isAndroid) return Permission.storage;
  final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
  return sdk >= 30 ? Permission.manageExternalStorage : Permission.storage;
}();

final permissionProvider = AsyncNotifierProvider<PermissionController, bool>(
  PermissionController.new,
);

class PermissionController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async => (await _required).isGranted;

  Future<void> request() async {
    final status = await (await _required).request();
    if (status.isPermanentlyDenied) await openAppSettings();
    state = AsyncData(status.isGranted);
  }
}
