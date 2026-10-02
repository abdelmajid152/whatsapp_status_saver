import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/widgets/app_icons.dart';
import '../data/media_item.dart';
import 'media_thumbnail.dart';
import 'save_button.dart';
import 'share_button.dart';

class MediaTile extends StatelessWidget {
  const MediaTile({
    super.key,
    required this.item,
    required this.showSave,
    required this.onTap,
  });

  final MediaItem item;
  final bool showSave;
  final VoidCallback onTap;

  static const _shade = DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.55, 1],
        colors: [Colors.transparent, Color(0x99000000)],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MediaThumbnail(item),
            _shade,
            if (item.isVideo)
              const PositionedDirectional(
                top: 6,
                start: 6,
                child: _VideoBadge(),
              ),
            PositionedDirectional(
              bottom: 6,
              start: 6,
              child: ShareButton(item),
            ),
            if (showSave)
              PositionedDirectional(bottom: 6, end: 6, child: SaveButton(item)),
          ],
        ),
      ),
    );
  }
}

class _VideoBadge extends StatelessWidget {
  const _VideoBadge();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Color(0x80000000),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: HugeIcon(icon: AppIcons.play, color: Colors.white, size: 14),
      ),
    );
  }
}
