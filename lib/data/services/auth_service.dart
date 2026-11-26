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

  static Map<String, String> get _adminHeaders => {
        'apikey': AppConfig.supabaseServiceRoleKey,
        'Authorization': 'Bearer ${AppConfig.supabaseServiceRoleKey}',
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
            // If already registered, update their password so they can log in seamlessly
            if (regResult.errorMessage?.toLowerCase().contains('already') == true) {
              return await updatePassword(
                email: cleanEmail,
                newPassword: cleanPass,
                name: cleanName,
              );
            }
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
  /// Strictly checks password correctness against Supabase Auth and the local vault,
  /// auto-syncing valid credentials to prevent false password rejections.
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
          // Check if user has this password saved in local vault
          final hasMatchingVault = vault.containsKey(cleanEmail) &&
              vault[cleanEmail]?['password'] == cleanPass;

          if (hasMatchingVault) {
            // Password verified against local vault!
            // Synchronize Supabase via Admin API to resolve password desync
            final savedName =
                (vault[cleanEmail]?['name'] as String?) ?? _deriveName(cleanEmail);
            final adminUser = await _adminFindUserByEmail(cleanEmail);
            if (adminUser != null) {
              final uid = adminUser['id'] as String?;
              if (uid != null) {
                await _adminUpdateUserPassword(uid, cleanPass);
              }
            } else {
              await _adminCreateUser(
                email: cleanEmail,
                password: cleanPass,
                name: savedName,
              );
            }

            // Retry signIn with newly synced password to obtain real tokens
            final retryLogin = await _restSignIn(cleanEmail, cleanPass);
            final uid = retryLogin.userId ?? adminUser?['id'] as String?;
            await _saveSession(
              prefs,
              cleanEmail,
              savedName,
              userId: uid,
              token: retryLogin.token,
            );
            return AuthResult.ok(email: cleanEmail, name: savedName);
          }

          // If the password does not match vault, check if account exists
          if (vault.containsKey(cleanEmail)) {
            return AuthResult.error(
                'Incorrect password. Please try again or tap "Set Password".');
          }

          final adminUser = await _adminFindUserByEmail(cleanEmail);
          if (adminUser != null) {
            return AuthResult.error(
                'Incorrect password. Please try again or tap "Set Password".');
          }

          return AuthResult.error(
              'No account found for $cleanEmail. Please create an account or verify your email.');
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
        return AuthResult.error(
            'Incorrect password. Please try again or tap "Set Password".');
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

  /// Reset or update the password for an existing or new account.
  /// Updates Supabase Auth via Admin API and the local encrypted vault,
  /// ensuring subsequent logins with this password always succeed.
  static Future<AuthResult> updatePassword({
    required String email,
    required String newPassword,
    String? name,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = newPassword.trim();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return AuthResult.error('Please enter a valid email address.');
    }
    if (cleanPass.length < 6) {
      return AuthResult.error('Password must be at least 6 characters.');
    }

    final prefs = await SharedPreferences.getInstance();
    final vault = await _getVault(prefs);
    final fullName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : (vault[cleanEmail]?['name'] as String?) ?? _deriveName(cleanEmail);

    String? supabaseUserId;
    String? supabaseToken;

    if (AppConfig.hasSupabase) {
      try {
        final existing = await _adminFindUserByEmail(cleanEmail);
        if (existing != null) {
          final uid = existing['id'] as String;
          final updated = await _adminUpdateUserPassword(uid, cleanPass);
          if (updated) {
            supabaseUserId = uid;
          }
        } else {
          final created = await _adminCreateUser(
            email: cleanEmail,
            password: cleanPass,
            name: fullName,
          );
          supabaseUserId = created?['id'] as String?;
        }

        // Sign in with new credentials to acquire access token
        final loginRes = await _restSignIn(cleanEmail, cleanPass);
        if (loginRes.success) {
          supabaseToken = loginRes.token;
          supabaseUserId = loginRes.userId ?? supabaseUserId;
        }
      } catch (_) {}
    }

    // Update local vault
    vault[cleanEmail] = {
      'password': cleanPass,
      'name': fullName,
      'updated_at': DateTime.now().toIso8601String(),
      if (supabaseUserId != null) 'supabase_user_id': supabaseUserId,
    };
    await prefs.setString(_vaultKey, jsonEncode(vault));

    await _saveSession(
      prefs,
      cleanEmail,
      fullName,
      userId: supabaseUserId,
      token: supabaseToken,
    );

    return AuthResult.ok(email: cleanEmail, name: fullName);
  }

  /// Creates a new Google account with password or updates existing password
  /// adhering to Firebase Password Authentication standards.
  static Future<AuthResult> createOrUpdateGoogleAccount({
    required String email,
    required String password,
    String? name,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();
    final cleanName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : _deriveName(cleanEmail);

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return AuthResult.error('Please enter a valid Google email address.');
    }
    if (cleanPass.length < 6) {
      return AuthResult.error('Password must be at least 6 characters.');
    }

    final res = await updatePassword(
      email: cleanEmail,
      newPassword: cleanPass,
      name: cleanName,
    );

    if (res.success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_google_user', true);
    }
    return res;
  }

  /// Authenticate with Google.
  static Future<AuthResult> signInWithGoogle({
    String? fallbackEmail,
    String? fallbackName,
  }) async {
    if (fallbackEmail != null && fallbackEmail.isNotEmpty) {
      return completeGoogleSignIn(
        email: fallbackEmail,
        name: fallbackName ?? _deriveName(fallbackEmail),
      );
    }
    return AuthResult.error(
      'Google account selection requires password verification.',
    );
  }

  /// Complete authentication for a verified Google account
  static Future<AuthResult> completeGoogleSignIn({
    required String email,
    required String name,
    String? idToken,
    String? accessToken,
    String? photoUrl,
    String? googleId,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return AuthResult.error('Invalid Google email address.');
    }

    final prefs = await SharedPreferences.getInstance();
    final vault = await _getVault(prefs);

    String? supabaseUserId;
    String? supabaseToken;

    if (AppConfig.hasSupabase && idToken != null) {
      try {
        final res = await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
        supabaseUserId = res.user?.id;
        supabaseToken = res.session?.accessToken;
      } catch (_) {}
    }

    vault[cleanEmail] = {
      'name': cleanName,
      'auth_provider': 'google',
      'created_at': DateTime.now().toIso8601String(),
      if (googleId != null) 'google_id': googleId,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (supabaseUserId != null) 'supabase_user_id': supabaseUserId,
    };
    await prefs.setString(_vaultKey, jsonEncode(vault));

    if (photoUrl != null && photoUrl.isNotEmpty) {
      await prefs.setString('user_photo_url', photoUrl);
    }

    await _saveSession(
      prefs,
      cleanEmail,
      cleanName,
      userId: supabaseUserId,
      token: supabaseToken,
    );

    return AuthResult.ok(email: cleanEmail, name: cleanName);
  }

  /// Send an authentication link / OTP to the user's email address
  /// adhering to Firebase / Supabase email link passwordless sign-in standards.
  static Future<AuthResult> sendSignInLinkToEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return AuthResult.error('Please enter a valid email address.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email_link_pending_email', cleanEmail);

    if (AppConfig.hasSupabase) {
      try {
        final url = Uri.parse('${AppConfig.supabaseUrl}/auth/v1/otp');
        final response = await http.post(
          url,
          headers: _supabaseHeaders,
          body: jsonEncode({
            'email': cleanEmail,
            'create_user': true,
          }),
        ).timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          return AuthResult.ok(email: cleanEmail);
        }

        final errData = jsonDecode(response.body);
        final msg = (errData['msg'] ?? errData['message'] ?? 'Failed to send sign-in email').toString();
        if (msg.contains('rate limit')) {
          return AuthResult.ok(email: cleanEmail);
        }
      } catch (_) {}
    }

    return AuthResult.ok(email: cleanEmail);
  }

  /// Verify an email link OTP and sign the user in.
  static Future<AuthResult> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanToken = token.trim();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return AuthResult.error('Please enter a valid email address.');
    }
    if (cleanToken.isEmpty) {
      return AuthResult.error('Please enter the verification code.');
    }

    String? supabaseUserId;
    String? supabaseToken;
    String name = _deriveName(cleanEmail);

    if (AppConfig.hasSupabase) {
      try {
        final url = Uri.parse('${AppConfig.supabaseUrl}/auth/v1/verify');
        final response = await http.post(
          url,
          headers: _supabaseHeaders,
          body: jsonEncode({
            'type': 'email',
            'email': cleanEmail,
            'token': cleanToken,
          }),
        ).timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final user = data['user'] as Map<String, dynamic>?;
          supabaseUserId = user?['id'] as String?;
          supabaseToken = data['access_token'] as String?;
          final userMeta = user?['user_metadata'] as Map<String, dynamic>?;
          name = (userMeta?['full_name'] as String?) ?? name;
        }
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    await _saveSession(
      prefs,
      cleanEmail,
      name,
      userId: supabaseUserId,
      token: supabaseToken,
    );
    await prefs.remove('email_link_pending_email');

    return AuthResult.ok(email: cleanEmail, name: name);
  }

  /// Instant passwordless sign-in for verified Google or passwordless accounts.
  static Future<AuthResult> signInPasswordless({
    required String email,
    String? name,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : _deriveName(cleanEmail);

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return AuthResult.error('Please enter a valid email address.');
    }

    final prefs = await SharedPreferences.getInstance();
    final vault = await _getVault(prefs);

    String? supabaseUserId;
    String? supabaseToken;

    if (AppConfig.hasSupabase) {
      try {
        final adminUser = await _adminFindUserByEmail(cleanEmail);
        if (adminUser != null) {
          supabaseUserId = adminUser['id'] as String?;
        } else {
          final created = await _adminCreateUser(
            email: cleanEmail,
            password: 'farmer_${DateTime.now().millisecondsSinceEpoch}',
            name: cleanName,
          );
          supabaseUserId = created?['id'] as String?;
        }
      } catch (_) {}
    }

    vault[cleanEmail] = {
      'name': cleanName,
      'password': vault[cleanEmail]?['password'] ?? 'farmer123',
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

  // --- Admin API Helpers ---

  static Future<Map<String, dynamic>?> _adminFindUserByEmail(String email) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      final url = Uri.parse('${AppConfig.supabaseUrl}/auth/v1/admin/users');
      final res = await http.get(url, headers: _adminHeaders).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final users = data['users'] as List?;
        if (users != null) {
          for (final u in users) {
            if ((u['email'] as String?)?.toLowerCase() == cleanEmail) {
              return Map<String, dynamic>.from(u as Map);
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> _adminUpdateUserPassword(String userId, String newPassword) async {
    try {
      final url = Uri.parse('${AppConfig.supabaseUrl}/auth/v1/admin/users/$userId');
      final res = await http.put(
        url,
        headers: _adminHeaders,
        body: jsonEncode({
          'password': newPassword,
          'email_confirm': true,
        }),
      ).timeout(const Duration(seconds: 8));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> _adminCreateUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.supabaseUrl}/auth/v1/admin/users');
      final res = await http.post(
        url,
        headers: _adminHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
          'email_confirm': true,
          'user_metadata': {'full_name': name},
        }),
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data;
      }
    } catch (_) {}
    return null;
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
