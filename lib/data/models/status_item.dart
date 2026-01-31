import 'dart:io';

/// Enum for status type
enum StatusType { image, video }

/// Model representing a WhatsApp status item
class StatusItem {
  final String id;
  final String path;
  final StatusType type;
  final DateTime timestamp;
  final String? duration;
  bool saved;

  StatusItem({
    required this.id,
    required this.path,
    required this.type,
    required this.timestamp,
    this.duration,
    this.saved = false,
  });

  /// Get file from path
  File get file => File(path);

  /// Get file name
  String get fileName => path.split('/').last;

  /// Get file extension
  String get extension => path.split('.').last.toLowerCase();

  /// Check if this is an image
  bool get isImage => type == StatusType.image;

  /// Check if this is a video
  bool get isVideo => type == StatusType.video;

  /// Get human-readable timestamp
  String get formattedTimestamp {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  /// Create StatusItem from FileSystemEntity
  factory StatusItem.fromFile(FileSystemEntity file) {
    final path = file.path;
    final extension = path.split('.').last.toLowerCase();
    final stat = file.statSync();

    StatusType type;
    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      type = StatusType.image;
    } else {
      type = StatusType.video;
    }

    return StatusItem(
      id: path.hashCode.toString(),
      path: path,
      type: type,
      timestamp: stat.modified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StatusItem && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}
