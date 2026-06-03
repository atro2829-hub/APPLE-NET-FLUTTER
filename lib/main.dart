// ============================================================
// Apple.NET — App Entry Point with Firebase Initialization
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/theme.dart';
import 'app/router.dart';
import 'l10n/app_localizations.dart';
import 'data/providers/app_providers.dart';

// ============================================================
// Main
// ============================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase with options
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBAhuybF3tz1oh6j9HtNfhyo52tAX_t-_4',
      authDomain: 'apple-net-df0e7.firebaseapp.com',
      databaseURL: 'https://apple-net-df0e7-default-rtdb.firebaseio.com',
      projectId: 'apple-net-df0e7',
      storageBucket: 'apple-net-df0e7.firebasestorage.app',
      messagingSenderId: '910060697351',
      appId: '1:910060697351:android:177b0075a87ca0cb5ab7a2',
    ),
  );

  // 2. Enable Firebase Realtime Database offline persistence
  FirebaseDatabase.instance.setPersistenceEnabled(true);

  // 3. Initialize Arabic date formatting
  await initializeDateFormatting('ar');

  // 4. Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 5. Run the app inside Riverpod's ProviderScope
  runApp(const ProviderScope(child: AppleNetApp()));
}

// ============================================================
// AppleNetApp — Root ConsumerStatefulWidget
// ============================================================

class AppleNetApp extends ConsumerStatefulWidget {
  const AppleNetApp({super.key});

  @override
  ConsumerState<AppleNetApp> createState() => _AppleNetAppState();
}

class _AppleNetAppState extends ConsumerState<AppleNetApp> {
  StreamSubscription<fb_auth.User?>? _authSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();

    // Load saved theme & locale from SharedPreferences on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeProvider.notifier);
      ref.read(localeProvider.notifier);
    });

    // ── Listen to Firebase Auth state changes ──
    _authSubscription = fb_auth.FirebaseAuth.instance.authStateChanges().listen((user) {
      // When auth state changes, the authStateProvider will automatically
      // update. We can trigger side-effects here if needed (e.g. invalidate
      // user-specific providers on sign-out).
      if (user == null) {
        // User signed out — invalidate user-dependent providers
        ref.invalidate(currentUserProvider);
        ref.invalidate(notificationsProvider);
        ref.invalidate(unreadCountProvider);
      } else {
        // User signed in — refresh user data
        ref.invalidate(currentUserProvider);
      }
    });

    // ── Listen to connectivity changes ──
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final wasOffline = _isOffline;
      setState(() {
        _isOffline = results.contains(ConnectivityResult.none);
      });

      // Show a snackbar when connectivity changes
      if (wasOffline && !_isOffline && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم استعادة الاتصال بالإنترنت',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textOnPrimary),
            ),
            backgroundColor: AppTheme.accentGreen,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (!wasOffline && _isOffline && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يوجد اتصال بالإنترنت',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textOnPrimary),
            ),
            backgroundColor: AppTheme.accentRed,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    // ── Listen to app settings for maintenance mode ──
    // The appSettingsProvider stream is already listened to via Riverpod.
    // We watch it in the build method to react to maintenance mode.
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);
    final appSettings = ref.watch(appSettingsProvider);

    // Check initial connectivity
    Connectivity().checkConnectivity().then((results) {
      if (mounted) {
        setState(() {
          _isOffline = results.contains(ConnectivityResult.none);
        });
      }
    });

    return MaterialApp.router(
      title: 'Apple.NET',
      debugShowCheckedModeBanner: false,

      // ── Theming ──
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // ── Router ──
      routerConfig: router,

      // ── Localization ──
      locale: locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Builder: Directionality + Connectivity + Maintenance ──
      builder: (context, child) {
        final textDirection = locale.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr;

        Widget wrapped = Directionality(
          textDirection: textDirection,
          child: child ?? const SizedBox.shrink(),
        );

        // Wrap with connectivity-aware banner
        wrapped = ConnectivityAware(
          isOffline: _isOffline,
          child: wrapped,
        );

        // Show maintenance mode overlay when enabled
        if (appSettings.value?.maintenanceMode == true) {
          final currentUserRole = ref.watch(currentUserProvider).value?.role;
          // Only block non-admin users
          if (currentUserRole != 'admin') {
            wrapped = _MaintenanceOverlay(child: wrapped);
          }
        }

        return wrapped;
      },
    );
  }
}

// ============================================================
// ConnectivityAware — Shows an offline banner when no network
// ============================================================

class ConnectivityAware extends StatelessWidget {
  final bool isOffline;
  final Widget child;

  const ConnectivityAware({
    super.key,
    required this.isOffline,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return child;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.warningColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: AppTheme.textOnPrimary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'لا يوجد اتصال بالإنترنت',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

// ============================================================
// Maintenance Mode Overlay
// ============================================================

class _MaintenanceOverlay extends StatelessWidget {
  final Widget child;

  const _MaintenanceOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dim the underlying content
        Opacity(
          opacity: 0.3,
          child: child,
        ),
        // Maintenance overlay
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: AppTheme.mediumShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.build_rounded,
                          color: AppTheme.warningColor,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'صيانة مجدولة',
                        style: AppTheme.headingMedium.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'نقوم حالياً بأعمال صيانة لتحسين التطبيق. يرجى المحاولة لاحقاً.',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
