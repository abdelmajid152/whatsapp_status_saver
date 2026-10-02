import 'package:flutter/material.dart';

import '../data/media_item.dart';
import 'media_thumbnail.dart';
import 'save_button.dart';

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
              const Center(
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0x66000000),
                  child: Icon(Icons.play_arrow_rounded, color: Colors.white),
                ),
              ),
            if (showSave)
              PositionedDirectional(
                bottom: 6,
                end: 6,
                child: SaveButton(item),
              ),
          ],
        ),
      ),
    );
  }
}
