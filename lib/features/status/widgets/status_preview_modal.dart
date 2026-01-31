import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/status_item.dart';

/// Full-screen preview modal for viewing and saving statuses
class StatusPreviewModal extends StatefulWidget {
  final List<StatusItem> statuses;
  final int initialIndex;
  final Function(StatusItem) onSave;

  const StatusPreviewModal({
    super.key,
    required this.statuses,
    required this.initialIndex,
    required this.onSave,
  });

  @override
  State<StatusPreviewModal> createState() => _StatusPreviewModalState();
}

class _StatusPreviewModalState extends State<StatusPreviewModal> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  StatusItem get _currentStatus => widget.statuses[_currentIndex];

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.statuses.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image/Video PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.statuses.length,
            itemBuilder: (context, index) {
              final status = widget.statuses[index];
              return _buildMediaView(status);
            },
          ),

          // Top bar
          _buildTopBar(context),

          // Navigation arrows (for larger screens)
          if (MediaQuery.of(context).size.width > 600) ...[
            _buildNavigationArrow(
              isLeft: true,
              onTap: _goToPrevious,
              enabled: _currentIndex > 0,
            ),
            _buildNavigationArrow(
              isLeft: false,
              onTap: _goToNext,
              enabled: _currentIndex < widget.statuses.length - 1,
            ),
          ],

          // Timestamp badge
          _buildTimestampBadge(),

          // Bottom action bar
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildMediaView(StatusItem status) {
    if (status.isImage) {
      return InteractiveViewer(
        minScale: 1.0,
        maxScale: 3.0,
        child: Center(
          child: Image.file(
            File(status.path),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 80,
                ),
              );
            },
          ),
        ),
      );
    } else {
      // Video placeholder - actual video playback handled in VideoPlayerScreen
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap to play video',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
                Text(
                  '${_currentIndex + 1} / ${widget.statuses.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 48), // Spacer for centering
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationArrow({
    required bool isLeft,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: isLeft ? 8 : null,
      right: isLeft ? null : 8,
      child: Center(
        child: Opacity(
          opacity: enabled ? 1.0 : 0.3,
          child: Material(
            color: Colors.black.withValues(alpha: 0.3),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: enabled ? onTap : null,
              customBorder: const CircleBorder(),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  isLeft ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimestampBadge() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _currentStatus.formattedTimestamp,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: _buildSaveButton()),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final isSaved = _currentStatus.saved;

    return ElevatedButton.icon(
      onPressed: () => widget.onSave(_currentStatus),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSaved
            ? AppColors.primary.withValues(alpha: 0.8)
            : AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
      ),
      icon: Icon(isSaved ? Icons.check : Icons.download, size: 24),
      label: Text(
        isSaved ? 'Saved' : 'Save Status',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}
