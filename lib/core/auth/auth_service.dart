import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

const Duration _kRequestTimeout = Duration(seconds: 12);
const String _kAccessTokenKey = 'auth_access_token';
const String _kRefreshTokenKey = 'auth_refresh_token';
const String _kUserJsonKey = 'auth_user_json';
const String _kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);
const String _kGoogleServerClientId = String.fromEnvironment(
  'GOOGLE_WEB_CLIENT_ID',
);
const String _kAppleServiceId = String.fromEnvironment('APPLE_SERVICE_ID');
const String _kAppleRedirectUri = String.fromEnvironment('APPLE_REDIRECT_URI');

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final StreamController<AuthUser?> _authController =
      StreamController<AuthUser?>.broadcast();
  final http.Client _httpClient = http.Client();

  bool _initialized = false;
  bool _googleSignInConfigured = false;
  AuthSession? _session;

  Future<bool> initialize() async {
    if (_initialized) return _session != null;
    _initialized = true;
    final persisted = await _loadSessionFromStorage();
    _session = persisted;
    _authController.add(_session?.user);
    return _session != null;
  }

  Stream<AuthUser?> get authStateChanges => _authController.stream;
  AuthUser? get currentUser => _session?.user;
  bool get isAuthenticated => _session != null;

  Future<Map<String, dynamic>?> getPersistedUserData() async {
    final raw = await _secureStorage.read(key: _kUserJsonKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final payload = <String, dynamic>{
      'email': email.trim(),
      'password': password,
    };
    final response = await _post(
      '/auth/login',
      payload,
      includeAccessToken: false,
    );
    return _persistSessionFromResponse(response);
  }

  Future<AuthSession> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String profileEmoji,
    required String gender,
    required int birthYear,
    required String registrationTicket,
  }) async {
    final payload = <String, dynamic>{
      'email': email.trim(),
      'password': password,
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'profileEmoji': profileEmoji,
      'gender': gender,
      'birthYear': birthYear,
      'registrationTicket': registrationTicket,
    };
    final response = await _post(
      '/auth/register',
      payload,
      includeAccessToken: false,
    );
    return _persistSessionFromResponse(response);
  }

  Future<String?> sendEmailOtp(String email) async {
    final response = await _post('/auth/email-otp/send', {
      'email': email.trim(),
    }, includeAccessToken: false);
    final devCode = response['devEmailVerificationCode']?.toString();
    return devCode?.isEmpty == true ? null : devCode;
  }

  Future<void> sendVerificationEmail() async {
    await _post('/auth/verify-email/send', {});
  }

  Future<void> sendPasswordReset(String email) async {
    await _post('/auth/forgot-password', {
      'email': email.trim(),
    }, includeAccessToken: false);
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _post('/auth/reset-password', {
      'token': token,
      'newPassword': newPassword,
    }, includeAccessToken: false);
  }

  Future<String> verifyEmail({
    required String email,
    required String code,
  }) async {
    final response = await _post('/auth/verify-email', {
      'email': email.trim(),
      'code': code.trim(),
    }, includeAccessToken: false);
    return (response['registrationTicket'] ?? '').toString();
  }

  Future<AuthSession> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      if (!_googleSignInConfigured) {
        await googleSignIn.initialize(
          serverClientId: _kGoogleServerClientId.isEmpty
              ? null
              : _kGoogleServerClientId,
        );
        _googleSignInConfigured = true;
      }
      final googleUser = await googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthException(
          'Google setup is incomplete. Add Android SHA-1/SHA-256 and web client ID.',
        );
      }
      final response = await _post('/auth/google', {
        'idToken': idToken,
      }, includeAccessToken: false);
      return _persistSessionFromResponse(response);
    } on AuthException {
      rethrow;
    } catch (e) {
      final text = e.toString();
      if (text.contains('ApiException: 10') ||
          text.contains('sign_in_failed')) {
        throw const AuthException(
          'Google sign-in is not configured correctly. Add SHA-1/SHA-256 in Firebase, download google-services.json again, and pass GOOGLE_WEB_CLIENT_ID.',
        );
      }
      throw AuthException(text);
    }
  }

  Future<AuthSession> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions:
          _kAppleServiceId.isEmpty || _kAppleRedirectUri.isEmpty
          ? null
          : WebAuthenticationOptions(
              clientId: _kAppleServiceId,
              redirectUri: Uri.parse(_kAppleRedirectUri),
            ),
    );
    final idToken = credential.identityToken;
    if (idToken == null || idToken.isEmpty) {
      throw const AuthException('Apple did not return an identity token.');
    }
    final response = await _post('/auth/apple', {
      'idToken': idToken,
      'firstName': credential.givenName,
      'lastName': credential.familyName,
    }, includeAccessToken: false);
    return _persistSessionFromResponse(response);
  }

  Future<void> signOut() async {
    try {
      await _post('/auth/logout', {'refreshToken': _session?.refreshToken});
    } catch (_) {
      // Local cleanup still happens even if backend is temporarily unreachable.
    }
    await _clearSession();
  }

  Future<void> signOutAllDevices() async {
    await _post('/auth/logout-all', {});
    await _clearSession();
  }

  Future<AuthSession> refreshSession() async {
    final refreshToken =
        _session?.refreshToken ??
        await _secureStorage.read(key: _kRefreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const AuthException('No refresh token available.');
    }
    final response = await _post(
      '/auth/refresh',
      {'refreshToken': refreshToken},
      includeAccessToken: false,
      retryOnUnauthorized: false,
    );
    return _persistSessionFromResponse(response);
  }

  Future<void> saveDeviceFcmToken({
    required String fcmToken,
    required String platform,
  }) async {
    await _post('/devices/fcm-token', {
      'fcmToken': fcmToken,
      'platform': platform,
    });
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _get('/me');
    final userData = _extractUserMap(response);
    if (userData == null) {
      throw const AuthException('Invalid /me response from server.');
    }
    final current = _session;
    if (current == null) return userData;
    final updatedSession = current.copyWith(user: AuthUser.fromJson(userData));
    await _saveSession(updatedSession);
    return userData;
  }

  Future<Map<String, dynamic>> _get(String path) async {
    return _sendJsonRequest(
      method: 'GET',
      path: path,
      includeAccessToken: true,
    );
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    bool includeAccessToken = true,
    bool retryOnUnauthorized = true,
  }) async {
    return _sendJsonRequest(
      method: 'POST',
      path: path,
      body: body,
      includeAccessToken: includeAccessToken,
      retryOnUnauthorized: retryOnUnauthorized,
    );
  }

  Future<Map<String, dynamic>> _sendJsonRequest({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    required bool includeAccessToken,
    bool retryOnUnauthorized = true,
  }) async {
    final uri = Uri.parse('$_kApiBaseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAccessToken) {
      final token =
          _session?.accessToken ??
          await _secureStorage.read(key: _kAccessTokenKey);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    late final http.Response response;
    try {
      if (method == 'GET') {
        response = await _httpClient
            .get(uri, headers: headers)
            .timeout(_kRequestTimeout);
      } else {
        response = await _httpClient
            .post(
              uri,
              headers: headers,
              body: jsonEncode(body ?? <String, dynamic>{}),
            )
            .timeout(_kRequestTimeout);
      }
    } on TimeoutException {
      throw AuthException(
        'Cannot reach $_kApiBaseUrl. Make sure the backend is running and API_BASE_URL points to this device network.',
      );
    } catch (e) {
      throw AuthException('Network request failed: $e');
    }

    final responseBody = response.body.trim();
    final decoded = _decodeResponse(responseBody);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    if (response.statusCode == 401 &&
        includeAccessToken &&
        retryOnUnauthorized) {
      try {
        await refreshSession();
      } catch (_) {
        await _clearSession();
        rethrow;
      }
      return _sendJsonRequest(
        method: method,
        path: path,
        body: body,
        includeAccessToken: includeAccessToken,
        retryOnUnauthorized: false,
      );
    }
    final errorMessage =
        (decoded['message'] ?? decoded['error'] ?? 'Request failed').toString();
    throw AuthException(errorMessage, statusCode: response.statusCode);
  }

  Map<String, dynamic> _decodeResponse(String responseBody) {
    if (responseBody.isEmpty) return <String, dynamic>{};
    try {
      final value = jsonDecode(responseBody);
      if (value is Map<String, dynamic>) return value;
      return {'message': value.toString()};
    } catch (_) {
      return {'message': responseBody};
    }
  }

  Future<AuthSession> _persistSessionFromResponse(
    Map<String, dynamic> response,
  ) async {
    final accessToken = (response['accessToken'] ?? response['token'] ?? '')
        .toString();
    final refreshToken = (response['refreshToken'] ?? '').toString();
    final userMap = _extractUserMap(response);
    if (accessToken.isEmpty || refreshToken.isEmpty || userMap == null) {
      throw const AuthException('Invalid auth response from server.');
    }
    final session = AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: AuthUser.fromJson(userMap),
    );
    await _saveSession(session);
    return session;
  }

  Map<String, dynamic>? _extractUserMap(Map<String, dynamic> json) {
    final direct = json['user'];
    if (direct is Map<String, dynamic>) return direct;
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final nestedUser = data['user'];
      if (nestedUser is Map<String, dynamic>) return nestedUser;
    }
    return null;
  }

  Future<void> _saveSession(AuthSession session) async {
    _session = session;
    await _secureStorage.write(
      key: _kAccessTokenKey,
      value: session.accessToken,
    );
    await _secureStorage.write(
      key: _kRefreshTokenKey,
      value: session.refreshToken,
    );
    await _secureStorage.write(
      key: _kUserJsonKey,
      value: jsonEncode(session.user.toJson()),
    );
    _authController.add(session.user);
  }

  Future<void> _clearSession() async {
    _session = null;
    await _secureStorage.delete(key: _kAccessTokenKey);
    await _secureStorage.delete(key: _kRefreshTokenKey);
    await _secureStorage.delete(key: _kUserJsonKey);
    _authController.add(null);
  }

  Future<AuthSession?> _loadSessionFromStorage() async {
    final accessToken = await _secureStorage.read(key: _kAccessTokenKey);
    final refreshToken = await _secureStorage.read(key: _kRefreshTokenKey);
    final userJson = await _secureStorage.read(key: _kUserJsonKey);
    if (accessToken == null || refreshToken == null || userJson == null) {
      return null;
    }
    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      final user = AuthUser.fromJson(userMap);
      return AuthSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
    } catch (_) {
      await _clearSession();
      return null;
    }
  }
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    AuthUser? user,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    this.profileEmoji,
    this.gender,
    this.birthYear,
    this.authProvider,
    required this.emailVerified,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? profileEmoji;
  final String? gender;
  final int? birthYear;
  final String? authProvider;
  final bool emailVerified;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? json['uid'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      displayName: json['displayName']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      profileEmoji: json['profileEmoji']?.toString(),
      gender: json['gender']?.toString(),
      birthYear: int.tryParse((json['birthYear'] ?? '').toString()),
      authProvider: json['authProvider']?.toString(),
      emailVerified:
          json['isVerified'] == true || json['emailVerified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'profileEmoji': profileEmoji,
      'gender': gender,
      'birthYear': birthYear,
      'authProvider': authProvider,
      'isVerified': emailVerified,
    };
  }
}

class AuthException implements Exception {
  const AuthException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
