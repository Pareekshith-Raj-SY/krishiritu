import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({this.message, super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const CircularProgressIndicator(color: AppColors.leafGreen),
      if (message != null) ...[
        const SizedBox(height: 16),
        Text(message!, style: const TextStyle(color: AppColors.textMedium)),
      ],
    ]),
  );
}

class EmptyStateWidget extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    required this.emoji, required this.title, required this.subtitle,
    this.actionLabel, this.onAction, super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(
            fontSize: 14, color: AppColors.textMedium), textAlign: TextAlign.center),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ]),
    ),
  );
}

class ErrorWidget2 extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorWidget2({required this.message, this.onRetry, super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('⚠️', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMedium)),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ]),
    ),
  );
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: AppColors.warmAmber,
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.wifi_off, size: 16, color: Colors.white),
      SizedBox(width: 8),
      Text('Offline Mode — showing cached data',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );
}
