import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/localization/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _tasks = [
    {'icon': '🌱', 'title': 'Kharif Sowing Window Open', 'desc': 'June–July is ideal for Ragi, Paddy, Maize, Groundnut, Sugarcane, Sericulture, and Flower crops.', 'date': 'Jun 2025', 'type': 'season'},
    {'icon': '🐛', 'title': 'Sericulture Batch Prep', 'desc': 'Complete rearing house disinfection with 2% bleach solution and check Uzi fly nets.', 'date': 'This week', 'type': 'task'},
    {'icon': '🌼', 'title': 'Marigold & Flower Pinching', 'desc': 'Pinch terminal shoots 25-30 days after transplanting to stimulate branching for Dasara/Diwali harvest.', 'date': 'Week 4', 'type': 'task'},
    {'icon': '🎋', 'title': 'Sugarcane Earthing Up Alert', 'desc': 'Perform first earthing up and detrash lower dried leaves to conserve soil moisture.', 'date': 'Month 2', 'type': 'task'},
    {'icon': '💧', 'title': 'First Irrigation Due', 'desc': 'If no significant rainfall in the past 10 days, irrigate your crop.', 'date': 'This week', 'type': 'task'},
    {'icon': '🔍', 'title': 'Pest Scouting Reminder', 'desc': 'Week 6–8 is critical for stem borer in Paddy/Maize and bud borer in Flowers.', 'date': 'This week', 'type': 'task'},
    {'icon': '📊', 'title': 'Rabi Season Preparation', 'desc': 'Start planning Rabi crops (Jowar, Bengal Gram, Chrysanthemum) for October–November sowing.', 'date': 'Oct 2025', 'type': 'season'},
    {'icon': '🌾', 'title': 'Harvest Approaching', 'desc': 'Based on your sowing date, harvest window may begin soon. Arrange drying and market crates.', 'date': 'Upcoming', 'type': 'harvest'},
    {'icon': '💰', 'title': 'MSP & Market Rate Alert', 'desc': 'Government MSP for Ragi is ₹3,846/quintal. Check live cocoon prices at Ramanagara APMC.', 'date': 'Info', 'type': 'info'},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.t('tasks_and_notifications')),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.forestGreen,
        elevation: 0,
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.leafGreen.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 15, color: AppColors.leafGreen),
            const SizedBox(width: 6),
            Expanded(child: Text(
              l10n.t('notifications_notice'),
              style: const TextStyle(fontSize: 11, color: AppColors.forestGreen),
            )),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
            itemCount: _tasks.length,
            itemBuilder: (_, i) => _TaskCard(task: _tasks[i]),
          ),
        ),
      ]),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Map<String, String> task;
  const _TaskCard({required this.task});

  Color get _typeColor {
    switch (task['type']) {
      case 'season': return AppColors.leafGreen;
      case 'task': return AppColors.skyBlue;
      case 'harvest': return AppColors.warmAmber;
      default: return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      color: Colors.white.withOpacity(0.92),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(task['icon']!, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(l10n.translateTaskTitle(task['title']!), style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: _typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(l10n.translateTaskDate(task['date']!), style: TextStyle(
                    fontSize: 11, color: _typeColor, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 5),
            Text(l10n.translateTaskDesc(task['desc']!),
                style: const TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.4)),
          ])),
        ]),
      ),
    );
  }
}
