import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';
import '../../../shared/widgets/app_background.dart';

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
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLocal = prefs.getBool('is_authenticated') == true;
      final isSupa = AppConfig.hasSupabase &&
          Supabase.instance.client.auth.currentSession != null;
      if ((isLocal || isSupa) && mounted) {
        context.go('/home');
      }
    } catch (_) {}
  }

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

    final result = await AuthService.signIn(
      email: email,
      password: password,
      isGoogleAuth: false,
    );

    if (mounted) {
      setState(() => _loading = false);
      if (result.success) {
        context.go('/home');
      } else {
        _showError(result.errorMessage ?? 'Invalid email or password.');
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);

    try {
      final result = await AuthService.signInWithGoogle();

      if (!mounted) return;
      setState(() => _loading = false);

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Welcome, ${result.name}! Signed in with Google.'),
                ),
              ],
            ),
            backgroundColor: AppColors.forestGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/home');
      } else {
        if (result.errorMessage != null &&
            result.errorMessage!.contains('cancelled')) {
          return;
        }

        // Show account chooser sheet if Google Play services needs fallback
        await _showGoogleAccountPicker();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        await _showGoogleAccountPicker();
      }
    }
  }

  Future<void> _showGoogleAccountPicker() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    final savedName = prefs.getString('user_name');

    if (!mounted) return;

    final result = await showModalBottomSheet<AuthResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GoogleAccountChooserSheet(
        savedEmail: savedEmail,
        savedName: savedName,
      ),
    );

    if (result != null && result.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Welcome, ${result.name}! Signed in with Google.'),
              ),
            ],
          ),
          backgroundColor: AppColors.forestGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/home');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.errorRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Card(
                color: Colors.white.withValues(alpha: 0.92),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text('🌿', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text('Welcome',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestGreen)),
                const SizedBox(height: 8),
                const Text('Sign in to KrishiRitu AI',
                    style: TextStyle(color: AppColors.textMedium)),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'Enter a valid email',
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
                  validator: (v) =>
                      v != null && v.length >= 6 ? null : 'Password too short',
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
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(
                        child: Divider(color: AppColors.divider, thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: AppColors.textMedium,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(color: AppColors.divider, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: _loading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GoogleIcon(size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
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
    ),
  ),
),
),
);
  }
}

class _GoogleIcon extends StatelessWidget {
  final double size;
  const _GoogleIcon({this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/google.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: size,
          height: size,
          child: const Center(
            child: Text(
              'G',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Color(0xFF4285F4),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GoogleAccountChooserSheet extends StatefulWidget {
  final String? savedEmail;
  final String? savedName;

  const _GoogleAccountChooserSheet({
    this.savedEmail,
    this.savedName,
  });

  @override
  State<_GoogleAccountChooserSheet> createState() =>
      _GoogleAccountChooserSheetState();
}

class _GoogleAccountChooserSheetState extends State<_GoogleAccountChooserSheet> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showCustomInput = false;
  bool _isSigningIn = false;
  String? _signingInEmail;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    if (widget.savedEmail == null || widget.savedEmail!.isEmpty) {
      _showCustomInput = true;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _completeSignIn({
    required String email,
    String? displayName,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    setState(() {
      _isSigningIn = true;
      _signingInEmail = cleanEmail;
      _inlineError = null;
    });

    final result = await AuthService.completeGoogleSignIn(
      email: cleanEmail,
      name: displayName ?? cleanEmail.split('@').first,
    );

    if (!mounted) return;

    if (result.success) {
      Navigator.of(context).pop(result);
    } else {
      setState(() {
        _isSigningIn = false;
        _signingInEmail = null;
        _inlineError =
            result.errorMessage ?? 'Google Sign-In failed. Please try again.';
      });
    }
  }

  void _submitCustomEmail() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailCtrl.text.trim();
    _completeSignIn(
      email: email,
      displayName: email.split('@').first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasSaved = widget.savedEmail != null && widget.savedEmail!.isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: bottomInset + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const _GoogleIcon(size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Choose an account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'to continue to KrishiRitu AI',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            if (_inlineError != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.errorRed, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _inlineError!,
                        style: const TextStyle(
                          color: AppColors.errorRed,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (hasSaved && !_showCustomInput) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  child: Text(
                    (widget.savedName?.isNotEmpty == true
                            ? widget.savedName![0]
                            : widget.savedEmail![0])
                        .toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  widget.savedName?.isNotEmpty == true
                      ? widget.savedName!
                      : 'Google User',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  widget.savedEmail!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                trailing: _isSigningIn && _signingInEmail == widget.savedEmail
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: _isSigningIn
                    ? null
                    : () => _completeSignIn(
                          email: widget.savedEmail!,
                          displayName: widget.savedName,
                        ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: AppColors.textDark,
                  child: const Icon(Icons.person_add_alt_1_outlined, size: 20),
                ),
                title: const Text(
                  'Use another account',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Sign in with a different Google email',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: _isSigningIn
                    ? null
                    : () => setState(() {
                          _showCustomInput = true;
                          _emailCtrl.clear();
                          _inlineError = null;
                        }),
              ),
            ],

            if (_showCustomInput) ...[
              const SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Google Email address:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: true,
                      enabled: !_isSigningIn,
                      decoration: InputDecoration(
                        hintText: 'e.g. farmer@gmail.com',
                        prefixIcon: const Icon(Icons.alternate_email),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _emailCtrl.clear(),
                        ),
                      ),
                      validator: (v) {
                        final val = v?.trim() ?? '';
                        if (val.isEmpty) return 'Please enter your Google email';
                        if (!val.contains('@') || !val.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submitCustomEmail(),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _isSigningIn ? null : _submitCustomEmail,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AppColors.forestGreen,
                      ),
                      child: _isSigningIn
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Continue with Google'),
                    ),
                    if (hasSaved) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: _isSigningIn
                              ? null
                              : () => setState(() {
                                    _showCustomInput = false;
                                    _inlineError = null;
                                  }),
                          child: const Text('Back to saved accounts'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 18),
            Text(
              'To continue, Google will share your name, email address, language preference, and profile picture with KrishiRitu AI.',
              style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade500, height: 1.3),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
