// ============================================================
// Apple.NET — Splash Screen with Gradient & Elastic Animation
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    // ── Animation Setup ──
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // ── Navigate after 2.5s based on auth state ──
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryDark,
              AppTheme.primaryColor,
              AppTheme.primaryLight,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fade.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── App Icon ──
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.textOnPrimary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryDark.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.wifi_rounded,
                          size: 60,
                          color: AppTheme.textOnPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── App Name ──
                      Text(
                        'Apple.NET',
                        style: AppTheme.headingLarge.copyWith(
                          color: AppTheme.textOnPrimary,
                          fontSize: 36,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ── Tagline ──
                      Text(
                        loc.translate('appTagline'),
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textOnPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ── Progress Indicator ──
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          backgroundColor:
                              AppTheme.textOnPrimary.withValues(alpha: 0.2),
                          color: AppTheme.secondaryColor,
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
