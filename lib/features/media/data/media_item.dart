import 'package:flutter/foundation.dart';

enum MediaType { image, video }

enum MediaSource {
  whatsapp('com.whatsapp', 'WhatsApp'),
  business('com.whatsapp.w4b', 'WhatsApp Business'),
  saved('', '');

  const MediaSource(this.package, this.folder);

  final String package;
  final String folder;
}

@immutable
class MediaItem {
  const MediaItem(this.path, this.type, this.modified, {this.displayName});

  final String path;
  final MediaType type;
  final DateTime modified;

  /// SAF URIs don't end with the file name, so it's passed explicitly.
  final String? displayName;

  bool get isVideo => type == MediaType.video;

  /// `content://` URI from SAF (Android 11+) rather than a file path.
  bool get isContent => path.startsWith('content://');
  String get name => displayName ?? path.substring(path.lastIndexOf('/') + 1);

  @override
  bool operator ==(Object other) =>
      other is MediaItem && other.path == path && other.modified == modified;

  @override
  int get hashCode => Object.hash(path, modified);
}

/// Value-equal so a rescan that finds nothing new doesn't notify listeners.
@immutable
class MediaFiles {
  const MediaFiles(this.images, this.videos);

  static const empty = MediaFiles([], []);

  final List<MediaItem> images;
  final List<MediaItem> videos;

  List<MediaItem> of(MediaType type) =>
      type == MediaType.image ? images : videos;

  @override
  bool operator ==(Object other) =>
      other is MediaFiles &&
      listEquals(other.images, images) &&
      listEquals(other.videos, videos);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(images), Object.hashAll(videos));
}
