import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/prefs.dart';

/// Whether the user finished onboarding (persisted).
final onboardingDoneProvider = NotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);

class OnboardingController extends Notifier<bool> {
  static const _key = 'onboarding_done';

  @override
  bool build() => ref.watch(prefsProvider).getBool(_key) ?? false;

  void complete() {
    ref.read(prefsProvider).setBool(_key, true);
    state = true;
  }
}
