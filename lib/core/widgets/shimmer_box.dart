import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Theme-aware shimmer. Wrap a whole group of [ShimmerBox.plain] boxes in
/// one [AppShimmer] so they share a single animation.
class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.brightness == Brightness.dark
          ? const Color(0xFF2A3942)
          : Colors.white,
      child: child,
    );
  }
}

/// A shimmering placeholder box.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.radius = 0}) : _animated = true;

  /// Static box, for use inside an existing [AppShimmer].
  const ShimmerBox.plain({super.key, this.radius = 0}) : _animated = false;

  final double radius;
  final bool _animated;

  @override
  Widget build(BuildContext context) {
    final box = DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: const SizedBox.expand(),
    );
    return _animated ? AppShimmer(child: box) : box;
  }
}
