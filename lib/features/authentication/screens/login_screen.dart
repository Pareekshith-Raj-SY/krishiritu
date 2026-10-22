import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false, _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);

    final email = _email.text.trim();
    final password = _pass.text.trim();

    try {
      if (AppConfig.hasSupabase) {
        try {
          await Supabase.instance.client.auth.signInWithPassword(
            email: email,
            password: password,
          );
        } on AuthException catch (e) {
          final msg = e.message.toLowerCase();
          final isNetworkError = msg.contains('socketexception') ||
              msg.contains('failed host lookup') ||
              msg.contains('network') ||
              msg.contains('clientexception') ||
              msg.contains('connection');

          if (!isNetworkError) {
            if (mounted) _showError(e.message);
            return;
          }
          // Network issue: gracefully proceed in offline mode
        } catch (_) {
          // Network or server unreachable: continue locally
        }
      }

      // Save local authentication session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setBool('is_authenticated', true);

      if (mounted) context.go('/home');
    } catch (_) {
      if (mounted) _showError('Login failed. Please check your credentials.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.errorRed));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Text('🌿', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text('Welcome', style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.forestGreen)),
                const SizedBox(height: 8),
                const Text('Sign in to KrishiRitu AI', style: TextStyle(color: AppColors.textMedium)),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) => v!.contains('@') ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pass,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v!.length >= 6 ? null : 'Password too short',
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('Create Account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
