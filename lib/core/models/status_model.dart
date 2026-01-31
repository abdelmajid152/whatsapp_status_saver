class StatusModel {
  final int id;
  final String title;
  final String type; // video, image, text
  final String category;
  final String duration;
  final String size;
  final int downloads;
  final bool isFavorite;
  final String thumbnail;

  StatusModel({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.duration,
    required this.size,
    required this.downloads,
    required this.isFavorite,
    required this.thumbnail,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      category: json['category'],
      duration: json['duration'] ?? '',
      size: json['size'],
      downloads: json['downloads'],
      isFavorite: json['isFavorite'],
      thumbnail: json['thumbnail'],
    );
  }
}
