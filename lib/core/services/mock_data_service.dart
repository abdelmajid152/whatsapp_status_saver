import 'package:get/get.dart';
import '../models/status_model.dart';
import '../models/category_model.dart';

class MockDataService extends GetxService {
  List<StatusModel> getStatuses() {
    return [
      StatusModel(
        id: 1,
        title: "حالة دينية مؤثرة عن الصبر",
        type: "video",
        category: "religious",
        duration: "0:25",
        size: "3.2 MB",
        downloads: 1250,
        isFavorite: false,
        thumbnail:
            "https://images.unsplash.com/photo-1542838132-92c53300491e?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80",
      ),
      StatusModel(
        id: 2,
        title: "منظر طبيعي خلاب للاستمتاع",
        type: "image",
        category: "nature",
        duration: "",
        size: "1.8 MB",
        downloads: 890,
        isFavorite: true,
        thumbnail:
            "https://images.unsplash.com/photo-1501854140801-50d01698950b?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80",
      ),
      StatusModel(
        id: 3,
        title: "كلام جميل عن الحياة والأمل",
        type: "text",
        category: "motivational",
        duration: "",
        size: "0.5 MB",
        downloads: 2100,
        isFavorite: false,
        thumbnail:
            "https://images.unsplash.com/photo-1519681393784-d120267933ba?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80",
      ),
      StatusModel(
        id: 4,
        title: "فيديو مضحك لقطط طريفة",
        type: "video",
        category: "funny",
        duration: "0:42",
        size: "4.5 MB",
        downloads: 3200,
        isFavorite: false,
        thumbnail:
            "https://images.unsplash.com/photo-1514888286974-6d03bde4ba42?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80",
      ),
      StatusModel(
        id: 5,
        title: "حالة رومانسية مع مشاعر جميلة",
        type: "image",
        category: "romantic",
        duration: "",
        size: "2.1 MB",
        downloads: 1560,
        isFavorite: true,
        thumbnail:
            "https://images.unsplash.com/photo-1518568814500-bf0f8d125f46?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80",
      ),
      StatusModel(
        id: 6,
        title: "عبارات تحفيزية للنجاح",
        type: "text",
        category: "motivational",
        duration: "",
        size: "0.7 MB",
        downloads: 1890,
        isFavorite: false,
        thumbnail:
            "https://images.unsplash.com/photo-1490730141103-6cac27aaab94?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80",
      ),
    ];
  }

  List<CategoryModel> getCategories() {
    return [
      CategoryModel(id: 1, name: "religious", icon: "mosque", count: 245),
      CategoryModel(id: 2, name: "romantic", icon: "heart", count: 189),
      CategoryModel(id: 3, name: "funny", icon: "face-laugh", count: 312),
      CategoryModel(
        id: 4,
        name: "sad",
        icon: "face-sad-tear",
        count: 156,
      ), // Added 'sad' to translations if missing
      CategoryModel(id: 5, name: "motivational", icon: "trophy", count: 278),
      CategoryModel(id: 6, name: "kids", icon: "child", count: 134),
      CategoryModel(id: 7, name: "occasions", icon: "gift", count: 98),
      CategoryModel(id: 8, name: "nature", icon: "tree", count: 167),
    ];
  }
}
