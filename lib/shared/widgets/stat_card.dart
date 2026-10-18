import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final Color? valueColor;
  final String? emoji;
  final VoidCallback? onTap;

  const StatCard({
    required this.label,
    required this.value,
    this.subtitle,
    this.valueColor,
    this.emoji,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null) Text(emoji!, style: const TextStyle(fontSize: 24)),
              if (emoji != null) const SizedBox(height: 8),
              Text(label, style: const TextStyle(
                  fontSize: 12, color: AppColors.textMedium, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800,
                  color: valueColor ?? AppColors.textDark)),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: const TextStyle(
                    fontSize: 11, color: AppColors.textLight)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;

  const InfoChip({required this.label, this.color, this.textColor, super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color ?? AppColors.paleGreen,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: textColor ?? AppColors.forestGreen)),
  );
}
