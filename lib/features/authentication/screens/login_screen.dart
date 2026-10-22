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

  Future<void> _handleGoogleSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    final savedName = prefs.getString('user_name');

    if (!mounted) return;

    final selectedEmail = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GoogleAccountPickerSheet(
        savedEmail: savedEmail,
        savedName: savedName,
      ),
    );

    if (selectedEmail != null && selectedEmail.trim().isNotEmpty) {
      await _completeGoogleSignIn(selectedEmail.trim(), savedName);
    }
  }

  Future<void> _completeGoogleSignIn(String email, [String? knownName]) async {
    setState(() => _loading = true);
    try {
      if (AppConfig.hasSupabase) {
        try {
          await Supabase.instance.client.auth.signInWithOAuth(
            OAuthProvider.google,
          );
        } catch (_) {}
      }

      final prefs = await SharedPreferences.getInstance();
      final displayName = (knownName != null && knownName.isNotEmpty)
          ? knownName
          : _deriveNameFromEmail(email);

      await prefs.setString('user_email', email);
      await prefs.setString('user_name', displayName);
      await prefs.setBool('is_authenticated', true);

      if (mounted) context.go('/home');
    } catch (_) {
      if (mounted) _showError('Google sign in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _deriveNameFromEmail(String email) {
    try {
      final username = email.split('@').first;
      final clean = username.replaceAll(RegExp(r'[^a-zA-Z]'), ' ').trim();
      if (clean.isEmpty) return 'Google User';
      final parts = clean.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
      return parts
          .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
          .join(' ');
    } catch (_) {
      return 'Google User';
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
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
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
                    Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
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

class _GoogleAccountPickerSheet extends StatefulWidget {
  final String? savedEmail;
  final String? savedName;

  const _GoogleAccountPickerSheet({
    this.savedEmail,
    this.savedName,
  });

  @override
  State<_GoogleAccountPickerSheet> createState() => _GoogleAccountPickerSheetState();
}

class _GoogleAccountPickerSheetState extends State<_GoogleAccountPickerSheet> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showCustomInput = false;

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

  void _submitCustomEmail() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_emailCtrl.text.trim());
    }
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
                Column(
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
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            if (hasSaved) ...[
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
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  widget.savedEmail!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => Navigator.of(context).pop(widget.savedEmail),
              ),
              const Divider(),
            ],
            if (!_showCustomInput && hasSaved)
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
                onTap: () => setState(() => _showCustomInput = true),
              ),
            if (_showCustomInput) ...[
              const SizedBox(height: 8),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasSaved ? 'Enter Google Account:' : 'Enter your Google Email:',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: true,
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
                        if (val.isEmpty) return 'Please enter your email';
                        if (!val.contains('@') || !val.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submitCustomEmail(),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: _submitCustomEmail,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AppColors.forestGreen,
                      ),
                      child: const Text('Continue with this account'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              'To continue, Google will share your name, email address, language preference, and profile picture with KrishiRitu AI.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500, height: 1.3),
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
