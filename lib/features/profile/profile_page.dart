import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniguide/core/auth/auth_service.dart';
import 'package:uniguide/core/constants/app_constants.dart';
import 'package:uniguide/l10n/app_localizations.dart';
import 'package:uniguide/main.dart';
import 'package:uniguide/features/settings/settings_page.dart';

const Color _kAppBackground = Color(0xFFF5F7FA);
const Color _kAppPrimary = Color(0xFF007AFF);
const Color _kAppSurface = Colors.white;
const Color _kAppSurfaceBorder = Color(0xFFE4E8EE);

enum _AuthMode { signIn, register }

enum _RegisterStep { email, code, profile }

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _resetEmailController = TextEditingController();

  late final Future<bool> _initFuture;
  late final AnimationController _introController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;

  _AuthMode _authMode = _AuthMode.signIn;
  _RegisterStep _registerStep = _RegisterStep.email;
  bool _loading = false;
  String? _message;
  String? _registrationTicket;
  String _gender = 'male';
  int _birthYear = DateTime.now().year - 20;
  String _selectedEmoji = '🙂';
  ThemeMode _selectedThemeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _initFuture = AuthService.instance.initialize();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _fadeIn = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(_fadeIn);
    _loadThemePreference();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _resetEmailController.dispose();
    _introController.dispose();
    super.dispose();
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await action();
    } on AuthException catch (e) {
      setState(() => _message = e.message);
    } catch (e) {
      setState(() => _message = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppConstants.kPrefsThemeModeKey);
    final mode = _parseThemeMode(code);
    if (!mounted) return;
    setState(() {
      _selectedThemeMode = mode;
    });
  }

  ThemeMode _parseThemeMode(String? code) {
    if (code == 'light') return ThemeMode.light;
    if (code == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  String _themeModeToCode(ThemeMode mode) {
    if (mode == ThemeMode.dark) return 'dark';
    if (mode == ThemeMode.light) return 'light';
    return 'system';
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final code = _themeModeToCode(mode);
    await prefs.setString(AppConstants.kPrefsThemeModeKey, code);
    if (!mounted) return;
    setState(() {
      _selectedThemeMode = mode;
    });
    UniGuideApp.setThemeMode(context, mode);
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    return Scaffold(
      backgroundColor: _kAppBackground,
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: _initFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: _kAppPrimary),
              );
            }
            return StreamBuilder<AuthUser?>(
              stream: auth.authStateChanges,
              builder: (context, authSnapshot) {
                final user = authSnapshot.data ?? auth.currentUser;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  child: user == null
                      ? _AnimatedPanel(
                          key: const ValueKey('auth'),
                          fade: _fadeIn,
                          slide: _slideIn,
                          child: _buildAuthExperience(context, auth),
                        )
                      : _AnimatedPanel(
                          key: const ValueKey('profile'),
                          fade: _fadeIn,
                          slide: _slideIn,
                          child: _buildProfile(context, auth, user),
                        ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAuthExperience(BuildContext context, AuthService auth) {
    final width = MediaQuery.sizeOf(context).width;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: width < 420 ? 18 : 28,
            vertical: 18,
          ),
          children: [
            _AuthHeader(mode: _authMode),
            const SizedBox(height: 18),
            _ModeSwitch(
              mode: _authMode,
              onChanged: (mode) {
                setState(() {
                  _authMode = mode;
                  _message = null;
                });
              },
            ),
            const SizedBox(height: 18),
            if (_authMode == _AuthMode.signIn)
              _buildSignInForm(auth)
            else
              _buildRegisterFlow(auth),
            const SizedBox(height: 18),
            _SocialButtons(
              loading: _loading,
              onGoogle: () => _runAction(auth.signInWithGoogle),
              onApple: () => _runAction(auth.signInWithApple),
            ),
            if (_message != null) ...[
              const SizedBox(height: 14),
              _StatusBanner(message: _message!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignInForm(AuthService auth) {
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(
            icon: Icons.lock_outline,
            title: 'Welcome back',
            subtitle: 'Sign in with your email and password.',
          ),
          const SizedBox(height: 18),
          _AppTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _AppTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.password,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading
                ? null
                : () => _runAction(
                    () => auth.signInWithEmail(
                      email: _emailController.text,
                      password: _passwordController.text,
                    ),
                  ),
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_kAppPrimary),
                    ),
                  )
                : const Icon(Icons.arrow_forward),
            label: const Text('Sign in'),
          ),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: _loading ? null : () => _showResetDialog(auth),
              child: const Text('Forgot password?'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterFlow(AuthService auth) {
    return _Surface(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        child: switch (_registerStep) {
          _RegisterStep.email => _buildEmailStep(auth),
          _RegisterStep.code => _buildCodeStep(auth),
          _RegisterStep.profile => _buildProfileStep(auth),
        },
      ),
    );
  }

  Widget _buildEmailStep(AuthService auth) {
    return Column(
      key: const ValueKey('email-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepPills(activeIndex: 0),
        const SizedBox(height: 18),
        const _SectionTitle(
          icon: Icons.mail_outline,
          title: 'Verify your email',
          subtitle: 'We will send a 6-digit code before creating the account.',
        ),
        const SizedBox(height: 18),
        _AppTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.alternate_email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading
              ? null
              : () => _runAction(() async {
                  final devCode = await auth.sendEmailOtp(
                    _emailController.text,
                  );
                  setState(() => _registerStep = _RegisterStep.code);
                  if (devCode != null) {
                    setState(() => _message = 'Development OTP: $devCode');
                  }
                }),
          icon: const Icon(Icons.mark_email_read_outlined),
          label: const Text('Send code'),
        ),
      ],
    );
  }

  Widget _buildCodeStep(AuthService auth) {
    return Column(
      key: const ValueKey('code-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepPills(activeIndex: 1),
        const SizedBox(height: 18),
        const _SectionTitle(
          icon: Icons.verified_outlined,
          title: 'Enter the code',
          subtitle: 'Check your inbox and type the code here.',
        ),
        const SizedBox(height: 18),
        _AppTextField(
          controller: _otpController,
          label: '6-digit code',
          icon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: _loading
                  ? null
                  : () => setState(() => _registerStep = _RegisterStep.email),
              child: const Text('Change email'),
            ),
            const Spacer(),
            TextButton(
              onPressed: _loading
                  ? null
                  : () => _runAction(() async {
                      final devCode = await auth.sendEmailOtp(
                        _emailController.text,
                      );
                      if (devCode != null) {
                        setState(() => _message = 'Development OTP: $devCode');
                      }
                    }),
              child: const Text('Resend'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _loading
              ? null
              : () => _runAction(() async {
                  final ticket = await auth.verifyEmail(
                    email: _emailController.text,
                    code: _otpController.text,
                  );
                  if (ticket.isEmpty) {
                    throw const AuthException('Verification failed.');
                  }
                  setState(() {
                    _registrationTicket = ticket;
                    _registerStep = _RegisterStep.profile;
                  });
                }),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Verify code'),
        ),
      ],
    );
  }

  Widget _buildProfileStep(AuthService auth) {
    final emojis = _emojiOptions();
    if (!emojis.contains(_selectedEmoji)) {
      _selectedEmoji = emojis.first;
    }
    return Column(
      key: const ValueKey('profile-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepPills(activeIndex: 2),
        const SizedBox(height: 18),
        const _SectionTitle(
          icon: Icons.auto_awesome,
          title: 'Complete your profile',
          subtitle: 'Add your name, password, and a personal emoji.',
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _AppTextField(
                controller: _firstNameController,
                label: 'First name',
                icon: Icons.badge_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AppTextField(
                controller: _lastNameController,
                label: 'Last name',
                icon: Icons.badge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _AppTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.password,
          obscureText: true,
        ),
        const SizedBox(height: 14),
        _ChoiceGroup(
          label: 'Gender',
          selected: _gender,
          values: const {'male': 'Male', 'female': 'Female', 'other': 'Other'},
          onChanged: (value) {
            setState(() {
              _gender = value;
              _selectedEmoji = _emojiOptions().first;
            });
          },
        ),
        const SizedBox(height: 14),
        _BirthYearPicker(
          value: _birthYear,
          onChanged: (value) {
            setState(() {
              _birthYear = value;
              _selectedEmoji = _emojiOptions().first;
            });
          },
        ),
        const SizedBox(height: 14),
        _EmojiPicker(
          emojis: emojis,
          selected: _selectedEmoji,
          onChanged: (emoji) => setState(() => _selectedEmoji = emoji),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _loading
              ? null
              : () => _runAction(() {
                  final ticket = _registrationTicket;
                  if (ticket == null || ticket.isEmpty) {
                    throw const AuthException('Verify your email first.');
                  }
                  return auth.registerWithEmail(
                    email: _emailController.text,
                    password: _passwordController.text,
                    firstName: _firstNameController.text,
                    lastName: _lastNameController.text,
                    profileEmoji: _selectedEmoji,
                    gender: _gender,
                    birthYear: _birthYear,
                    registrationTicket: ticket,
                  );
                }),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Create account'),
        ),
      ],
    );
  }

  Widget _buildProfile(BuildContext context, AuthService auth, AuthUser user) {
    final age = user.birthYear == null
        ? null
        : DateTime.now().year - user.birthYear!;
    return ListView(
      key: const ValueKey('profile-list'),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        _ProfileHero(user: user),
        const SizedBox(height: 14),
        _ProfileStats(
          items: [
            _ProfileStat(
              icon: Icons.verified_user_outlined,
              label: 'Email',
              value: user.emailVerified ? 'Verified' : 'Needs OTP',
            ),
            _ProfileStat(
              icon: Icons.login,
              label: 'Provider',
              value: user.authProvider ?? 'email',
            ),
            _ProfileStat(
              icon: Icons.cake_outlined,
              label: 'Age',
              value: age == null ? '-' : '$age',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
        ),
        const SizedBox(height: 14),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.color_lens_outlined),
              title: Text(AppLocalizations.of(context)!.themeModeTitle),
              subtitle: Text(
                _selectedThemeMode == ThemeMode.system
                    ? AppLocalizations.of(context)!.themeModeSystem
                    : _selectedThemeMode == ThemeMode.light
                    ? AppLocalizations.of(context)!.themeModeLight
                    : AppLocalizations.of(context)!.themeModeDark,
              ),
              trailing: DropdownButton<ThemeMode>(
                value: _selectedThemeMode,
                onChanged: _loading
                    ? null
                    : (value) {
                        if (value != null) {
                          _setThemeMode(value);
                        }
                      },
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(AppLocalizations.of(context)!.themeModeSystem),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(AppLocalizations.of(context)!.themeModeLight),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(AppLocalizations.of(context)!.themeModeDark),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle(
                icon: Icons.manage_accounts_outlined,
                title: 'Account controls',
                subtitle: 'Keep your session and profile fresh.',
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _loading
                        ? null
                        : () => _runAction(() => auth.getMe()),
                    style: FilledButton.styleFrom(
                      backgroundColor: _kAppPrimary.withValues(alpha: 0.2),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _loading
                        ? null
                        : () => _runAction(() => auth.signOut()),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign out'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _loading
                        ? null
                        : () => _runAction(() => auth.signOutAllDevices()),
                    icon: const Icon(Icons.devices_other),
                    label: const Text('All devices'),
                  ),
                ],
              ),
              if (_message != null) ...[
                const SizedBox(height: 14),
                _StatusBanner(message: _message!),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<String> _emojiOptions() {
    final age = DateTime.now().year - _birthYear;
    if (age <= 17) {
      return _gender == 'female'
          ? const ['🌸', '🎨', '📚', '✨', '🎧']
          : const ['⚽', '🎮', '📚', '🚀', '🎧'];
    }
    if (age >= 45) {
      return _gender == 'female'
          ? const ['🌺', '☕', '📖', '🧭', '💫']
          : const ['🧭', '☕', '📖', '🏛️', '⭐'];
    }
    return switch (_gender) {
      'female' => const ['✨', '🌿', '🎓', '💼', '🌙'],
      'male' => const ['🚀', '🌿', '🎓', '💼', '⭐'],
      _ => const ['🙂', '✨', '🌿', '🎓', '🧭'],
    };
  }

  Future<void> _showResetDialog(AuthService auth) async {
    _resetEmailController.text = _emailController.text;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset password'),
          content: _AppTextField(
            controller: _resetEmailController,
            label: 'Email',
            icon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _runAction(
                  () => auth.sendPasswordReset(_resetEmailController.text),
                );
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
}

class _AnimatedPanel extends StatelessWidget {
  const _AnimatedPanel({
    super.key,
    required this.fade,
    required this.slide,
    required this.child,
  });

  final Animation<double> fade;
  final Animation<Offset> slide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.mode});

  final _AuthMode mode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _kAppPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(
              'assets/images/app_logo.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            mode == _AuthMode.signIn
                ? 'Your UniGuide account'
                : 'Join UniGuide',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mode == _AuthMode.signIn
                ? 'A calmer profile space for your university journey.'
                : 'Start with email verification, then shape your profile.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.mode, required this.onChanged});

  final _AuthMode mode;
  final ValueChanged<_AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_AuthMode>(
      segments: const [
        ButtonSegment(
          value: _AuthMode.signIn,
          icon: Icon(Icons.login),
          label: Text('Sign in'),
        ),
        ButtonSegment(
          value: _AuthMode.register,
          icon: Icon(Icons.person_add_alt),
          label: Text('Register'),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (value) => onChanged(value.first),
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons({
    required this.loading,
    required this.onGoogle,
    required this.onApple,
  });

  final bool loading;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or continue with',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: loading ? null : onGoogle,
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text('Google'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: loading ? null : onApple,
                icon: const Icon(Icons.apple),
                label: const Text('Apple'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kAppSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kAppSurfaceBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF1F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _kAppPrimary),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD8DEE8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD8DEE8)),
        ),
      ),
    );
  }
}

class _StepPills extends StatelessWidget {
  const _StepPills({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    const labels = ['Email', 'OTP', 'Profile'];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i <= activeIndex
                    ? _kAppPrimary
                    : const Color(0xFFE8EDF3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: i <= activeIndex ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (i != labels.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _ChoiceGroup extends StatelessWidget {
  const _ChoiceGroup({
    required this.label,
    required this.selected,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String selected;
  final Map<String, String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.entries.map((entry) {
            return ChoiceChip(
              label: Text(entry.value),
              selected: selected == entry.key,
              selectedColor: _kAppPrimary,
              labelStyle: TextStyle(
                color: selected == entry.key ? Colors.white : Colors.black,
              ),
              onSelected: (_) => onChanged(entry.key),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BirthYearPicker extends StatelessWidget {
  const _BirthYearPicker({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final maxYear = DateTime.now().year - 8;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth year: $value',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        Slider(
          value: value.clamp(1940, maxYear).toDouble(),
          min: 1940,
          max: maxYear.toDouble(),
          divisions: maxYear - 1940,
          activeColor: _kAppPrimary,
          label: '$value',
          onChanged: (newValue) => onChanged(newValue.round()),
        ),
      ],
    );
  }
}

class _EmojiPicker extends StatelessWidget {
  const _EmojiPicker({
    required this.emojis,
    required this.selected,
    required this.onChanged,
  });

  final List<String> emojis;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose your emoji',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: emojis.map((emoji) {
            final isSelected = emoji == selected;
            return Tooltip(
              message: 'Select $emoji',
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onChanged(emoji),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? _kAppPrimary : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? _kAppPrimary
                          : const Color(0xFFD8DEE8),
                    ),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final name = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : user.email.split('@').first;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kAppPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user.profileEmoji ?? '🙂',
              style: const TextStyle(fontSize: 36),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: Color(0xFFD8E2EA)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({required this.items});

  final List<_ProfileStat> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 460;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) {
            return SizedBox(
              width: compact
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 20) / 3,
              child: _Surface(
                child: Row(
                  children: [
                    Icon(item.icon, color: _kAppPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Text(
                            item.value,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ProfileStat {
  const _ProfileStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD28A)),
      ),
      child: Text(message, style: const TextStyle(color: Color(0xFF7A4D00))),
    );
  }
}
