// ============================================================
// Apple.NET — GoRouter Configuration with Auth Guards
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../data/providers/app_providers.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/home/home_screen.dart';
import '../features/deposit/deposit_screen.dart';
import '../features/purchased/purchased_screen.dart';
import '../features/banks/banks_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/ads/ads_screen.dart';
import '../features/starlink/starlink_screen.dart';
import '../features/sims/sims_screen.dart';
import '../features/network_submission/network_submission_screen.dart';
import '../features/about/about_screen.dart';
import '../features/admin/admin_panel.dart';
import '../features/manager/manager_panel.dart';
import '../app/theme.dart';

// ============================================================
// Protected Routes — Require Authentication
// ============================================================

const _authRequiredRoutes = <String>{
  '/deposit',
  '/purchased',
  '/notifications',
  '/profile',
  '/submit-network',
};

// ============================================================
// Custom Page Transition — Fade + Slide (300ms easeOutCubic)
// ============================================================

CustomTransitionPage<void> _pageTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      final slide = Tween<Offset>(
        begin: const Offset(0.1, 0),
        end: Offset.zero,
      ).animate(curvedAnimation);

      final fade = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(curvedAnimation);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

// ============================================================
// Router Provider
// ============================================================

final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state to rebuild router on sign-in/sign-out
  final authState = ref.watch(authStateProvider);
  final isLoggedIn = authState.value != null;

  // Watch current user for role-based access
  final currentUser = ref.watch(currentUserProvider);
  final userRole = currentUser.value?.role;

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: _GoRouterRefreshStream(
      fb_auth.FirebaseAuth.instance.authStateChanges(),
    ),

    // ── Redirect Logic ──
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login';

      // 1. Not authenticated → trying to access protected route → /login
      if (!isLoggedIn && _authRequiredRoutes.contains(location)) {
        return '/login';
      }

      // 2. Not authenticated → trying to access admin panel → /login
      if (!isLoggedIn && location == '/admin') {
        return '/login';
      }

      // 3. Not authenticated → trying to access manager panel → /login
      if (!isLoggedIn && location == '/manager') {
        return '/login';
      }

      // 4. Authenticated → trying to access /login → /home
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      // 5. User role is not admin → trying to access /admin → /home
      if (location == '/admin' && userRole != 'admin') {
        return '/home';
      }

      // 6. User role is not network_manager → trying to access /manager → /home
      if (location == '/manager' && userRole != 'network_manager') {
        return '/home';
      }

      // No redirect needed
      return null;
    },

    // ── Routes ──
    routes: [
      // Splash
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _pageTransition(
          state: state,
          child: const SplashScreen(),
        ),
      ),

      // Auth / Login
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _pageTransition(
          state: state,
          child: const LoginScreen(),
        ),
      ),

      // Home (with optional ?tab=N query parameter)
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _pageTransition(
          state: state,
          child: HomeScreen(
            initialTab: state.uri.queryParameters['tab'] != null
                ? int.tryParse(state.uri.queryParameters['tab']!) ?? 0
                : 0,
          ),
        ),
      ),

      // Deposit (auth required)
      GoRoute(
        path: '/deposit',
        pageBuilder: (context, state) => _pageTransition(
          state: state,
          child: const DepositScreen(),
        ),
      ),

      // Purchased (auth required)
      GoRoute(
        path: '/purchased',
        pageBuilder: (context, state) => _pageTransition(
          state: state,
          child: const PurchasedScreen(),
        ),
      ),

      // Banks
      GoRoute(
        path: '/banks',
        pageBuilder: (context, state) => _pageTransition(
          state: state,
          child: const BanksScreen(),
        ),
      ),

      // Notifications (auth required)
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => _pageTransition(
          state: state,
          child: const NotificationsScreen(),
        ),
      ),

      // Profile (auth required)
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _pageTransition(
          state: state,
          child: const ProfileScreen(),
        ),
      ),

      // Ads
      GoRoute(
        path: '/ads',
        pageBuilder: (context, state) => _pageTransition(
          state: state,
          child: const AdsScreen(),
        ),
      ),

      // Starlink
      GoRoute(
        path: '/starlink',
        pageBuilder: (context, state) => _pageTransition(
          state: state,
          child: const StarlinkScreen(),
        ),
      ),

      // SIM Cards
      GoRoute(
        path: '/sims',
        pageBuilder: (context, state) => _pageTransition(
          state: state,
          child: const SimsScreen(),
        ),
      ),

      // Network Submission (auth required)
      GoRoute(
        path: '/submit-network',
        pageBuilder: (context, state) => _pageTransition(
          state: state,
          child: const NetworkSubmissionScreen(),
        ),
      ),

      // About
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) => _pageTransition(
          state: state,
          child: const AboutScreen(),
        ),
      ),

      // Admin Panel (admin role required)
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) => _pageTransition(
          state: state,
          child: const AdminPanel(),
        ),
      ),

      // Manager Panel (network_manager role required)
      GoRoute(
        path: '/manager',
        pageBuilder: (context, state) => _pageTransition(
          state: state,
          child: const ManagerPanel(),
        ),
      ),
    ],

    // ── 404 Error Page ──
    errorBuilder: (context, state) => Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 56,
                    color: AppTheme.accentRed.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),

                // 404 title
                Text(
                  '404',
                  style: AppTheme.headingLarge.copyWith(
                    color: AppTheme.accentRed,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: 8),

                // Error message
                Text(
                  'الصفحة غير موجودة',
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.adaptiveTextPrimary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  'عذراً، الصفحة التي تبحث عنها غير موجودة أو تم نقلها.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.adaptiveTextSecondary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Back to home button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('العودة للرئيسية'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.textOnPrimary,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 52),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      textStyle: AppTheme.buttonText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
});

// ============================================================
// GoRouterRefreshStream — Allows GoRouter to react to auth changes
// ============================================================

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<fb_auth.User?> stream) {
    _subscription = stream.listen(
      (_) => notifyListeners(),
      onError: (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<fb_auth.User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
