class CategoryModel {
  final int id;
  final String name;
  final String icon; // FontAwesome icon name
  final int count;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.count,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      count: json['count'],
    );
  }
}
