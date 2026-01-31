import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/status_item.dart';

/// Status card widget displaying a single status item
class StatusCard extends StatelessWidget {
  final StatusItem status;
  final VoidCallback onTap;
  final VoidCallback? onDownload;

  const StatusCard({
    super.key,
    required this.status,
    required this.onTap,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            AppConstants.statusCardBorderRadius,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            AppConstants.statusCardBorderRadius,
          ),
          child: AspectRatio(
            aspectRatio: AppConstants.statusCardAspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail
                _buildThumbnail(),

                // Gradient overlay
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.cardOverlayGradient,
                  ),
                ),

                // Video play icon
                if (status.isVideo) _buildPlayIcon(),

                // Saved indicator
                if (status.saved) _buildSavedIndicator(),

                // Bottom info bar
                _buildBottomInfo(),

                // Download button
                if (onDownload != null) _buildDownloadButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (status.isImage) {
      return Image.file(
        File(status.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.muted,
            child: const Icon(
              Icons.broken_image,
              color: Colors.white54,
              size: 40,
            ),
          );
        },
      );
    } else {
      // For videos, show a dark placeholder with icon
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Icon(Icons.videocam, color: Colors.white38, size: 40),
        ),
      );
    }
  }

  Widget _buildPlayIcon() {
    return Center(
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildSavedIndicator() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status.formattedTimestamp,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (status.isVideo && status.duration != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status.duration!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Positioned(
      bottom: 8,
      left: 8,
      child: GestureDetector(
        onTap: onDownload,
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.download, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
