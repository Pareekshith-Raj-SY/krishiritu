import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    required this.title, this.actionLabel, this.onAction, super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Expanded(child: Text(title, style: const TextStyle(
          fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark))),
      if (actionLabel != null && onAction != null)
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero),
          child: Text(actionLabel!, style: const TextStyle(fontSize: 13)),
        ),
    ]),
  );
}

class DisclaimerCard extends StatelessWidget {
  final String text;
  final Color? color;

  const DisclaimerCard({required this.text, this.color, super.key});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: (color ?? AppColors.warmAmber).withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: (color ?? AppColors.warmAmber).withOpacity(0.3)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ℹ️', style: TextStyle(fontSize: 16)),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(
          fontSize: 12, color: AppColors.earthBrown, height: 1.5))),
    ]),
  );
}
