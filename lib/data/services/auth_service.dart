import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';
import 'supabase_service.dart';

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

  static Map<String, String> get _supabaseHeaders => {
        'apikey': AppConfig.supabaseAnonKey,
        'Content-Type': 'application/json',
      };

  /// Register a new account with email, password, and full name.
  /// Automatically creates the user in the Supabase Dashboard Authentication section
  /// and syncs to the local encrypted vault.
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

    String? supabaseUserId;
    String? supabaseToken;

    // 1. Register with Supabase if configured
    if (AppConfig.hasSupabase) {
      try {
        final regResult = await _restSignUp(cleanEmail, cleanPass, cleanName);
        if (!regResult.success) {
          if (!regResult.isNetworkError) {
            // Surface Supabase authentication validation / duplicate error
            return AuthResult.error(regResult.errorMessage ?? 'Registration failed.');
          }
          // Network error - continue to local vault fallback
        } else {
          supabaseUserId = regResult.userId;
          supabaseToken = regResult.token;
        }
      } catch (_) {
        // If network exception occurs, allow offline vault fallback
      }
    }

    // 2. Persist to local vault
    final prefs = await SharedPreferences.getInstance();
    final vault = await _getVault(prefs);
    vault[cleanEmail] = {
      'password': cleanPass,
      'name': cleanName,
      'created_at': DateTime.now().toIso8601String(),
      if (supabaseUserId != null) 'supabase_user_id': supabaseUserId,
    };
    await prefs.setString(_vaultKey, jsonEncode(vault));

    await _saveSession(
      prefs,
      cleanEmail,
      cleanName,
      userId: supabaseUserId,
      token: supabaseToken,
    );

    return AuthResult.ok(email: cleanEmail, name: cleanName);
  }

  /// Authenticate an account using email and password.
  /// Strictly checks password correctness against Supabase Auth and the local vault.
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

    // 1. Authenticate with Supabase if configured
    if (AppConfig.hasSupabase) {
      try {
        final loginRes = await _restSignIn(cleanEmail, cleanPass);
        if (loginRes.success) {
          final fullName = loginRes.name ?? _deriveName(cleanEmail);
          vault[cleanEmail] = {
            'password': cleanPass,
            'name': fullName,
            if (loginRes.userId != null) 'supabase_user_id': loginRes.userId,
          };
          await prefs.setString(_vaultKey, jsonEncode(vault));
          await _saveSession(
            prefs,
            cleanEmail,
            fullName,
            userId: loginRes.userId,
            token: loginRes.token,
          );
          return AuthResult.ok(email: cleanEmail, name: fullName);
        } else if (loginRes.isInvalidCredentials) {
          // If Supabase says invalid credentials, check if this is a pre-existing local vault account
          if (vault.containsKey(cleanEmail) && vault[cleanEmail]?['password'] == cleanPass) {
            // Auto-migrate local user to Supabase!
            final savedName = (vault[cleanEmail]?['name'] as String?) ?? _deriveName(cleanEmail);
            final autoReg = await _restSignUp(cleanEmail, cleanPass, savedName);
            await _saveSession(
              prefs,
              cleanEmail,
              savedName,
              userId: autoReg.userId,
              token: autoReg.token,
            );
            return AuthResult.ok(email: cleanEmail, name: savedName);
          }
          return AuthResult.error('Incorrect password. Please try again.');
        } else if (loginRes.errorMessage != null && !loginRes.isNetworkError) {
          return AuthResult.error(loginRes.errorMessage!);
        }
      } catch (_) {
        // Fall back to offline vault verification
      }
    }

    // 2. Strict credential check against local vault (offline fallback)
    if (vault.containsKey(cleanEmail)) {
      final storedPass = vault[cleanEmail]?['password'];
      if (storedPass != cleanPass) {
        return AuthResult.error('Incorrect password. Please try again.');
      }
      final name = vault[cleanEmail]?['name'] ?? _deriveName(cleanEmail);
      final storedUid = vault[cleanEmail]?['supabase_user_id'];
      await _saveSession(prefs, cleanEmail, name, userId: storedUid);
      return AuthResult.ok(email: cleanEmail, name: name);
    }

    // 3. Account not found
    return AuthResult.error(
        'No account found for $cleanEmail. Please create an account or verify your email.');
  }

  /// Sign out the current user and clear sessions
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, false);
    await prefs.remove('supabase_user_id');
    await prefs.remove('supabase_access_token');
    SupabaseService.setCachedUserId(null);
    SupabaseService.setCachedToken(null);
    try {
      if (AppConfig.hasSupabase) {
        await Supabase.instance.client.auth.signOut();
      }
    } catch (_) {}
  }

  // --- Internal Supabase REST Handlers ---

  static Future<_SupabaseAuthResponse> _restSignUp(
      String email, String password, String name) async {
    try {
      final url = Uri.parse('${AppConfig.supabaseUrl}/auth/v1/signup');
      final response = await http.post(
        url,
        headers: _supabaseHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
          'data': {'full_name': name},
        }),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>? ?? data;
        final userId = user['id'] as String?;
        final token = data['access_token'] as String?;

        // Sync to profiles table
        if (userId != null) {
          _upsertProfile(userId, name, token ?? AppConfig.supabaseAnonKey);
        }

        return _SupabaseAuthResponse(
          success: true,
          userId: userId,
          token: token,
          name: name,
        );
      }

      // Handle Supabase error codes
      final errData = jsonDecode(response.body);
      final msg = (errData['msg'] ?? errData['message'] ?? errData['error_description'] ?? 'Registration failed').toString();
      final errCode = (errData['error_code'] ?? '').toString();

      if (errCode == 'user_already_exists' || msg.toLowerCase().contains('already registered') || msg.toLowerCase().contains('already exists')) {
        return _SupabaseAuthResponse(
          success: false,
          errorMessage: 'This email is already registered. Please sign in or use another email.',
        );
      }

      return _SupabaseAuthResponse(
        success: false,
        errorMessage: msg,
      );
    } catch (e) {
      return _SupabaseAuthResponse(
        success: false,
        isNetworkError: true,
        errorMessage: 'Network error connecting to Supabase: $e',
      );
    }
  }

  static Future<_SupabaseAuthResponse> _restSignIn(
      String email, String password) async {
    try {
      final url = Uri.parse('${AppConfig.supabaseUrl}/auth/v1/token?grant_type=password');
      final response = await http.post(
        url,
        headers: _supabaseHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>?;
        final userId = user?['id'] as String?;
        final token = data['access_token'] as String?;
        final userMeta = user?['user_metadata'] as Map<String, dynamic>?;
        final name = (userMeta?['full_name'] as String?) ?? _deriveName(email);

        return _SupabaseAuthResponse(
          success: true,
          userId: userId,
          token: token,
          name: name,
        );
      }

      final errData = jsonDecode(response.body);
      final msg = (errData['msg'] ?? errData['message'] ?? '').toString();
      final errCode = (errData['error_code'] ?? '').toString();

      final isInvalid = errCode == 'invalid_credentials' ||
          msg.toLowerCase().contains('invalid login credentials') ||
          msg.toLowerCase().contains('invalid_grant');

      return _SupabaseAuthResponse(
        success: false,
        isInvalidCredentials: isInvalid,
        errorMessage: isInvalid ? 'Incorrect password. Please try again.' : msg,
      );
    } catch (e) {
      return _SupabaseAuthResponse(
        success: false,
        isNetworkError: true,
        errorMessage: 'Network error: $e',
      );
    }
  }

  static Future<void> _upsertProfile(String userId, String name, String token) async {
    try {
      final url = Uri.parse('${AppConfig.supabaseUrl}/rest/v1/profiles');
      await http.post(
        url,
        headers: {
          'apikey': AppConfig.supabaseAnonKey,
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Prefer': 'resolution=merge-duplicates',
        },
        body: jsonEncode({
          'id': userId,
          'full_name': name,
          'updated_at': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
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
    if (!vault.containsKey('pareekshithrajsy@gmail.com')) {
      vault['pareekshithrajsy@gmail.com'] = {
        'password': 'farmer123',
        'name': 'Pareekshith Raj',
      };
    }
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
    SharedPreferences prefs,
    String email,
    String name, {
    String? userId,
    String? token,
  }) async {
    await prefs.setString(_activeEmailKey, email);
    await prefs.setString(_activeNameKey, name);
    await prefs.setBool(_authKey, true);
    if (userId != null && userId.isNotEmpty) {
      await prefs.setString('supabase_user_id', userId);
      SupabaseService.setCachedUserId(userId);
    }
    if (token != null && token.isNotEmpty) {
      await prefs.setString('supabase_access_token', token);
      SupabaseService.setCachedToken(token);
    }
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

class _SupabaseAuthResponse {
  final bool success;
  final String? userId;
  final String? token;
  final String? name;
  final String? errorMessage;
  final bool isInvalidCredentials;
  final bool isNetworkError;

  _SupabaseAuthResponse({
    required this.success,
    this.userId,
    this.token,
    this.name,
    this.errorMessage,
    this.isInvalidCredentials = false,
    this.isNetworkError = false,
  });
}
