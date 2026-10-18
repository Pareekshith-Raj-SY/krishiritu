import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _tasks = [
    {'icon': '🌱', 'title': 'Kharif Sowing Window Open', 'desc': 'June–July is ideal for Ragi, Maize, and Groundnut in your district.', 'date': 'Jun 2025', 'type': 'season'},
    {'icon': '💧', 'title': 'First Irrigation Due', 'desc': 'If no significant rainfall in the past 10 days, irrigate your crop.', 'date': 'This week', 'type': 'task'},
    {'icon': '🔍', 'title': 'Pest Scouting Reminder', 'desc': 'Week 6–8 is critical for stem borer monitoring in Paddy and Maize.', 'date': 'This week', 'type': 'task'},
    {'icon': '📊', 'title': 'Rabi Season Preparation', 'desc': 'Start planning Rabi crops (Jowar, Bengal Gram) for October–November sowing.', 'date': 'Oct 2025', 'type': 'season'},
    {'icon': '🌾', 'title': 'Harvest Approaching', 'desc': 'Based on your sowing date, harvest window may begin soon. Arrange drying space.', 'date': 'Upcoming', 'type': 'harvest'},
    {'icon': '💰', 'title': 'MSP Notification', 'desc': 'Government MSP for Ragi is ₹3,846/quintal for 2024-25. Verify at nearest APMC.', 'date': 'Info', 'type': 'info'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Tasks & Notifications'),
        backgroundColor: AppColors.forestGreen,
      ),
      body: Column(children: [
        Container(
          color: AppColors.paleGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Row(children: [
            Icon(Icons.info_outline, size: 15, color: AppColors.leafGreen),
            SizedBox(width: 6),
            Expanded(child: Text(
              'Notifications are based on typical Karnataka crop calendars. '
              'Set up your farm profile for personalized reminders.',
              style: TextStyle(fontSize: 11, color: AppColors.forestGreen),
            )),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(task['icon']!, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(task['title']!, style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: _typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(task['date']!, style: TextStyle(
                    fontSize: 11, color: _typeColor, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 5),
            Text(task['desc']!,
                style: const TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.4)),
          ])),
        ]),
      ),
    );
  }
}
