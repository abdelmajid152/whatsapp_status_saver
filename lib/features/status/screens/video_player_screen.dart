import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';

/// Full-screen video player screen
class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final VoidCallback onSave;

  const VideoPlayerScreen({
    super.key,
    required this.videoPath,
    required this.onSave,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.file(File(widget.videoPath));
    try {
      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
      });
      _controller!.play();
      _controller!.addListener(_onVideoUpdate);
    } catch (e) {
      // Handle initialization error
    }
  }

  void _onVideoUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    setState(() {
      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
    });
  }

  void _seekForward() {
    if (_controller == null) return;
    final newPosition =
        _controller!.value.position + const Duration(seconds: 10);
    _controller!.seekTo(
      newPosition > _controller!.value.duration
          ? _controller!.value.duration
          : newPosition,
    );
  }

  void _seekBackward() {
    if (_controller == null) return;
    final newPosition =
        _controller!.value.position - const Duration(seconds: 10);
    _controller!.seekTo(
      newPosition < Duration.zero ? Duration.zero : newPosition,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('عرض الفيديو'),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                widget.onSave();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: _isInitialized
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _showControls = !_showControls;
                  });
                },
                child: Stack(
                  children: [
                    // Video player
                    Center(
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                    ),

                    // Controls overlay
                    if (_showControls) _buildControls(),
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
      ),
    );
  }

  Widget _buildControls() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Column(
          children: [
            const Spacer(),
            // Center play/pause controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.replay_10,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: _seekBackward,
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white,
                    size: 64,
                  ),
                  onPressed: _togglePlayPause,
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(
                    Icons.forward_10,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: _seekForward,
                ),
              ],
            ),
            const Spacer(),
            // Bottom progress bar and time
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  VideoProgressIndicator(
                    _controller!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: AppColors.primary,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDuration(_controller!.value.position),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Text(' / ', style: TextStyle(color: Colors.white)),
                      Text(
                        _formatDuration(_controller!.value.duration),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
