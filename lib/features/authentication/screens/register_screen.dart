import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _email.text.trim(), password: _pass.text.trim(),
        data: {'full_name': _name.text.trim()});
      if (mounted) context.go('/farm-setup');
    } on AuthException catch (e) {
      if (mounted) _showErr(e.message);
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
