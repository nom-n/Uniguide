import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

const String kPrefsUserBlobKey = 'auth_user_blob';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  bool _initialized = false;
  bool _firebaseReady = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await Firebase.initializeApp();
      _firebaseReady = true;
    } catch (_) {
      _firebaseReady = false;
    }
  }

  bool get isFirebaseReady => _firebaseReady;
  Future<bool> initialize() async {
    await _ensureInitialized();
    return _firebaseReady;
  }

  Stream<User?> get authStateChanges => FirebaseAuth.instance.authStateChanges();
  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _persistUser(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(kPrefsUserBlobKey);
      return;
    }
    final lang = prefs.getString('lang');
    final province = prefs.getString('province');
    final data = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'providerIds': user.providerData.map((p) => p.providerId).toList(),
      'emailVerified': user.emailVerified,
      'lang': lang,
      'province': province,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(kPrefsUserBlobKey, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getPersistedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kPrefsUserBlobKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _ensureInitialized();
    _requireReady();
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _persistUser(cred.user);
    return cred;
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    await _ensureInitialized();
    _requireReady();
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user?.sendEmailVerification();
    await _persistUser(cred.user);
    return cred;
  }

  Future<void> sendVerificationEmail() async {
    await _ensureInitialized();
    _requireReady();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await user.sendEmailVerification();
  }

  Future<void> sendPasswordReset(String email) async {
    await _ensureInitialized();
    _requireReady();
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserCredential> signInWithGoogle() async {
    await _ensureInitialized();
    _requireReady();
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'cancelled',
        message: 'Google sign-in cancelled.',
      );
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await FirebaseAuth.instance.signInWithCredential(credential);
    await _persistUser(cred.user);
    return cred;
  }

  Future<UserCredential> signInWithApple() async {
    await _ensureInitialized();
    _requireReady();
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: <AppleIDAuthorizationScopes>[
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    final cred = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    await _persistUser(cred.user);
    return cred;
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    if (_firebaseReady) {
      await FirebaseAuth.instance.signOut();
    }
    await GoogleSignIn().signOut();
    await _persistUser(null);
  }

  Future<void> refreshUser() async {
    await _ensureInitialized();
    _requireReady();
    await FirebaseAuth.instance.currentUser?.reload();
    await _persistUser(FirebaseAuth.instance.currentUser);
  }

  void _requireReady() {
    if (!_firebaseReady) {
      throw FirebaseException(
        plugin: 'firebase_core',
        message:
            'Firebase is not configured yet. Add GoogleService-Info.plist and google-services.json.',
      );
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
