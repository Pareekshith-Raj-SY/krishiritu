import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? email;
  final String? name;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.email,
    this.name,
  });

  factory AuthResult.ok({required String email, String? name}) =>
      AuthResult(success: true, email: email, name: name);

  factory AuthResult.error(String msg) =>
      AuthResult(success: false, errorMessage: msg);
}

class AuthService {
  static const _vaultKey = 'local_user_vault';
  static const _activeEmailKey = 'user_email';
  static const _activeNameKey = 'user_name';
  static const _authKey = 'is_authenticated';

  static bool get _hasLiveSupabase {
    try {
      return AppConfig.hasSupabase && Supabase.instance.client != null;
    } catch (_) {
      return false;
    }
  }

  /// Register a new account with email, password, and full name.
  static Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();
    final cleanName = name.trim();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return AuthResult.error('Please enter a valid email address.');
    }
    if (cleanPass.length < 6) {
      return AuthResult.error('Password must be at least 6 characters.');
    }

    // 1. Supabase integration when configured and initialized
    if (_hasLiveSupabase) {
      try {
        await Supabase.instance.client.auth.signUp(
          email: cleanEmail,
          password: cleanPass,
          data: {'full_name': cleanName},
        );
      } on AuthException catch (e) {
        final msg = e.message.toLowerCase();
        final isNetwork = msg.contains('socketexception') ||
            msg.contains('failed host lookup') ||
            msg.contains('network') ||
            msg.contains('connection');
        if (!isNetwork) {
          return AuthResult.error(e.message);
        }
      } catch (_) {}
    }

    // 2. Persist to local vault
    final prefs = await SharedPreferences.getInstance();
    final vault = await _getVault(prefs);
    vault[cleanEmail] = {
      'password': cleanPass,
      'name': cleanName,
      'created_at': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_vaultKey, jsonEncode(vault));

    await _saveSession(prefs, cleanEmail, cleanName);
    return AuthResult.ok(email: cleanEmail, name: cleanName);
  }

  /// Authenticate an account using email and password.
  /// Strictly checks password correctness against Supabase and the credential vault.
  static Future<AuthResult> signIn({
    required String email,
    required String password,
    bool isGoogleAuth = false,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return AuthResult.error('Please enter a valid email address.');
    }
    if (cleanPass.isEmpty) {
      return AuthResult.error('Please enter your password.');
    }
    if (cleanPass.length < 6) {
      return AuthResult.error('Password must be at least 6 characters.');
    }

    final prefs = await SharedPreferences.getInstance();
    final vault = await _getVault(prefs);

    // 1. Check with Supabase if active and initialized
    if (_hasLiveSupabase) {
      try {
        final res = await Supabase.instance.client.auth.signInWithPassword(
          email: cleanEmail,
          password: cleanPass,
        );

        if (res.user != null) {
          final fullName = (res.user?.userMetadata?['full_name'] as String?) ??
              _deriveName(cleanEmail);
          vault[cleanEmail] = {
            'password': cleanPass,
            'name': fullName,
          };
          await prefs.setString(_vaultKey, jsonEncode(vault));
          await _saveSession(prefs, cleanEmail, fullName);
          return AuthResult.ok(email: cleanEmail, name: fullName);
        }
      } on AuthException catch (e) {
        final msg = e.message.toLowerCase();
        final isNetwork = msg.contains('socketexception') ||
            msg.contains('failed host lookup') ||
            msg.contains('network') ||
            msg.contains('connection');

        if (!isNetwork) {
          if (msg.contains('invalid login credentials') ||
              msg.contains('invalid_grant') ||
              msg.contains('invalid password') ||
              msg.contains('invalid credentials')) {
            return AuthResult.error('Incorrect password. Please try again.');
          }
          return AuthResult.error(e.message);
        }
      } catch (_) {}
    }

    // 2. Strict credential check against local vault
    if (vault.containsKey(cleanEmail)) {
      final storedPass = vault[cleanEmail]?['password'];
      if (storedPass != cleanPass) {
        return AuthResult.error('Incorrect password. Please try again.');
      }
      final name = vault[cleanEmail]?['name'] ?? _deriveName(cleanEmail);
      await _saveSession(prefs, cleanEmail, name);
      return AuthResult.ok(email: cleanEmail, name: name);
    }

    // 3. For first-time Google Sign-In with a new email:
    if (isGoogleAuth) {
      final derivedName = _deriveName(cleanEmail);
      vault[cleanEmail] = {
        'password': cleanPass,
        'name': derivedName,
        'created_at': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_vaultKey, jsonEncode(vault));
      await _saveSession(prefs, cleanEmail, derivedName);
      return AuthResult.ok(email: cleanEmail, name: derivedName);
    }

    return AuthResult.error(
        'Account not found. Please create an account or verify your email.');
  }

  static Future<Map<String, dynamic>> _getVault(SharedPreferences prefs) async {
    final raw = prefs.getString(_vaultKey);
    Map<String, dynamic> vault = {};
    if (raw != null && raw.isNotEmpty) {
      try {
        vault = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {}
    }

    // Pre-seed default accounts with known passwords
    if (!vault.containsKey('farmer@gmail.com')) {
      vault['farmer@gmail.com'] = {
        'password': 'farmer123',
        'name': 'Karnataka Farmer',
      };
    }
    if (!vault.containsKey('krishiritu@farmer.com')) {
      vault['krishiritu@farmer.com'] = {
        'password': 'password123',
        'name': 'KrishiRitu User',
      };
    }

    return vault;
  }

  static Future<void> _saveSession(
      SharedPreferences prefs, String email, String name) async {
    await prefs.setString(_activeEmailKey, email);
    await prefs.setString(_activeNameKey, name);
    await prefs.setBool(_authKey, true);
  }

  static String _deriveName(String email) {
    try {
      final username = email.split('@').first;
      final clean = username.replaceAll(RegExp(r'[^a-zA-Z]'), ' ').trim();
      if (clean.isEmpty) return 'Farmer';
      final parts = clean.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
      return parts
          .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
          .join(' ');
    } catch (_) {
      return 'Farmer';
    }
  }
}
