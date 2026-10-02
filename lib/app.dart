import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/strings.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_controller.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/settings/settings_controller.dart';
import 'features/shell/home_shell.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final onboarded = ref.watch(onboardingDoneProvider);
    return MaterialApp(
      onGenerateTitle: (context) => context.tr(Tr.appName),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: onboarded ? const HomeShell() : const OnboardingPage(),
    );
  }
}
