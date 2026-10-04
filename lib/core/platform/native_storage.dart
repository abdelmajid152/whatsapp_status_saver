import 'dart:io';

import 'package:flutter/services.dart';

enum PickResult { ok, wrong, cancelled }

/// A child of a SAF folder.
typedef SafEntry = ({
  String docId,
  String uri,
  String name,
  bool dir,
  DateTime modified,
});

/// Bridge to `MainActivity.kt` (Storage Access Framework + file helpers).
abstract final class NativeStorage {
  static const _channel = MethodChannel('status_saver/storage');

  static final Future<int> sdkInt = Platform.isAndroid
      ? _channel.invokeMethod<int>('sdkInt').then((v) => v ?? 0)
      : Future.value(0);

  /// Android 11+ reads WhatsApp folders through SAF.
  static Future<bool> get usesSaf async => await sdkInt >= 30;

  /// Tree URI the user already granted that covers [docId], or `null`.
  static Future<String?> grantedTree(String docId) =>
      _channel.invokeMethod<String>('grantedTree', {'docId': docId});

  /// Opens the system folder picker positioned on [docId].
  static Future<PickResult> pickTree(String docId) async {
    final r = await _channel.invokeMethod<String>('pickTree', {'docId': docId});
    return PickResult.values.byName(r ?? 'cancelled');
  }

  static Future<List<SafEntry>> list(String tree, String docId) async {
    final raw = await _channel.invokeListMethod<Map<Object?, Object?>>('list', {
      'tree': tree,
      'docId': docId,
    });
    return [
      for (final m in raw ?? const <Map<Object?, Object?>>[])
        (
          docId: m['docId']! as String,
          uri: m['uri']! as String,
          name: m['name']! as String,
          dir: m['dir']! as bool,
          modified: DateTime.fromMillisecondsSinceEpoch(m['modified']! as int),
        ),
    ];
  }

  /// Copies a `content://` URI or file path to [dest].
  static Future<void> copy(String source, String dest) =>
      _channel.invokeMethod('copy', {'source': source, 'dest': dest});

  /// Writes a small JPEG preview of an image or video to [dest].
  static Future<bool> thumbnail(
    String source,
    String dest, {
    required bool video,
    int size = 360,
  }) async =>
      await _channel.invokeMethod<bool>('thumbnail', {
        'source': source,
        'dest': dest,
        'video': video,
        'size': size,
      }) ??
      false;
}
