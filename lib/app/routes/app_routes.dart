import 'package:get/get.dart';
import '../../features/status/screens/home_screen.dart';

/// App route definitions
class AppRoutes {
  AppRoutes._();

  // Route names
  static const String home = '/';

  // GetPages
  static final List<GetPage> routes = [
    GetPage(name: home, page: () => const HomeScreen()),
  ];
}
