# 📱 WhatsApp Status Saver

A beautiful Flutter application to view and save WhatsApp statuses (images and videos) directly to your device.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

- 🖼️ **View Images** - Browse all WhatsApp status images
- 🎬 **View Videos** - Watch WhatsApp status videos with built-in player
- 💾 **Save Statuses** - Download statuses directly to your gallery
- 🌙 **Dark/Light Theme** - Beautiful WhatsApp-inspired themes
- 🌍 **Multi-language** - Supports English and Arabic
- 📱 **Multiple WhatsApp Support** - Works with WhatsApp & WhatsApp Business

## 📸 Screenshots

<!-- Add your screenshots here -->
| Home Screen | Video Player | Saved Statuses |
|:-----------:|:------------:|:--------------:|
| Coming Soon | Coming Soon  | Coming Soon    |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x or higher
- Dart 3.x or higher
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/abdelmajid152/whatsapp_status_saver.git
   ```

2. **Navigate to the project directory**
   ```bash
   cd whatsapp_status_saver
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

This project follows a **feature-based architecture** with GetX for state management:

```
lib/
├── app/
│   ├── bindings/          # Dependency injection
│   └── routes/            # App navigation routes
├── core/
│   ├── constants/         # App constants
│   ├── models/            # Data models
│   ├── services/          # Core services
│   ├── theme/             # App theming
│   ├── translations/      # Localization
│   └── utils/             # Utility functions
├── data/
│   ├── models/            # Data layer models
│   └── services/          # Data services
├── features/
│   └── status/
│       ├── controllers/   # GetX controllers
│       ├── screens/       # UI screens
│       └── widgets/       # Reusable widgets
└── main.dart
```

## 📦 Dependencies

| Package | Description |
|---------|-------------|
| `get` | State management & navigation |
| `video_player` | Video playback |
| `permission_handler` | Runtime permissions |
| `path_provider` | File system access |
| `share_plus` | Share functionality |

## 📋 Permissions Required

- **Storage Permission** - To access WhatsApp status files
- **Manage External Storage** - For Android 11+ devices

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Abdelmajid**

- GitHub: [@abdelmajid152](https://github.com/abdelmajid152)

---

<p align="center">Made with ❤️ using Flutter</p>
