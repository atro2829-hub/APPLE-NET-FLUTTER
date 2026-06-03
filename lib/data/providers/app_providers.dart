// ============================================================
// Apple.NET — Riverpod Providers (Firebase Integration)
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';
import '../../core/constants/app_constants.dart';

// ============================================================
// 1. Firebase Auth Provider
// ============================================================

/// Provides the [fb_auth.FirebaseAuth] singleton instance.
final firebaseAuthProvider = Provider<fb_auth.FirebaseAuth>((ref) {
  return fb_auth.FirebaseAuth.instance;
});

// ============================================================
// 2. Firebase Database Provider
// ============================================================

/// Provides the [FirebaseDatabase] singleton instance.
final databaseProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instance;
});

// ============================================================
// 3. Auth State Provider
// ============================================================

/// Streams the Firebase authentication state.
/// Emits `null` when the user is signed out.
final authStateProvider = StreamProvider<fb_auth.User?>((ref) {
  return fb_auth.FirebaseAuth.instance.authStateChanges();
});

// ============================================================
// 4. Current User ID Provider
// ============================================================

/// Returns the currently signed-in user's UID, or `null`.
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.uid;
});

// ============================================================
// 5. Current AppUser Provider (realtime)
// ============================================================

/// Streams the [AppUser] for the currently authenticated user
/// from the Realtime Database at `users/{uid}`.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);

  final controller = StreamController<AppUser?>();
  final refDb = FirebaseDatabase.instance.ref('${AppConstants.fbUsers}/$uid');
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add(null);
      return;
    }
    final map = Map<String, dynamic>.from(data as Map);
    controller.add(AppUser.fromMap(map));
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 6. Networks Provider
// ============================================================

final networksProvider = StreamProvider<List<NetworkModel>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<NetworkModel>>();
  final refDb = db.ref(AppConstants.fbNetworks);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => NetworkModel.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 7. Tiers Provider
// ============================================================

final tiersProvider = StreamProvider<List<TierModel>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<TierModel>>();
  final refDb = db.ref(AppConstants.fbTiers);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => TierModel.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 8. Banks Provider
// ============================================================

final banksProvider = StreamProvider<List<BankDetail>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<BankDetail>>();
  final refDb = db.ref(AppConstants.fbBanks);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => BankDetail.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 9. Advertisements Provider
// ============================================================

final adsProvider = StreamProvider<List<Advertisement>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<Advertisement>>();
  final refDb = db.ref(AppConstants.fbAds);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => Advertisement.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 10. Starlink Products Provider
// ============================================================

final starlinkProductsProvider = StreamProvider<List<StarlinkProduct>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<StarlinkProduct>>();
  final refDb = db.ref(AppConstants.fbStarlinkProducts);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => StarlinkProduct.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 11. Notifications Provider (per-user)
// ============================================================

/// Streams the notifications for the currently authenticated user
/// from `notifications/{uid}`, sorted by createdAt descending.
final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);

  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<AppNotification>>();
  final refDb = db.ref('${AppConstants.fbNotifications}/$uid');
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => AppNotification.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    list.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 12. Unread Notification Count Provider
// ============================================================

/// Counts the number of unread notifications.
final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.valueOrNull?.where((n) => !n.isRead).length ?? 0;
});

// ============================================================
// 13. Deposit Requests Provider
// ============================================================

final depositsProvider = StreamProvider<List<DepositRequest>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<DepositRequest>>();
  final refDb = db.ref(AppConstants.fbDeposits);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => DepositRequest.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    list.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 14. Cards Provider
// ============================================================

final cardsProvider = StreamProvider<List<CardModel>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<CardModel>>();
  final refDb = db.ref(AppConstants.fbCards);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => CardModel.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 15. Orders Provider
// ============================================================

final ordersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<Map<String, dynamic>>>();
  final refDb = db.ref(AppConstants.fbOrders);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => Map<String, dynamic>.from(e.value as Map))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 16. Redeem Codes Provider
// ============================================================

final redeemCodesProvider = StreamProvider<List<RedeemCode>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<RedeemCode>>();
  final refDb = db.ref(AppConstants.fbRedeemCodes);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => RedeemCode.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 17. Shared Redeem Codes Provider
// ============================================================

final sharedCodesProvider = StreamProvider<List<SharedRedeemCode>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<SharedRedeemCode>>();
  final refDb = db.ref(AppConstants.fbSharedCodes);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => SharedRedeemCode.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 18. Subscription Plans Provider
// ============================================================

final subscriptionPlansProvider = StreamProvider<List<SubscriptionPlan>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<SubscriptionPlan>>();
  final refDb = db.ref(AppConstants.fbSubscriptionPlans);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => SubscriptionPlan.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 19. Starlink Orders Provider
// ============================================================

final starlinkOrdersProvider = StreamProvider<List<StarlinkOrder>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<StarlinkOrder>>();
  final refDb = db.ref(AppConstants.fbStarlinkOrders);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => StarlinkOrder.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 20. Commission Settings Provider
// ============================================================

final commissionSettingsProvider =
    StreamProvider<List<CommissionSetting>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<CommissionSetting>>();
  final refDb = db.ref(AppConstants.fbCommissionSettings);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => CommissionSetting.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 21. Commission Entries Provider
// ============================================================

final commissionEntriesProvider = StreamProvider<List<CommissionEntry>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<CommissionEntry>>();
  final refDb = db.ref(AppConstants.fbCommissionEntries);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => CommissionEntry.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 22. Home Banners Provider
// ============================================================

final homeBannersProvider = StreamProvider<List<HomeBanner>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<HomeBanner>>();
  final refDb = db.ref(AppConstants.fbHomeBanners);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => HomeBanner.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 23. Network Submissions Provider
// ============================================================

final networkSubmissionsProvider =
    StreamProvider<List<NetworkSubmission>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<NetworkSubmission>>();
  final refDb = db.ref(AppConstants.fbNetworkSubmissions);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => NetworkSubmission.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 24. Card Sale Locations Provider
// ============================================================

final saleLocationsProvider = StreamProvider<List<CardSaleLocation>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<CardSaleLocation>>();
  final refDb = db.ref(AppConstants.fbCardSaleLocations);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => CardSaleLocation.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 25. SIM Cards Provider
// ============================================================

final simsProvider = StreamProvider<List<SimCard>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<SimCard>>();
  final refDb = db.ref(AppConstants.fbSims);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => SimCard.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 26. Monthly Payouts Provider
// ============================================================

final monthlyPayoutsProvider = StreamProvider<List<MonthlyPayout>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<MonthlyPayout>>();
  final refDb = db.ref(AppConstants.fbMonthlyPayouts);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => MonthlyPayout.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 27. App Settings Provider
// ============================================================

/// Streams global app settings from the `settings` node.
/// Returns a default [AppSettings] when the node is empty.
final appSettingsProvider = StreamProvider<AppSettings>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<AppSettings>();
  final refDb = db.ref(AppConstants.fbSettings);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add(const AppSettings());
      return;
    }
    if (data is! Map<dynamic, dynamic>) {
      controller.add(const AppSettings());
      return;
    }
    final map = Map<String, dynamic>.from(data);
    controller.add(AppSettings.fromMap(map));
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 28. Is Admin Provider
// ============================================================

/// Returns `true` if the current user's role is 'admin'.
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.valueOrNull?.role == AppConstants.roleAdmin;
});

// ============================================================
// 29. Is Manager Provider
// ============================================================

/// Returns `true` if the current user's role is 'network_manager'.
final isManagerProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.valueOrNull?.role == AppConstants.roleNetworkManager;
});

// ============================================================
// 30. User Subscriptions Provider
// ============================================================

final userSubscriptionsProvider =
    StreamProvider<List<UserSubscription>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<UserSubscription>>();
  final refDb = db.ref(AppConstants.fbUserSubscriptions);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => UserSubscription.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// 31. Bulk Notifications Provider
// ============================================================

final bulkNotificationsProvider =
    StreamProvider<List<BulkNotification>>((ref) {
  final db = FirebaseDatabase.instance;
  final controller = StreamController<List<BulkNotification>>();
  final refDb = db.ref(AppConstants.fbBulkNotifications);
  final sub = refDb.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      controller.add([]);
      return;
    }
    final map = data as Map<dynamic, dynamic>;
    final list = map.entries
        .map((e) => BulkNotification.fromMap(
            Map<String, dynamic>.from(e.value as Map)))
        .toList();
    controller.add(list);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

// ============================================================
// Theme Notifier — StateNotifier<ThemeMode>
// ============================================================

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String prefKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(prefKey);
    if (saved != null) {
      state = _fromString(saved);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, _toString(mode));
  }

  Future<void> toggleTheme() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(next);
  }

  static ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// ============================================================
// Locale Notifier — StateNotifier<Locale>
// ============================================================

class LocaleNotifier extends StateNotifier<Locale> {
  static const String prefKey = 'locale';

  LocaleNotifier() : super(const Locale('ar')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(prefKey);
    if (saved != null) {
      state = Locale(saved);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, locale.languageCode);
  }

  /// Toggles between Arabic ('ar') and English ('en').
  Future<void> toggleLocale() async {
    final next =
        state.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    await setLocale(next);
  }
}

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
