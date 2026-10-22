import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false, _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);

    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _pass.text.trim();

    try {
      if (AppConfig.hasSupabase) {
        try {
          await Supabase.instance.client.auth.signUp(
            email: email,
            password: password,
            data: {'full_name': name},
          );
        } on AuthException catch (e) {
          final msg = e.message.toLowerCase();
          final isNetworkError = msg.contains('socketexception') ||
              msg.contains('failed host lookup') ||
              msg.contains('network') ||
              msg.contains('clientexception') ||
              msg.contains('connection');

          if (!isNetworkError) {
            if (mounted) _showErr(e.message);
            return;
          }
          // Network issue: gracefully proceed in offline mode
        } catch (_) {
          // Network or server unreachable: continue locally
        }
      }

      // Save local user profile
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setBool('is_authenticated', true);

      if (mounted) context.go('/farm-setup');
    } catch (_) {
      if (mounted) _showErr('Registration failed. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showErr(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(m), backgroundColor: AppColors.errorRed));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), backgroundColor: Colors.transparent,
          foregroundColor: AppColors.forestGreen, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text('Join KrishiRitu AI', style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.forestGreen)),
                const SizedBox(height: 8),
                const Text('Create your farmer account', style: TextStyle(color: AppColors.textMedium)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v!.trim().isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) => v!.contains('@') ? null : 'Enter valid email',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pass,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password (min 6 chars)',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v!.length >= 6 ? null : 'Min 6 characters',
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Create Account'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Already have an account? Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
