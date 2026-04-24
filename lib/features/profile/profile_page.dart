import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uniguide/core/auth/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _resetEmailController = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;
  String? _message;
  late final Future<bool> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = AuthService.instance.initialize();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      setState(() => _message = e.message ?? e.code);
    } on FirebaseException catch (e) {
      setState(() => _message = e.message ?? e.plugin);
    } catch (e) {
      setState(() => _message = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _t(BuildContext context, String key) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    const ar = <String, String>{
      'profile': 'الحساب',
      'signIn': 'تسجيل الدخول',
      'register': 'تسجيل جديد',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'continue': 'متابعة',
      'or': 'أو',
      'google': 'المتابعة عبر Google',
      'apple': 'المتابعة عبر Apple',
      'forgot': 'نسيت كلمة المرور؟',
      'sendReset': 'إرسال رابط إعادة التعيين',
      'emailSent': 'تم إرسال رسالة التحقق إلى بريدك.',
      'verifyEmail': 'إرسال/إعادة إرسال رسالة التحقق',
      'logout': 'تسجيل الخروج',
      'verified': 'البريد موثّق',
      'notVerified': 'البريد غير موثّق',
      'firebaseMissing': 'Firebase غير مُعدّة. يلزم ربط المشروع أولاً.',
      'savedData': 'البيانات المحفوظة محلياً',
      'provider': 'مزود الدخول',
      'uid': 'المعرّف',
    };
    const en = <String, String>{
      'profile': 'Profile',
      'signIn': 'Sign in',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'continue': 'Continue',
      'or': 'OR',
      'google': 'Continue with Google',
      'apple': 'Continue with Apple',
      'forgot': 'Forgot password?',
      'sendReset': 'Send reset email',
      'emailSent': 'Verification email has been sent.',
      'verifyEmail': 'Send / resend verification email',
      'logout': 'Sign out',
      'verified': 'Email verified',
      'notVerified': 'Email not verified',
      'firebaseMissing': 'Firebase is not configured yet.',
      'savedData': 'Saved local data',
      'provider': 'Provider',
      'uid': 'UID',
    };
    return (isAr ? ar : en)[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(_t(context, 'profile')),
      ),
      body: FutureBuilder<bool>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<User?>(
            stream: auth.authStateChanges,
            builder: (context, authSnapshot) {
              final user = authSnapshot.data;
              if (user == null) {
                return _buildAuthForm(context, auth);
              }
              return _buildLoggedInView(context, auth, user);
            },
          );
        },
      ),
    );
  }

  Widget _buildAuthForm(BuildContext context, AuthService auth) {
    final firebaseReady = auth.isFirebaseReady;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: Text(_t(context, 'signIn')),
                selected: !_isRegister,
                onSelected: _loading ? null : (_) => setState(() => _isRegister = false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: Text(_t(context, 'register')),
                selected: _isRegister,
                onSelected: _loading ? null : (_) => setState(() => _isRegister = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: _t(context, 'email'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: _t(context, 'password'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _loading
                ? null
                : () => _runAction(() async {
                    if (_isRegister) {
                      await auth.registerWithEmail(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                      setState(() => _message = _t(context, 'emailSent'));
                    } else {
                      await auth.signInWithEmail(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                    }
                  }),
            child: _loading
                ? const CircularProgressIndicator()
                : Text(_t(context, 'continue')),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _loading
              ? null
              : () => _showResetDialog(context, auth),
          child: Text(_t(context, 'forgot')),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(_t(context, 'or')),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _loading
              ? null
              : () => _runAction(() => auth.signInWithGoogle()),
          icon: const Icon(Icons.g_mobiledata),
          label: Text(_t(context, 'google')),
        ),
        if (!kIsWeb &&
            Theme.of(context).platform == TargetPlatform.iOS) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _loading
                ? null
                : () => _runAction(() => auth.signInWithApple()),
            icon: const Icon(Icons.apple),
            label: Text(_t(context, 'apple')),
          ),
        ],
        if (!firebaseReady)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _t(context, 'firebaseMissing'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(_message!),
          ),
      ],
    );
  }

  Widget _buildLoggedInView(BuildContext context, AuthService auth, User user) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: auth.getPersistedUserData(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? <String, dynamic>{};
        final provider = (user.providerData.isNotEmpty)
            ? user.providerData.first.providerId
            : '-';
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(user.displayName ?? '-'),
              subtitle: Text(user.email ?? '-'),
            ),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: Text(
                user.emailVerified
                    ? _t(context, 'verified')
                    : _t(context, 'notVerified'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.key),
              title: Text('${_t(context, 'uid')}: ${user.uid}'),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: Text('${_t(context, 'provider')}: $provider'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () => _runAction(() async {
                      await auth.sendVerificationEmail();
                      setState(() => _message = _t(context, 'emailSent'));
                    }),
              child: Text(_t(context, 'verifyEmail')),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loading
                  ? null
                  : () => _runAction(() => auth.signOut()),
              child: Text(_t(context, 'logout')),
            ),
            const SizedBox(height: 16),
            Text(
              _t(context, 'savedData'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(data.toString()),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_message!),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showResetDialog(BuildContext context, AuthService auth) async {
    _resetEmailController.text = _emailController.text;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_t(context, 'sendReset')),
          content: TextField(
            controller: _resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: _t(context, 'email'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _runAction(
                  () => auth.sendPasswordReset(_resetEmailController.text),
                );
              },
              child: Text(_t(context, 'sendReset')),
            ),
          ],
        );
      },
    );
  }
}
