import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../app.dart';
import '../../farms/providers/farm_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final farm = ref.watch(farmProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Settings & Profile'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.forestGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // Profile header
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [AppColors.forestGreen.withOpacity(0.88), AppColors.leafGreen.withOpacity(0.88)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Row(children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Center(child: Text('👨‍🌾', style: TextStyle(fontSize: 32))),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(farm?.name ?? 'Farmer', style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                Text(farm?.district ?? 'Set up your farm profile',
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
              ])),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => context.push('/farm-profile'),
              ),
            ]),
          ),
          const SizedBox(height: 4),

          // Language
          _SettingsSection(title: 'Language / ಭಾಷೆ', children: [
            _SettingsTile(
              icon: Icons.language,
              title: 'App Language',
              subtitle: locale.languageCode == 'kn' ? 'ಕನ್ನಡ' : 'English',
              trailing: Switch(
                value: locale.languageCode == 'kn',
                activeColor: AppColors.leafGreen,
                onChanged: (v) {
                  ref.read(localeProvider.notifier).state =
                      v ? const Locale('kn') : const Locale('en');
                },
              ),
            ),
          ]),

          // Farm
          _SettingsSection(title: 'Farm', children: [
            _SettingsTile(
              icon: Icons.agriculture,
              title: 'Farm Profile',
              subtitle: 'Update farm details, soil, and crop',
              onTap: () => context.push('/farm-profile'),
            ),
            _SettingsTile(
              icon: Icons.history,
              title: 'Season Memory',
              subtitle: 'View and add season records',
              onTap: () => context.push('/history'),
            ),
          ]),

          // Features
          _SettingsSection(title: 'Features', children: [
            _SettingsTile(
              icon: Icons.cloud,
              title: 'Weather API',
              subtitle: AppConfig.hasWeather ? 'Configured ✓' : 'Add key to .env',
              trailing: Icon(AppConfig.hasWeather ? Icons.check_circle : Icons.warning_amber,
                  color: AppConfig.hasWeather ? AppColors.leafGreen : AppColors.warmAmber),
            ),
            _SettingsTile(
              icon: Icons.auto_awesome,
              title: 'AI Assistant',
              subtitle: AppConfig.hasAI ? 'Configured ✓' : 'Add key to .env',
              trailing: Icon(AppConfig.hasAI ? Icons.check_circle : Icons.warning_amber,
                  color: AppConfig.hasAI ? AppColors.leafGreen : AppColors.warmAmber),
            ),
            _SettingsTile(
              icon: Icons.storage,
              title: 'Supabase Sync',
              subtitle: AppConfig.hasSupabase ? 'Connected ✓' : 'Add credentials to .env',
              trailing: Icon(AppConfig.hasSupabase ? Icons.check_circle : Icons.warning_amber,
                  color: AppConfig.hasSupabase ? AppColors.leafGreen : AppColors.warmAmber),
            ),
          ]),

          // About
          _SettingsSection(title: 'About', children: [
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: 'KrishiRitu AI v${AppConfig.appVersion}',
            ),
            _SettingsTile(
              icon: Icons.verified_user_outlined,
              title: 'Data Disclaimer',
              subtitle: 'Crop data is illustrative. Verify with local KVK.',
              onTap: () => _showDisclaimer(context),
            ),
            _SettingsTile(
              icon: Icons.logout,
              title: 'Sign Out',
              subtitle: 'Return to login',
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('is_authenticated', false);
                if (AppConfig.hasSupabase) {
                  try {
                    await Supabase.instance.client.auth.signOut();
                  } catch (_) {}
                }
                if (context.mounted) context.go('/login');
              },
              color: AppColors.errorRed,
            ),
          ]),
          const SizedBox(height: 90),
        ]),
      ),
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Data Disclaimer'),
        content: const Text(
          'KrishiRitu AI provides crop recommendations and planning tools based on '
          'publicly available agricultural extension data from KSDA, ICAR, and UAS publications.\n\n'
          'All cost estimates, yield projections, and seasonal recommendations are '
          'illustrative and should be verified with your nearest Krishi Vigyan Kendra (KVK) '
          'or local agricultural extension officer before making farming decisions.\n\n'
          'The app does not guarantee crop outcomes, market prices, or weather predictions.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Understood')),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
        child: Text(title, style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w800,
            color: AppColors.forestGreen, letterSpacing: 1.0)),
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(children: children),
        ),
      ),
    ]);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;
  const _SettingsTile({
    required this.icon, required this.title, required this.subtitle,
    this.trailing, this.onTap, this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.leafGreen),
      title: Text(title, style: TextStyle(
          fontWeight: FontWeight.w600, color: color ?? AppColors.textDark)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: AppColors.textLight) : null),
      onTap: onTap,
    );
  }
}
