/// App Constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Status Saver';
  static const String appSubtitle = 'Save WhatsApp Statuses';

  // WhatsApp Paths
  static const String whatsappBasePath =
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp';
  static const String whatsappStatusPath = 'Media/.Statuses';
  static const String accountsFolder = 'accounts';

  // Supported Extensions
  static const List<String> imageExtensions = ['.jpg', '.jpeg', '.png'];
  static const List<String> videoExtensions = ['.mp4', '.mkv', '.mov'];

  // Grid Configuration
  static const int gridCrossAxisCount = 3;
  static const double gridSpacing = 8.0;
  static const double gridPadding = 12.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 400);

  // Status Card
  static const double statusCardAspectRatio = 3 / 4;
  static const double statusCardBorderRadius = 12.0;
}
