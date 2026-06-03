// ============================================================
// Apple.NET — Auth Screen (Login & Register Tabs)
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_database/firebase_database.dart';
import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  late Animation<double> _iconScale;
  late Animation<double> _fade;

  // ── Login Controllers ──
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();

  // ── Register Controllers ──
  final _regName = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPhone = TextEditingController();
  final _regPassword = TextEditingController();
  final _regConfirmPassword = TextEditingController();
  final _registerFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscureLoginPass = true;
  bool _obscureRegPass = true;
  bool _obscureRegConfirmPass = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _regName.dispose();
    _regEmail.dispose();
    _regPhone.dispose();
    _regPassword.dispose();
    _regConfirmPassword.dispose();
    super.dispose();
  }

  // ── Login Method ──
  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _loginEmail.text.trim(),
        password: _loginPassword.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('loginSuccess')),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        context.go('/home');
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      _showError(_mapAuthError(e.code));
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Register Method ──
  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final credential =
          await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _regEmail.text.trim(),
        password: _regPassword.text.trim(),
      );
      final uid = credential.user!.uid;

      // Save user data to RTDB
      await FirebaseDatabase.instance
          .ref('${AppConstants.fbUsers}/$uid')
          .set({
        'uid': uid,
        'email': _regEmail.text.trim(),
        'displayName': _regName.text.trim(),
        'phone': _regPhone.text.trim(),
        'role': 'user',
        'balance': 0,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context).translate('registerSuccess')),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        context.go('/home');
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      _showError(_mapAuthError(e.code));
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لم يتم العثور على مستخدم بهذا البريد';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة';
      case 'invalid-email':
        return 'بريد إلكتروني غير صالح';
      case 'too-many-requests':
        return 'طلبات كثيرة، حاول لاحقاً';
      default:
        return 'حدث خطأ، حاول مرة أخرى';
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.accentRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryDark, AppTheme.primaryColor, AppTheme.primaryLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Gradient Header ──
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fade.value,
                      child: Transform.scale(
                        scale: _iconScale.value,
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.textOnPrimary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.wifi_rounded,
                                size: 40,
                                color: AppTheme.textOnPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Apple.NET',
                              style: AppTheme.headingLarge.copyWith(
                                color: AppTheme.textOnPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              loc.translate('welcome'),
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textOnPrimary.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Tab Bar ──
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppTheme.textOnPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.textOnPrimary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppTheme.textOnPrimary,
                  unselectedLabelColor: AppTheme.textOnPrimary.withValues(alpha: 0.6),
                  labelStyle: AppTheme.labelMedium,
                  tabs: [
                    Tab(text: loc.translate('login')),
                    Tab(text: loc.translate('register')),
                  ],
                ),
              ),

              // ── Tab Views ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginForm(loc),
                    _buildRegisterForm(loc),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Login Form ──
  Widget _buildLoginForm(AppLocalizations loc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            const SizedBox(height: 24),
            AppTextField(
              controller: _loginEmail,
              label: loc.translate('email'),
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return loc.translate('fieldRequired');
                if (!v.contains('@')) return loc.translate('invalidEmail');
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _loginPassword,
              label: loc.translate('password'),
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureLoginPass,
              keyboardType: TextInputType.visiblePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPass ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureLoginPass = !_obscureLoginPass),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return loc.translate('fieldRequired');
                if (v.length < 6) return loc.translate('invalidPassword');
                return null;
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                },
                child: Text(
                  loc.translate('forgotPassword'),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textOnPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: loc.translate('login'),
              isLoading: _isLoading,
              onPressed: _handleLogin,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/home'),
              child: Text(
                loc.translate('browseWithoutAccount'),
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textOnPrimary.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Register Form ──
  Widget _buildRegisterForm(AppLocalizations loc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          children: [
            const SizedBox(height: 24),
            AppTextField(
              controller: _regName,
              label: loc.translate('displayName'),
              prefixIcon: Icons.person_outline,
              validator: (v) {
                if (v == null || v.isEmpty) return loc.translate('fieldRequired');
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _regEmail,
              label: loc.translate('email'),
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return loc.translate('fieldRequired');
                if (!v.contains('@')) return loc.translate('invalidEmail');
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _regPhone,
              label: loc.translate('phone'),
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.isEmpty) return loc.translate('fieldRequired');
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _regPassword,
              label: loc.translate('password'),
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureRegPass,
              keyboardType: TextInputType.visiblePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegPass ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureRegPass = !_obscureRegPass),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return loc.translate('fieldRequired');
                if (v.length < 6) return loc.translate('invalidPassword');
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _regConfirmPassword,
              label: loc.translate('confirmPassword'),
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureRegConfirmPass,
              keyboardType: TextInputType.visiblePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegConfirmPass
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 20,
                ),
                onPressed: () => setState(
                    () => _obscureRegConfirmPass = !_obscureRegConfirmPass),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return loc.translate('fieldRequired');
                if (v != _regPassword.text) return loc.translate('passwordMismatch');
                return null;
              },
            ),
            const SizedBox(height: 24),
            AppButton(
              text: loc.translate('register'),
              isLoading: _isLoading,
              onPressed: _handleRegister,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _tabController.animateTo(0),
              child: Text(
                loc.translate('haveAccount'),
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textOnPrimary.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
