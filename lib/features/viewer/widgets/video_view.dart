import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../../media/data/media_item.dart';
import '../../media/widgets/media_thumbnail.dart';

/// Full-screen looping video player.
///
/// - Tap shows/hides controls (auto-hide after 3s while playing).
/// - Double-tap the start/end half to seek ∓10s.
/// - Pauses when the app goes to background.
///
/// Playback ticks only rebuild the small widgets that listen to the
/// controller (play icon, scrubber, time), never the whole page.
class VideoView extends StatefulWidget {
  const VideoView({super.key, required this.item});

  final MediaItem item;

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  static const _skip = Duration(seconds: 10);
  static const _hideAfter = Duration(seconds: 3);

  late final _controller = VideoPlayerController.file(File(widget.item.path));
  late final Future<void> _init = _controller.initialize().then((_) {
    _controller
      ..setLooping(true)
      ..play();
    _scheduleHide();
  });
  late final _lifecycle = AppLifecycleListener(onHide: _controller.pause);
  final _controlsVisible = ValueNotifier(true);
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _lifecycle.dispose();
    _controlsVisible.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_hideAfter, () {
      if (_controller.value.isPlaying) _controlsVisible.value = false;
    });
  }

  void _showControls() {
    _controlsVisible.value = true;
    _scheduleHide();
  }

  void _togglePlay() {
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
    _showControls();
  }

  void _seekBy(Duration offset) {
    final value = _controller.value;
    final target = value.position + offset;
    _controller.seekTo(
      target < Duration.zero
          ? Duration.zero
          : (target > value.duration ? value.duration : target),
    );
    _showControls();
  }

  void _toggleMute() {
    _controller.setVolume(_controller.value.volume == 0 ? 1 : 0);
    _showControls();
  }

  void _onDoubleTap(TapDownDetails details, double width) {
    final isStartHalf = details.localPosition.dx < width / 2;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // "Start" side seeks backward in both reading directions.
    _seekBy(isStartHalf != rtl ? -_skip : _skip);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const _VideoError();
        if (snapshot.connectionState != ConnectionState.done) {
          return Stack(
            fit: StackFit.expand,
            children: [
              MediaThumbnail(widget.item, fit: BoxFit.contain),
              const Center(
                child: CircularProgressIndicator(color: AppColors.green),
              ),
            ],
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            TapDownDetails? lastDoubleTap;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _controlsVisible.value
                  ? _controlsVisible.value = false
                  : _showControls(),
              onDoubleTapDown: (d) => lastDoubleTap = d,
              onDoubleTap: () =>
                  _onDoubleTap(lastDoubleTap!, constraints.maxWidth),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _controlsVisible,
                    builder: (_, visible, child) => IgnorePointer(
                      ignoring: !visible,
                      child: AnimatedOpacity(
                        opacity: visible ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: child,
                      ),
                    ),
                    child: _Controls(
                      controller: _controller,
                      onTogglePlay: _togglePlay,
                      onBack: () => _seekBy(-_skip),
                      onForward: () => _seekBy(_skip),
                      onToggleMute: _toggleMute,
                      onScrubbed: _showControls,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.controller,
    required this.onTogglePlay,
    required this.onBack,
    required this.onForward,
    required this.onToggleMute,
    required this.onScrubbed,
  });

  final VideoPlayerController controller;
  final VoidCallback onTogglePlay;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onToggleMute;
  final VoidCallback onScrubbed;

  static const _scrim = DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0, 0.25, 0.65, 1],
        colors: [
          Color(0x99000000),
          Colors.transparent,
          Colors.transparent,
          Color(0xCC000000),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _scrim,
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RoundButton(icon: AppIcons.back10, onTap: onBack),
              const SizedBox(width: 28),
              ValueListenableBuilder(
                valueListenable: controller,
                builder: (_, value, _) => _RoundButton(
                  icon: value.isPlaying ? AppIcons.pause : AppIcons.play,
                  onTap: onTogglePlay,
                  size: 72,
                  filled: true,
                ),
              ),
              const SizedBox(width: 28),
              _RoundButton(icon: AppIcons.forward10, onTap: onForward),
            ],
          ),
        ),
        PositionedDirectional(
          start: 12,
          end: 12,
          bottom: 8,
          child: _BottomBar(
            controller: controller,
            onToggleMute: onToggleMute,
            onScrubbed: onScrubbed,
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.controller,
    required this.onToggleMute,
    required this.onScrubbed,
  });

  final VideoPlayerController controller;
  final VoidCallback onToggleMute;
  final VoidCallback onScrubbed;

  static const _time = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 4, 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      // Video timeline always runs left-to-right, even in Arabic.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, value, _) => Row(
            children: [
              Text(_format(value.position), style: _time),
              Expanded(
                child: _Scrubber(
                  controller: controller,
                  position: value.position,
                  duration: value.duration,
                  onScrubbed: onScrubbed,
                ),
              ),
              Text(_format(value.duration), style: _time),
              IconButton(
                onPressed: onToggleMute,
                icon: HugeIcon(
                  icon: value.volume == 0 ? AppIcons.mute : AppIcons.volume,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Slider that follows the finger while dragging instead of fighting the
/// playback position, and seeks once on release.
class _Scrubber extends StatefulWidget {
  const _Scrubber({
    required this.controller,
    required this.position,
    required this.duration,
    required this.onScrubbed,
  });

  final VideoPlayerController controller;
  final Duration position;
  final Duration duration;
  final VoidCallback onScrubbed;

  @override
  State<_Scrubber> createState() => _ScrubberState();
}

class _ScrubberState extends State<_Scrubber> {
  double? _dragging;

  @override
  Widget build(BuildContext context) {
    final max = widget.duration.inMilliseconds.toDouble();
    final value =
        _dragging ?? widget.position.inMilliseconds.clamp(0, max).toDouble();

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        activeTrackColor: AppColors.green,
        inactiveTrackColor: Colors.white24,
        thumbColor: Colors.white,
        overlayColor: AppColors.green.withValues(alpha: 0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      ),
      child: Slider(
        value: value,
        max: max <= 0 ? 1 : max,
        onChangeStart: (v) => setState(() => _dragging = v),
        onChanged: (v) {
          setState(() => _dragging = v);
          widget.onScrubbed();
        },
        onChangeEnd: (v) async {
          await widget.controller.seekTo(Duration(milliseconds: v.round()));
          if (mounted) setState(() => _dragging = null);
        },
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.onTap,
    this.size = 52,
    this.filled = false,
  });

  final AppIconData icon;
  final VoidCallback onTap;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? null : Colors.black.withValues(alpha: 0.35),
        gradient: filled
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.green, AppColors.tealDark],
              )
            : null,
        boxShadow: filled
            ? [
                BoxShadow(
                  color: AppColors.green.withValues(alpha: 0.4),
                  blurRadius: 20,
                ),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: HugeIcon(
                icon: icon,
                color: Colors.white,
                size: size * 0.46,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoError extends StatelessWidget {
  const _VideoError();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: HugeIcon(
        icon: AppIcons.brokenVideo,
        color: Colors.white54,
        size: 48,
      ),
    );
  }
}
