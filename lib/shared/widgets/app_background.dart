import 'package:flutter/material.dart';

/// Reusable full-bleed background widget that renders the app's signature
/// landscape background edge-to-edge with all corners and display area visible.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image covering the full display
        Image.asset(
          'assets/images/dashboard_bg.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
          width: double.infinity,
          height: double.infinity,
        ),
        // Child content layered seamlessly above background
        child,
      ],
    );
  }
}
