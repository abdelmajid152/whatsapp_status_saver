import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../nav_index.dart';

class NavItem {
  const NavItem(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final Tr label;
}

/// Floating bottom bar with a curved notch holding a glowing center button.
/// Expects exactly four items: two on each side of the notch.
class CurvedNavBar extends ConsumerWidget {
  const CurvedNavBar({super.key, required this.items, required this.onCenterTap});

  final List<NavItem> items;
  final VoidCallback onCenterTap;

  static const _barHeight = 70.0;
  static const _buttonSize = 58.0;
  static const _overlap = 26.0; // How far the button rises above the bar.
  static const _notchWidth = 136.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(navIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget item(int i) => Expanded(
          child: _NavButton(
            item: items[i],
            selected: current == i,
            onTap: () => ref.read(navIndexProvider.notifier).select(i),
          ),
        );

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: SizedBox(
        height: _barHeight + _overlap,
        child: Stack(
          children: [
            Positioned.fill(
              top: _overlap,
              child: CustomPaint(
                painter: _BarPainter(
                  fill: isDark ? AppColors.darkCard : Colors.white,
                  stroke: AppColors.green.withValues(alpha: isDark ? 0.7 : 0.5),
                  notchWidth: _notchWidth,
                  notchDepth: _buttonSize - _overlap + 8,
                ),
                child: Row(
                  children: [
                    item(0),
                    item(1),
                    const SizedBox(width: _notchWidth * 0.6),
                    item(2),
                    item(3),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: _CenterButton(size: _buttonSize, onTap: onCenterTap),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return InkResponse(
      onTap: onTap,
      radius: 36,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: selected
                  ? scheme.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              selected ? item.activeIcon : item.icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr(item.label),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterButton extends StatefulWidget {
  const _CenterButton({required this.size, required this.onTap});

  final double size;
  final VoidCallback onTap;

  @override
  State<_CenterButton> createState() => _CenterButtonState();
}

class _CenterButtonState extends State<_CenterButton> {
  double _turns = 0;

  void _tap() {
    setState(() => _turns += 1);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.tr(Tr.refresh),
      child: GestureDetector(
        onTap: _tap,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.green, AppColors.tealDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withValues(alpha: 0.45),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: AnimatedRotation(
            turns: _turns,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
            child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  const _BarPainter({
    required this.fill,
    required this.stroke,
    required this.notchWidth,
    required this.notchDepth,
  });

  final Color fill;
  final Color stroke;
  final double notchWidth;
  final double notchDepth;

  static const _radius = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, cx = w / 2;
    final half = notchWidth / 2;
    const r = Radius.circular(_radius);

    final path = Path()
      ..moveTo(0, _radius)
      ..arcToPoint(const Offset(_radius, 0), radius: r)
      ..lineTo(cx - half, 0)
      ..cubicTo(cx - half * 0.45, 0, cx - half * 0.6, notchDepth, cx, notchDepth)
      ..cubicTo(cx + half * 0.6, notchDepth, cx + half * 0.45, 0, cx + half, 0)
      ..lineTo(w - _radius, 0)
      ..arcToPoint(Offset(w, _radius), radius: r)
      ..lineTo(w, h - _radius)
      ..arcToPoint(Offset(w - _radius, h), radius: r)
      ..lineTo(_radius, h)
      ..arcToPoint(Offset(0, h - _radius), radius: r)
      ..close();

    canvas
      ..drawShadow(path, Colors.black, 8, false)
      ..drawPath(path, Paint()..color = fill)
      ..drawPath(
        path,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.fill != fill || old.stroke != stroke;
}
