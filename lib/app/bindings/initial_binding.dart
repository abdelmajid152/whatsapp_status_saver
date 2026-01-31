import 'package:get/get.dart';
import '../../features/status/controllers/status_controller.dart';

/// Initial binding for app startup
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Register StatusController as a lazy singleton
    Get.lazyPut<StatusController>(() => StatusController(), fenix: true);
  }
}
