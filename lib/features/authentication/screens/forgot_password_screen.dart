import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';
import '../../../shared/widgets/app_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _newPass = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _statusMessage;

  @override
  void dispose() {
    _email.dispose();
    _newPass.dispose();
    super.dispose();
  }

  Future<void> _resetPasswordAndLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _email.text.trim();
    final newPass = _newPass.text.trim();

    setState(() {
      _loading = true;
      _statusMessage = null;
    });

    final res = await AuthService.updatePassword(
      email: email,
      newPassword: newPass,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Password updated successfully! Welcome, ${res.name}.'),
              ),
            ],
          ),
          backgroundColor: AppColors.forestGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.errorMessage ?? 'Password reset failed. Please try again.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _sendEmailLink() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address first.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final res = await AuthService.sendSignInLinkToEmail(email);

    if (!mounted) return;
    setState(() {
      _loading = false;
      _statusMessage = res.success
          ? 'Authentication link sent to $email. Check your inbox to sign in passwordlessly.'
          : (res.errorMessage ?? 'Failed to send sign-in link.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Reset Password'),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.forestGreen,
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Card(
                color: Colors.white.withValues(alpha: 0.94),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter your email and create a new password to instantly regain access.',
                          style: TextStyle(color: AppColors.textMedium, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        if (_statusMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.paleGreen.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.mark_email_read, color: AppColors.forestGreen, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _statusMessage!,
                                    style: const TextStyle(
                                      color: AppColors.forestGreen,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Account Email',
                            hintText: 'e.g. farmer@gmail.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            final val = v?.trim() ?? '';
                            if (val.isEmpty || !val.contains('@') || !val.contains('.')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _newPass,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'New Password (min 6 chars)',
                            prefixIcon: const Icon(Icons.lock_reset),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            final val = v?.trim() ?? '';
                            if (val.isEmpty) return 'Enter your new password';
                            if (val.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loading ? null : _resetPasswordAndLogin,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: AppColors.forestGreen,
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Reset Password & Sign In'),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: _loading ? null : _sendEmailLink,
                          icon: const Icon(Icons.send, size: 16),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                            foregroundColor: AppColors.forestGreen,
                            side: const BorderSide(color: AppColors.forestGreen),
                          ),
                          label: const Text('Send Email Sign-In Link (Passwordless)'),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('Back to Sign In'),
                          ),
                        ),
                      ],
                    ),
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
