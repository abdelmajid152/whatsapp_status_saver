import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'حفظ استوريهات الواتساب',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // GetX Configuration
      initialBinding: InitialBinding(),
      getPages: AppRoutes.routes,
      initialRoute: AppRoutes.home,

      // Localization settings for RTL support
      locale: const Locale('ar'),
      fallbackLocale: const Locale('en'),

      // Default transition
      defaultTransition: Transition.cupertino,
    );
  }
}
