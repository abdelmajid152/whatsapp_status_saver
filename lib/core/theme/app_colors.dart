import 'package:flutter/material.dart';

/// WhatsApp-themed color palette
class AppColors {
  AppColors._();

  // Primary Colors (WhatsApp Teal)
  static const Color primary = Color(0xFF128C7E);
  static const Color primaryLight = Color(0xFF25D366);
  static const Color primaryDark = Color(0xFF075E54);

  // Secondary Colors
  static const Color secondary = Color(0xFF525252);
  static const Color secondaryForeground = Color(0xFFFAFAFA);

  // Background Colors
  static const Color background = Color(0xFFECE5DD);
  static const Color backgroundDark = Color(0xFF171717);

  // Card Colors
  static const Color card = Color(0xFFFAFAFA);
  static const Color cardDark = Color(0xFF242424);

  // WhatsApp Specific
  static const Color whatsappGreen = Color(0xFF25D366);
  static const Color whatsappTeal = Color(0xFF075E54);
  static const Color whatsappLightGreen = Color(0xFFDCF8C6);
  static const Color whatsappChatBg = Color(0xFFECE5DD);

  // Text Colors
  static const Color textPrimary = Color(0xFF171717);
  static const Color textSecondary = Color(0xFF737373);
  static const Color textLight = Color(0xFFFAFAFA);

  // Muted Colors
  static const Color muted = Color(0xFFA1A1A1);
  static const Color mutedForeground = Color(0xFF171717);

  // Destructive
  static const Color destructive = Color(0xFFEF4444);

  // Border
  static const Color border = Color(0xFFD4D4D4);
  static const Color borderDark = Color(0xFF525252);

  // Gradient for status cards
  static const LinearGradient cardOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Colors.transparent,
      Color(0x99000000),
    ],
    stops: [0.0, 0.5, 1.0],
  );
}
