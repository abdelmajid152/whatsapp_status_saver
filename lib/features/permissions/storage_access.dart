import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/platform/native_storage.dart';
import '../media/data/media_item.dart';
import '../media/data/media_repository.dart';

/// Whether the app can read a source.
///
/// - Android 11+: a folder grant from the SAF picker (WhatsApp and Business
///   are granted separately; the saved folder needs nothing).
/// - Android ≤ 10: the classic storage permission.
///
/// Invalidate the whole family to re-check (e.g. on app resume); every
/// [mediaProvider] rescans with it.
final storageAccessProvider =
    AsyncNotifierProvider.family<StorageAccess, bool, MediaSource>(
      StorageAccess.new,
    );

class StorageAccess extends AsyncNotifier<bool> {
  StorageAccess(this.source);

  final MediaSource source;

  @override
  Future<bool> build() async {
    if (!await NativeStorage.usesSaf) return Permission.storage.isGranted;
    if (source == MediaSource.saved) return true;
    return await NativeStorage.grantedTree(
          MediaRepository.statusesDocId(source),
        ) !=
        null;
  }

  /// Asks for access. Returns [PickResult.wrong] when the user picked a
  /// folder that doesn't contain the statuses, so the UI can explain.
  Future<PickResult> request() async {
    if (!await NativeStorage.usesSaf) {
      final status = await Permission.storage.request();
      if (status.isPermanentlyDenied) await openAppSettings();
      state = AsyncData(status.isGranted);
      return status.isGranted ? PickResult.ok : PickResult.cancelled;
    }
    final result = await NativeStorage.pickTree(
      MediaRepository.statusesDocId(source),
    );
    if (result == PickResult.ok) state = const AsyncData(true);
    return result;
  }
}
