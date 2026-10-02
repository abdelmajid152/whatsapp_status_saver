import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_theme.dart';

/// Looping video with tap-to-pause. Position updates repaint only the
/// progress bar and play icon, never the whole page.
class VideoView extends StatefulWidget {
  const VideoView({super.key, required this.path});

  final String path;

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late final _controller = VideoPlayerController.file(File(widget.path));
  late final Future<void> _init = _controller
      .initialize()
      .then((_) => _controller
        ..setLooping(true)
        ..play());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() =>
      _controller.value.isPlaying ? _controller.pause() : _controller.play();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.white54),
          );
        }
        return GestureDetector(
          onTap: _toggle,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (_, value, _) => AnimatedOpacity(
                  opacity: value.isPlaying ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.black45,
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                start: 16,
                end: 16,
                bottom: 8,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  colors: const VideoProgressColors(
                    playedColor: AppColors.green,
                    bufferedColor: Colors.white38,
                    backgroundColor: Colors.white12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
