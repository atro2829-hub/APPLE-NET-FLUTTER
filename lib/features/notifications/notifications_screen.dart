// ============================================================
// Apple.NET — Notifications Screen
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_database/firebase_database.dart';
import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _typeIcon(String type) {
    switch (type) {
      case 'purchase':
        return Icons.shopping_cart_rounded;
      case 'deposit':
        return Icons.account_balance_wallet_rounded;
      case 'starlink':
        return Icons.satellite_alt_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'redeem':
        return Icons.vpn_key_rounded;
      case 'system':
        return Icons.info_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'purchase':
        return AppTheme.primaryColor;
      case 'deposit':
        return AppTheme.accentGreen;
      case 'starlink':
        return AppTheme.secondaryColor;
      case 'gift':
        return AppTheme.tier2000;
      case 'redeem':
        return AppTheme.tier300;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _timeAgo(DateTime? date, AppLocalizations loc) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return loc.translate('justNow');
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${loc.translate('minutesAgo')}';
    if (diff.inHours < 24) return '${diff.inHours} ${loc.translate('hoursAgo')}';
    if (diff.inDays < 2) return loc.translate('yesterday');
    return '${diff.inDays} ${loc.translate('daysAgo')}';
  }

  Future<void> _markAsRead(String? notificationId, String? uid) async {
    if (notificationId == null || uid == null) return;
    await FirebaseDatabase.instance
        .ref('${AppConstants.fbNotifications}/$uid/$notificationId')
        .update({'isRead': true});
  }

  Future<void> _markAllAsRead(String? uid, List notifications) async {
    if (uid == null) return;
    final updates = <String, dynamic>{};
    for (final n in notifications) {
      if (!n.isRead) {
        updates['${n.id}/isRead'] = true;
      }
    }
    if (updates.isNotEmpty) {
      await FirebaseDatabase.instance
          .ref('${AppConstants.fbNotifications}/$uid')
          .update(updates);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final notificationsAsync = ref.watch(notificationsProvider);
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('notifications')),
        actions: [
          notificationsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (notifications) {
              final hasUnread = notifications.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _markAllAsRead(uid, notifications),
                child: Text(
                  loc.translate('markAllRead'),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => LoadingShimmer(type: ShimmerType.list),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (notifications) {
          if (notifications.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.notifications_off_rounded,
              title: loc.translate('noNotifications'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, i) {
              final n = notifications[i];
              final color = _typeColor(n.type);

              return AppCard(
                onTap: () {
                  if (!n.isRead) _markAsRead(n.id, uid);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Icon ──
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_typeIcon(n.type), color: color, size: 20),
                    ),
                    const SizedBox(width: 12),

                    // ── Content ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  n.title,
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: n.isRead
                                        ? FontWeight.w400
                                        : FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!n.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(left: 8, right: 8),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            n.message,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.adaptiveTextSecondary(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _timeAgo(n.createdAt, loc),
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.adaptiveTextHint(context),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
