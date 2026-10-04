import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/platform/native_storage.dart';
import '../../core/widgets/snack.dart';
import '../media/data/media_item.dart';
import '../permissions/storage_access.dart';
import 'onboarding_controller.dart';

class _Step {
  const _Step(this.title, this.body, {this.icon});

  final Tr title;
  final Tr body;

  /// `null` shows the app logo.
  final AppIconData? icon;
}

const _steps = [
  _Step(Tr.onboardTitle1, Tr.onboardBody1),
  _Step(Tr.onboardTitle2, Tr.onboardBody2, icon: AppIcons.status),
  _Step(Tr.onboardTitle3, Tr.onboardBody3, icon: AppIcons.folderOpen),
];

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _page = PageController();
  // Only the dots and buttons listen; swiping doesn't rebuild the pages.
  final _index = ValueNotifier(0);

  bool get _isLast => _index.value == _steps.length - 1;

  @override
  void dispose() {
    _page.dispose();
    _index.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (!_isLast) {
      await _page.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    // Last step: grant the WhatsApp status folder, then enter the app.
    // A wrong folder keeps the user here to retry; cancelling moves on
    // (the Status tab offers the same button later).
    final result = await ref
        .read(storageAccessProvider(MediaSource.whatsapp).notifier)
        .request();
    if (!mounted) return;
    if (result == PickResult.wrong) {
      context.snack(Tr.wrongFolder, icon: AppIcons.error);
      return;
    }
    _finish();
  }

  void _finish() => ref.read(onboardingDoneProvider.notifier).complete();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: ValueListenableBuilder(
                valueListenable: _index,
                builder: (_, _, _) => AnimatedOpacity(
                  opacity: _isLast ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: _isLast ? null : _finish,
                    child: Text(context.tr(Tr.skip)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _steps.length,
                onPageChanged: (i) => _index.value = i,
                itemBuilder: (_, i) => _StepView(_steps[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ValueListenableBuilder(
                valueListenable: _index,
                builder: (context, index, _) => Column(
                  children: [
                    _Dots(count: _steps.length, index: index),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          context.tr(_isLast ? Tr.grantPermission : Tr.next),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepView extends StatelessWidget {
  const _StepView(this.step);

  final _Step step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Illustration(icon: step.icon),
          const SizedBox(height: 48),
          Text(
            context.tr(step.title),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            context.tr(step.body),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Concentric soft circles with the logo or an icon in the middle.
class _Illustration extends StatelessWidget {
  const _Illustration({this.icon});

  final AppIconData? icon;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    Widget ring(double size, double alpha) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withValues(alpha: alpha),
      ),
    );

    return SizedBox.square(
      dimension: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ring(260, 0.05),
          ring(200, 0.08),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: icon == null ? Colors.white : null,
              gradient: icon == null
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.green, AppColors.tealDark],
                    ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: icon == null
                ? Image.asset(
                    'assets/branding/icon_foreground.png',
                    width: 250,
                    height: 250,
                  )
                : HugeIcon(
                    icon: icon!,
                    color: Colors.white,
                    size: 64,
                    strokeWidth: 1.8,
                  ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index ? scheme.primary : scheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
