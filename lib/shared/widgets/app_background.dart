import 'package:flutter/material.dart';

/// Reusable full-bleed background widget that renders the app's signature
/// landscape background edge-to-edge with all corners and the decorative frame
/// pinned perfectly to the display without cropping.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({required this.child, super.key});

  static const AssetImage imageProvider =
      AssetImage('assets/images/dashboard_bg.png');

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Pinned to all 4 corners and full display so the frame is never cropped
        const Positioned.fill(
          child: RepaintBoundary(
            child: Image(
              image: imageProvider,
              fit: BoxFit.fill,
              alignment: Alignment.center,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              excludeFromSemantics: true,
            ),
          ),
        ),
        // Child content layered seamlessly above background
        child,
      ],
    );
  }
}
