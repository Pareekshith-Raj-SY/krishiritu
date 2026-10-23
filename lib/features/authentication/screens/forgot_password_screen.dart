import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false, _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address'), backgroundColor: AppColors.errorRed));
      return;
    }
    setState(() => _loading = true);
    try {
      if (AppConfig.hasSupabase) {
        try {
          await Supabase.instance.client.auth.resetPasswordForEmail(email);
        } catch (_) {}
      }
      if (mounted) setState(() { _sent = true; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Reset Password'), backgroundColor: Colors.transparent,
            foregroundColor: AppColors.forestGreen, elevation: 0),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Card(
                color: Colors.white.withOpacity(0.92),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _sent
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📧', style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 24),
                            const Text('Reset email sent!', style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.forestGreen)),
                            const SizedBox(height: 12),
                            const Text('Check your email for a password reset link.',
                                textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMedium)),
                            const SizedBox(height: 32),
                            ElevatedButton(onPressed: () => context.go('/login'), child: const Text('Back to Login')),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            const Text('Forgot Password?', style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.forestGreen)),
                            const SizedBox(height: 12),
                            const Text("Enter your email and we'll send a reset link.",
                                style: TextStyle(color: AppColors.textMedium)),
                            const SizedBox(height: 28),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined)),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loading ? null : _reset,
                              child: _loading
                                  ? const SizedBox(width: 24, height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Send Reset Link'),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
