// ============================================================
// Apple.NET — Admin Panel (Complete — 10 Tabs)
// Full control panel with permissions, bulk operations,
// Firebase realtime integration, and comprehensive management
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════════
// ADMIN PANEL — ConsumerStatefulWidget
// ═══════════════════════════════════════════════════════════════

class AdminPanel extends ConsumerStatefulWidget {
  const AdminPanel({super.key});

  @override
  ConsumerState<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends ConsumerState<AdminPanel>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AppLocalizations loc;

  final List<_AdminTab> _tabs = const [
    _AdminTab(icon: Icons.dashboard_rounded, labelKey: 'overview'),
    _AdminTab(icon: Icons.people_rounded, labelKey: 'users'),
    _AdminTab(icon: Icons.wifi_rounded, labelKey: 'networks'),
    _AdminTab(icon: Icons.style_rounded, labelKey: 'cards'),
    _AdminTab(icon: Icons.account_balance_rounded, labelKey: 'deposits'),
    _AdminTab(icon: Icons.campaign_rounded, labelKey: 'ads'),
    _AdminTab(icon: Icons.satellite_alt_rounded, labelKey: 'starlink'),
    _AdminTab(icon: Icons.vpn_key_rounded, labelKey: 'redeemCodes'),
    _AdminTab(icon: Icons.notifications_active_rounded, labelKey: 'notifications'),
    _AdminTab(icon: Icons.settings_rounded, labelKey: 'settings'),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AppTheme.animNormal,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (_currentIndex == index) return;
    _fadeController.reset();
    setState(() => _currentIndex = index);
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(loc.translate('admin'))),
        body: const LoadingShimmer(type: ShimmerType.card, itemCount: 4),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(loc.translate('admin'))),
        body: AppErrorWidget(message: e.toString()),
      ),
      data: (user) {
        if (user == null || user.role != 'admin') {
          return Scaffold(
            appBar: AppBar(title: Text(loc.translate('admin'))),
            body: EmptyStateWidget(
              icon: Icons.admin_panel_settings_rounded,
              title: loc.translate('accessDenied'),
              subtitle: loc.translate('adminOnly'),
            ),
          );
        }

        final isWide = MediaQuery.of(context).size.width >= 900;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 10),
                Text(loc.translate('admin')),
              ],
            ),
            actions: [
              if (!isWide)
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
            ],
          ),
          body: isWide
              ? _buildWideLayout()
              : _buildNarrowLayout(),
          bottomNavigationBar: isWide ? null : _buildBottomNav(loc),
        );
      },
    );
  }

  // ─── Bottom Navigation (Mobile) ───
  Widget _buildBottomNav(AppLocalizations loc) {
    return NavigationBar(
      selectedIndex: _currentIndex > 4 ? 0 : _currentIndex,
      onDestinationSelected: _onTabChanged,
      height: 70,
      destinations: _tabs.take(5).map((tab) {
        return NavigationDestination(
          icon: Icon(tab.icon),
          label: loc.translate(tab.labelKey),
        );
      }).toList(),
    );
  }

  // ─── Wide Layout (Tablet/Desktop) ───
  Widget _buildWideLayout() {
    loc = AppLocalizations.of(context);
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabChanged,
          labelType: NavigationRailLabelType.all,
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      color: AppTheme.primaryColor, size: 20),
                ),
              ],
            ),
          ),
          destinations: _tabs.map((tab) {
            return NavigationRailDestination(
              icon: Icon(tab.icon),
              label: Text(loc.translate(tab.labelKey),
                  style: const TextStyle(fontSize: 11)),
            );
          }).toList(),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildTabContent(),
          ),
        ),
      ],
    );
  }

  // ─── Narrow Layout (Mobile) ───
  Widget _buildNarrowLayout() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildTabContent(),
    );
  }

  // ─── Tab Content Router ───
  Widget _buildTabContent() {
    switch (_currentIndex) {
      case 0: return _DashboardTab();
      case 1: return _UsersTab();
      case 2: return _NetworksTab();
      case 3: return _AdminCardsTab();
      case 4: return _DepositsTab();
      case 5: return _AdminAdsTab();
      case 6: return _AdminStarlinkTab();
      case 7: return _RedeemCodesTab();
      case 8: return _AdminNotificationsTab();
      case 9: return _AdminSettingsTab();
      default: return _DashboardTab();
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB DATA CLASS
// ═══════════════════════════════════════════════════════════════

class _AdminTab {
  final IconData icon;
  final String labelKey;
  const _AdminTab({required this.icon, required this.labelKey});
}

// ═══════════════════════════════════════════════════════════════
// TAB 1 — DASHBOARD / OVERVIEW
// ═══════════════════════════════════════════════════════════════

class _DashboardTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final networksAsync = ref.watch(networksProvider);
    final cardsAsync = ref.watch(cardsProvider);
    final depositsAsync = ref.watch(depositsProvider);
    final ordersAsync = ref.watch(ordersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome Card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryDark, AppTheme.primaryColor, AppTheme.primaryLight],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.textOnPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: AppTheme.textOnPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate('welcomeAdmin'),
                            style: AppTheme.headingSmall.copyWith(
                              color: AppTheme.textOnPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${AppConstants.appName} v${AppConstants.version}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textOnPrimary.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '${loc.translate('developer')}: ${AppConstants.developerName}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textOnPrimary.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  '${loc.translate('contact')}: ${AppConstants.developerEmail}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textOnPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Key Stats Grid ──
          SectionHeader(
            title: loc.translate('stats'),
            icon: Icons.bar_chart_rounded,
          ),
          const SizedBox(height: 8),
          cardsAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.card, itemCount: 4),
            error: (_, __) => const SizedBox.shrink(),
            data: (allCards) {
              final totalCards = allCards.length;
              final availableCards = allCards.where((c) => !c.isUsed).length;
              final soldCards = allCards.where((c) => c.isUsed).length;
              final now = DateTime.now();
              final thisMonthRevenue = allCards.where((c) {
                if (!c.isUsed || c.usedAt == null) return false;
                return c.usedAt!.year == now.year && c.usedAt!.month == now.month;
              }).fold<double>(0, (sum, c) => sum + c.price);

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  StatCard(
                    icon: Icons.style_rounded,
                    value: '$totalCards',
                    title: loc.translate('totalCards'),
                    color: AppTheme.primaryColor,
                  ),
                  StatCard(
                    icon: Icons.check_circle_rounded,
                    value: '$availableCards',
                    title: loc.translate('available'),
                    color: AppTheme.accentGreen,
                  ),
                  StatCard(
                    icon: Icons.sell_rounded,
                    value: '$soldCards',
                    title: loc.translate('sold'),
                    color: AppTheme.secondaryColor,
                  ),
                  StatCard(
                    icon: Icons.payments_rounded,
                    value: '${thisMonthRevenue.toInt()} ر.ي',
                    title: loc.translate('totalRevenue'),
                    subtitle: loc.translate('thisMonth'),
                    color: AppTheme.tier500,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // ── Networks & Users Stats ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: networksAsync.when(
                  loading: () => const LoadingShimmer(type: ShimmerType.card, itemCount: 1),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (networks) => AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wifi_rounded, color: AppTheme.primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text(loc.translate('networks'), style: AppTheme.headingSmall),
                          ],
                        ),
                        const Divider(height: 24),
                        InfoRow(
                          icon: Icons.dns_rounded,
                          label: loc.translate('totalNetworks'),
                          value: '${networks.length}',
                          iconColor: AppTheme.primaryColor,
                        ),
                        ...networks.take(5).map((n) => InfoRow(
                          icon: Icons.circle_rounded,
                          label: n.name,
                          value: n.provinceName ?? '-',
                          iconColor: _parseColor(n.color, AppTheme.primaryColor),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: depositsAsync.when(
                  loading: () => const LoadingShimmer(type: ShimmerType.card, itemCount: 1),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (deposits) {
                    final pending = deposits.where((d) => d.status == 'pending').length;
                    final approved = deposits.where((d) => d.status == 'approved').length;
                    final rejected = deposits.where((d) => d.status == 'rejected').length;
                    final totalAmount = deposits
                        .where((d) => d.status == 'approved')
                        .fold<double>(0, (s, d) => s + d.amount);

                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance_rounded, color: AppTheme.secondaryColor, size: 20),
                              const SizedBox(width: 8),
                              Text(loc.translate('deposits'), style: AppTheme.headingSmall),
                            ],
                          ),
                          const Divider(height: 24),
                          InfoRow(
                            icon: Icons.pending_rounded,
                            label: loc.translate('pending'),
                            value: '$pending',
                            iconColor: AppTheme.warningColor,
                          ),
                          InfoRow(
                            icon: Icons.check_circle_rounded,
                            label: loc.translate('approved'),
                            value: '$approved',
                            iconColor: AppTheme.accentGreen,
                          ),
                          InfoRow(
                            icon: Icons.cancel_rounded,
                            label: loc.translate('rejected'),
                            value: '$rejected',
                            iconColor: AppTheme.accentRed,
                          ),
                          InfoRow(
                            icon: Icons.payments_rounded,
                            label: loc.translate('totalApproved'),
                            value: '${totalAmount.toInt()} ر.ي',
                            iconColor: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Recent Orders ──
          ordersAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 3),
            error: (_, __) => const SizedBox.shrink(),
            data: (orders) {
              if (orders.isEmpty) return const SizedBox.shrink();
              final recent = orders.take(5).toList();
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long_rounded, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(loc.translate('recentOrders'), style: AppTheme.headingSmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...recent.map((order) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: const Icon(Icons.shopping_cart_rounded,
                            color: AppTheme.primaryColor, size: 20),
                      ),
                      title: Text(
                        order['userName'] ?? '-',
                        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${order['networkName'] ?? ''} - ${order['tier'] ?? ''}',
                        style: AppTheme.bodySmall,
                      ),
                      trailing: Text(
                        '${(order['price'] as num?)?.toInt() ?? 0} ر.ي',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    )),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // ── Quick Actions ──
          SectionHeader(
            title: loc.translate('quickActions'),
            icon: Icons.bolt_rounded,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickActionChip(
                icon: Icons.style_rounded,
                label: loc.translate('manageCards'),
                color: AppTheme.primaryColor,
              ),
              _QuickActionChip(
                icon: Icons.people_rounded,
                label: loc.translate('manageUsers'),
                color: AppTheme.secondaryColor,
              ),
              _QuickActionChip(
                icon: Icons.account_balance_rounded,
                label: loc.translate('manageDeposits'),
                color: AppTheme.accentGreen,
              ),
              _QuickActionChip(
                icon: Icons.wifi_rounded,
                label: loc.translate('manageNetworks'),
                color: AppTheme.tier300,
              ),
              _QuickActionChip(
                icon: Icons.campaign_rounded,
                label: loc.translate('manageAds'),
                color: AppTheme.tier500,
              ),
              _QuickActionChip(
                icon: Icons.notifications_active_rounded,
                label: loc.translate('sendNotification'),
                color: AppTheme.tier2000,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickActionChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 2 — USERS MANAGEMENT
// ═══════════════════════════════════════════════════════════════

class _UsersTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<_UsersTab> {
  String _searchQuery = '';
  String _roleFilter = 'all';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      children: [
        // ── Search & Filters ──
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppTextField(
                controller: _searchCtrl,
                hint: loc.translate('searchUsers'),
                prefixIcon: Icons.search_rounded,
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoChip(
                    label: loc.translate('all'),
                    isSelected: _roleFilter == 'all',
                    onTap: () => setState(() => _roleFilter = 'all'),
                    color: AppTheme.primaryColor,
                  ),
                  InfoChip(
                    label: loc.translate('users'),
                    isSelected: _roleFilter == 'user',
                    onTap: () => setState(() => _roleFilter = 'user'),
                    color: AppTheme.tier300,
                  ),
                  InfoChip(
                    label: loc.translate('admin'),
                    isSelected: _roleFilter == 'admin',
                    onTap: () => setState(() => _roleFilter = 'admin'),
                    color: AppTheme.accentRed,
                  ),
                  InfoChip(
                    label: loc.translate('manager'),
                    isSelected: _roleFilter == 'network_manager',
                    onTap: () => setState(() => _roleFilter = 'network_manager'),
                    color: AppTheme.secondaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Users List ──
        Expanded(
          child: StreamBuilder<List<AppUser>>(
            stream: _usersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingShimmer(type: ShimmerType.list, itemCount: 6);
              }
              if (snapshot.hasError) {
                return AppErrorWidget(message: snapshot.error.toString());
              }

              var users = snapshot.data ?? [];
              if (_roleFilter != 'all') {
                users = users.where((u) => u.role == _roleFilter).toList();
              }
              if (_searchQuery.isNotEmpty) {
                users = users.where((u) =>
                  u.displayName.toLowerCase().contains(_searchQuery) ||
                  u.email.toLowerCase().contains(_searchQuery) ||
                  u.phone.contains(_searchQuery)
                ).toList();
              }

              if (users.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.people_rounded,
                  title: loc.translate('noUsers'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _UserCard(user: user, loc: loc);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<List<AppUser>> _usersStream() {
    final controller = StreamController<List<AppUser>>();
    final ref = FirebaseDatabase.instance.ref(AppConstants.fbUsers);
    ref.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) {
        controller.add([]);
        return;
      }
      final map = data as Map<dynamic, dynamic>;
      final list = map.entries
          .map((e) => AppUser.fromMap(Map<String, dynamic>.from(e.value as Map)))
          .toList();
      controller.add(list);
    });
    // Note: we should cancel sub on dispose, but for simplicity we handle it
    return controller.stream;
  }
}

class _UserCard extends ConsumerStatefulWidget {
  final AppUser user;
  final AppLocalizations loc;
  const _UserCard({required this.user, required this.loc});

  @override
  ConsumerState<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends ConsumerState<_UserCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final loc = widget.loc;
    final roleColor = user.role == 'admin'
        ? AppTheme.accentRed
        : user.role == 'network_manager'
            ? AppTheme.secondaryColor
            : AppTheme.primaryColor;

    return AppCard(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: Image.network(
                          user.photoUrl!,
                          errorBuilder: (_, __, ___) => Icon(Icons.person_rounded, color: roleColor),
                        ),
                      )
                    : Icon(Icons.person_rounded, color: roleColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.adaptiveTextSecondary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(
                    text: user.isActive ? AppLocalizations.of(context).translate('active') : AppLocalizations.of(context).translate('disabled'),
                    color: user.isActive ? AppTheme.accentGreen : AppTheme.accentRed,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.balance.toInt()} ر.ي',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                color: AppTheme.adaptiveTextHint(context),
              ),
            ],
          ),

          // ── Expanded Details ──
          if (_isExpanded) ...[
            const Divider(height: 24),
            InfoRow(icon: Icons.badge_rounded, label: AppLocalizations.of(context).translate('role'), value: _roleLabel(user.role), iconColor: roleColor),
            if (user.phone.isNotEmpty)
              InfoRow(icon: Icons.phone_rounded, label: AppLocalizations.of(context).translate('phone'), value: user.phone),
            if (user.managedNetwork != null)
              InfoRow(icon: Icons.wifi_rounded, label: AppLocalizations.of(context).translate('managedNetwork'), value: user.managedNetwork!),
            if (user.createdAt != null)
              InfoRow(icon: Icons.calendar_today_rounded, label: AppLocalizations.of(context).translate('registered'), value: _formatDate(user.createdAt!)),
            const SizedBox(height: 12),

            // ── Action Buttons ──
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppButton(
                  text: AppLocalizations.of(context).translate('editRole'),
                  icon: Icons.edit_rounded,
                  onPressed: () => _editUserRole(user),
                  isSmall: true,
                  isOutlined: true,
                ),
                AppButton(
                  text: AppLocalizations.of(context).translate('adjustBalance'),
                  icon: Icons.account_balance_wallet_rounded,
                  onPressed: () => _adjustBalance(user),
                  isSmall: true,
                  isOutlined: true,
                ),
                AppButton(
                  text: user.isActive ? AppLocalizations.of(context).translate('disable') : AppLocalizations.of(context).translate('enable'),
                  icon: user.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                  onPressed: () => _toggleUserActive(user),
                  isSmall: true,
                  isOutlined: true,
                  backgroundColor: user.isActive ? AppTheme.accentRed : AppTheme.accentGreen,
                ),
                AppButton(
                  text: AppLocalizations.of(context).translate('delete'),
                  icon: Icons.delete_rounded,
                  onPressed: () => _deleteUser(user),
                  isSmall: true,
                  isOutlined: true,
                  backgroundColor: AppTheme.accentRed,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin': return AppLocalizations.of(context).translate('admin');
      case 'network_manager': return AppLocalizations.of(context).translate('manager');
      default: return AppLocalizations.of(context).translate('users');
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _editUserRole(AppUser user) async {
    final roles = ['user', 'admin', 'network_manager'];
    String? selectedRole = user.role;
    String? selectedNetwork;

    final networks = ref.read(networksProvider).value ?? [];

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          title: Text(AppLocalizations.of(context).translate('editRole')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${user.displayName} (${user.email})', style: AppTheme.bodySmall),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context).translate('selectRole'), style: AppTheme.labelMedium),
              const SizedBox(height: 8),
              ...roles.map((role) => RadioListTile<String>(
                value: role,
                groupValue: selectedRole,
                title: Text(_roleLabel(role)),
                onChanged: (v) => setDialogState(() => selectedRole = v),
                contentPadding: EdgeInsets.zero,
                dense: true,
              )),
              if (selectedRole == 'network_manager') ...[
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context).translate('assignNetwork'), style: AppTheme.labelMedium),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: selectedNetwork ?? (networks.isNotEmpty ? networks.first.id : null),
                  isExpanded: true,
                  items: networks.map((n) => DropdownMenuItem(
                    value: n.id,
                    child: Text(n.name),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => selectedNetwork = v),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context).translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, {
                'role': selectedRole ?? 'user',
                'network': selectedNetwork ?? '',
              }),
              child: Text(AppLocalizations.of(context).translate('save')),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    final updates = <String, dynamic>{
      'role': result['role'],
    };
    if (result['role'] == 'network_manager' && result['network']!.isNotEmpty) {
      updates['managedNetwork'] = result['network'];
    } else if (result['role'] != 'network_manager') {
      updates['managedNetwork'] = null;
    }

    await FirebaseDatabase.instance
        .ref('${AppConstants.fbUsers}/${user.uid}')
        .update(updates);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('roleUpdated')), backgroundColor: AppTheme.accentGreen),
      );
    }
  }

  Future<void> _adjustBalance(AppUser user) async {
    final amountCtrl = TextEditingController();
    String operation = 'add';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          title: Text(AppLocalizations.of(context).translate('adjustBalance')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${user.displayName} - ${user.balance.toInt()} ر.ي', style: AppTheme.bodySmall),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'add',
                      groupValue: operation,
                      title: Text(AppLocalizations.of(context).translate('add')),
                      onChanged: (v) => setDialogState(() => operation = v!),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'subtract',
                      groupValue: operation,
                      title: Text(AppLocalizations.of(context).translate('subtract')),
                      onChanged: (v) => setDialogState(() => operation = v!),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: amountCtrl,
                label: AppLocalizations.of(context).translate('amount'),
                keyboardType: TextInputType.number,
                prefixIcon: Icons.payments_rounded,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context).translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, {
                'operation': operation,
                'amount': double.tryParse(amountCtrl.text) ?? 0,
              }),
              child: Text(AppLocalizations.of(context).translate('confirm')),
            ),
          ],
        ),
      ),
    );

    if (result == null || result['amount'] == 0) return;

    final amount = result['amount'] as double;
    final delta = result['operation'] == 'add' ? amount : -amount;

    await FirebaseDatabase.instance
        .ref('${AppConstants.fbUsers}/${user.uid}/balance')
        .set(ServerValue.increment(delta));

    // Add credit history
    await FirebaseDatabase.instance
        .ref('${AppConstants.fbCredit}/${user.uid}/history')
        .push()
        .set({
      'type': result['operation'] == 'add' ? 'gift' : 'purchase',
      'amount': delta,
      'description': 'Admin balance adjustment',
      'date': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('balanceUpdated')), backgroundColor: AppTheme.accentGreen),
      );
    }
  }

  Future<void> _toggleUserActive(AppUser user) async {
    await FirebaseDatabase.instance
        .ref('${AppConstants.fbUsers}/${user.uid}/isActive')
        .set(!user.isActive);
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(AppLocalizations.of(context).translate('confirmDelete')),
        content: Text('${user.displayName} (${user.email})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).translate('delete'),
                style: const TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await FirebaseDatabase.instance
        .ref('${AppConstants.fbUsers}/${user.uid}')
        .remove();
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 3 — NETWORKS MANAGEMENT
// ═══════════════════════════════════════════════════════════════

class _NetworksTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_NetworksTab> createState() => _NetworksTabState();
}

class _NetworksTabState extends ConsumerState<_NetworksTab> {
  final _nameCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _emojiCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _ownerPhoneCtrl = TextEditingController();
  final _ipCtrl = TextEditingController();
  final _coverageCtrl = TextEditingController();
  final _speedCtrl = TextEditingController();
  final _networkTypeCtrl = TextEditingController();
  String? _selectedProvinceId;
  String? _selectedDistrict;
  String? _editingId;
  bool _isSaving = false;
  bool _showForm = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _colorCtrl.dispose();
    _emojiCtrl.dispose();
    _ownerNameCtrl.dispose();
    _ownerPhoneCtrl.dispose();
    _ipCtrl.dispose();
    _coverageCtrl.dispose();
    _speedCtrl.dispose();
    _networkTypeCtrl.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameCtrl.clear();
    _colorCtrl.clear();
    _emojiCtrl.clear();
    _ownerNameCtrl.clear();
    _ownerPhoneCtrl.clear();
    _ipCtrl.clear();
    _coverageCtrl.clear();
    _speedCtrl.clear();
    _networkTypeCtrl.clear();
    setState(() {
      _editingId = null;
      _selectedProvinceId = null;
      _selectedDistrict = null;
      _showForm = false;
    });
  }

  void _populateForm(NetworkModel network) {
    _nameCtrl.text = network.name;
    _colorCtrl.text = network.color;
    _emojiCtrl.text = network.emoji;
    _ownerNameCtrl.text = network.ownerName;
    _ownerPhoneCtrl.text = network.ownerPhone ?? '';
    _ipCtrl.text = network.connectionIP ?? '';
    _coverageCtrl.text = network.coverage ?? '';
    _speedCtrl.text = network.speed ?? '';
    _networkTypeCtrl.text = network.networkType ?? '';
    setState(() {
      _editingId = network.id;
      _selectedProvinceId = network.provinceId;
      _selectedDistrict = network.district;
      _showForm = true;
    });
  }

  Future<void> _saveNetwork() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    try {
      final db = FirebaseDatabase.instance;
      final provinceName = _selectedProvinceId != null
          ? AppConstants.getProvinceName(_selectedProvinceId!)
          : null;

      if (_editingId != null) {
        await db.ref('${AppConstants.fbNetworks}/$_editingId').update({
          'name': _nameCtrl.text.trim(),
          'color': _colorCtrl.text.trim().isNotEmpty ? _colorCtrl.text.trim() : '#0D7377',
          'emoji': _emojiCtrl.text.trim().isNotEmpty ? _emojiCtrl.text.trim() : '📡',
          'ownerName': _ownerNameCtrl.text.trim(),
          'ownerPhone': _ownerPhoneCtrl.text.trim(),
          'connectionIP': _ipCtrl.text.trim(),
          'coverage': _coverageCtrl.text.trim(),
          'speed': _speedCtrl.text.trim(),
          'networkType': _networkTypeCtrl.text.trim(),
          'provinceId': _selectedProvinceId,
          'provinceName': provinceName,
          'district': _selectedDistrict,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } else {
        final ref = db.ref(AppConstants.fbNetworks).push();
        await ref.set({
          'id': ref.key,
          'name': _nameCtrl.text.trim(),
          'color': _colorCtrl.text.trim().isNotEmpty ? _colorCtrl.text.trim() : '#0D7377',
          'bgColor': '#E8F5E9',
          'emoji': _emojiCtrl.text.trim().isNotEmpty ? _emojiCtrl.text.trim() : '📡',
          'ownerId': '',
          'ownerName': _ownerNameCtrl.text.trim(),
          'ownerPhone': _ownerPhoneCtrl.text.trim(),
          'provinceId': _selectedProvinceId,
          'provinceName': provinceName,
          'district': _selectedDistrict,
          'connectionIP': _ipCtrl.text.trim(),
          'coverage': _coverageCtrl.text.trim(),
          'speed': _speedCtrl.text.trim(),
          'networkType': _networkTypeCtrl.text.trim(),
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
      _clearForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.accentRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteNetwork(NetworkModel network) async {
    final loc = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(loc.translate('confirmDelete')),
        content: Text(network.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.translate('delete'),
                style: const TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await FirebaseDatabase.instance
        .ref('${AppConstants.fbNetworks}/${network.id}')
        .remove();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final networksAsync = ref.watch(networksProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Add Button ──
          AppButton(
            text: _showForm
                ? loc.translate('cancel')
                : loc.translate('addNetwork'),
            icon: _showForm ? Icons.close_rounded : Icons.add_rounded,
            onPressed: () {
              if (_showForm) {
                _clearForm();
              } else {
                setState(() => _showForm = true);
              }
            },
            isOutlined: _showForm,
          ),
          const SizedBox(height: 16),

          // ── Add/Edit Form ──
          if (_showForm) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _editingId != null
                        ? loc.translate('editNetwork')
                        : loc.translate('addNetwork'),
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: AppTextField(
                          label: loc.translate('emoji'),
                          controller: _emojiCtrl,
                          hint: '📡',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: loc.translate('networkName'),
                          controller: _nameCtrl,
                          hint: 'Apple Net',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: loc.translate('color'),
                          controller: _colorCtrl,
                          hint: '#0D7377',
                          prefixIcon: Icons.palette_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: loc.translate('networkType'),
                          controller: _networkTypeCtrl,
                          hint: 'WiFi / LTE',
                          prefixIcon: Icons.router_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: loc.translate('ownerName'),
                          controller: _ownerNameCtrl,
                          prefixIcon: Icons.person_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: loc.translate('ownerPhone'),
                          controller: _ownerPhoneCtrl,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Province Dropdown
                  Text(loc.translate('province'), style: AppTheme.labelMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedProvinceId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.adaptiveCardColor(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    hint: Text(loc.translate('selectProvince')),
                    items: AppConstants.provinces.map((p) => DropdownMenuItem(
                      value: p['id'] as String,
                      child: Text(p['name'] as String, style: AppTheme.bodySmall),
                    )).toList(),
                    onChanged: (v) => setState(() {
                      _selectedProvinceId = v;
                      _selectedDistrict = null;
                    }),
                  ),
                  const SizedBox(height: 12),

                  // District Dropdown
                  if (_selectedProvinceId != null) ...[
                    Text(loc.translate('district'), style: AppTheme.labelMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.adaptiveCardColor(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      hint: Text(loc.translate('selectDistrict')),
                      items: AppConstants.getDistricts(_selectedProvinceId!)
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(d, style: AppTheme.bodySmall),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedDistrict = v),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: loc.translate('connectionIP'),
                          controller: _ipCtrl,
                          prefixIcon: Icons.dns_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: loc.translate('coverage'),
                          controller: _coverageCtrl,
                          prefixIcon: Icons.wifi_tethering_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: loc.translate('speed'),
                    controller: _speedCtrl,
                    hint: '100 Mbps',
                    prefixIcon: Icons.speed_rounded,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: loc.translate('save'),
                    icon: Icons.save_rounded,
                    isLoading: _isSaving,
                    onPressed: _saveNetwork,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Networks List ──
          networksAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 4),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (networks) {
              if (networks.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.wifi_rounded,
                  title: loc.translate('noNetworks'),
                );
              }
              return Column(
                children: networks.map((network) => AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _parseColor(network.color, AppTheme.primaryColor).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Center(
                              child: Text(network.emoji, style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(network.name, style: AppTheme.titleMedium),
                                if (network.provinceName != null)
                                  Text(
                                    '${network.provinceName}${network.district != null ? ' - ${network.district}' : ''}',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.adaptiveTextSecondary(context),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (action) {
                              if (action == 'edit') _populateForm(network);
                              if (action == 'delete') _deleteNetwork(network);
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(value: 'edit', child: Text(loc.translate('edit'))),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(loc.translate('delete'),
                                    style: const TextStyle(color: AppTheme.accentRed)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (network.ownerName.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        InfoRow(icon: Icons.person_rounded, label: loc.translate('owner'), value: network.ownerName),
                      ],
                      if (network.connectionIP != null && network.connectionIP!.isNotEmpty)
                        InfoRow(icon: Icons.dns_rounded, label: 'IP', value: network.connectionIP!),
                      if (network.networkType != null)
                        InfoRow(icon: Icons.router_rounded, label: loc.translate('networkType'), value: network.networkType!),
                    ],
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 4 — CARDS MANAGEMENT (Admin View — All Networks)
// ═══════════════════════════════════════════════════════════════

class _AdminCardsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AdminCardsTab> createState() => _AdminCardsTabState();
}

class _AdminCardsTabState extends ConsumerState<_AdminCardsTab> {
  String _filterNetwork = 'all';
  String _filterTier = 'all';
  String _filterStatus = 'all';
  bool _showBulkForm = false;
  final _bulkCodesCtrl = TextEditingController();
  String _bulkNetworkId = '';
  String _bulkTier = '';
  int _bulkProgress = 0;
  int _bulkTotal = 0;

  @override
  void dispose() {
    _bulkCodesCtrl.dispose();
    super.dispose();
  }

  List<CardModel> _filterCards(List<CardModel> cards) {
    var filtered = cards;
    if (_filterNetwork != 'all') {
      filtered = filtered.where((c) => c.network == _filterNetwork).toList();
    }
    if (_filterTier != 'all') {
      filtered = filtered.where((c) => c.tier == _filterTier).toList();
    }
    if (_filterStatus == 'available') {
      filtered = filtered.where((c) => !c.isUsed).toList();
    } else if (_filterStatus == 'sold') {
      filtered = filtered.where((c) => c.isUsed).toList();
    }
    return filtered;
  }

  Future<void> _addBulkCards() async {
    final lines = _bulkCodesCtrl.text.trim().split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty || _bulkNetworkId.isEmpty || _bulkTier.isEmpty) return;

    setState(() {
      _bulkTotal = lines.length;
      _bulkProgress = 0;
    });

    final networks = ref.read(networksProvider).value ?? [];
    final network = networks.firstWhere((n) => n.id == _bulkNetworkId);
    final allTiers = ref.read(tiersProvider).value ?? [];
    final tierInfo = allTiers.where((t) =>
        (t.networkId == _bulkNetworkId || t.networkId == null) &&
        t.tier == _bulkTier).firstOrNull;
    final db = FirebaseDatabase.instance;

    for (int i = 0; i < lines.length; i++) {
      try {
        final ref = db.ref(AppConstants.fbCards).push();
        await ref.set({
          'id': ref.key,
          'code': lines[i].trim(),
          'price': tierInfo?.price ?? 0,
          'data': tierInfo?.data ?? '',
          'duration': tierInfo?.duration ?? 0,
          'isUsed': false,
          'tier': _bulkTier,
          'network': _bulkNetworkId,
          'networkName': network.name,
          'createdAt': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
      if (mounted) setState(() => _bulkProgress = i + 1);
    }

    _bulkCodesCtrl.clear();
    if (mounted) {
      setState(() {
        _bulkTotal = 0;
        _bulkProgress = 0;
        _showBulkForm = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${lines.length} cards'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
    }
  }

  Future<void> _deleteCard(CardModel card) async {
    await FirebaseDatabase.instance
        .ref('${AppConstants.fbCards}/${card.id}')
        .remove();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cardsAsync = ref.watch(cardsProvider);
    final networksAsync = ref.watch(networksProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Bulk Add Button ──
          AppButton(
            text: _showBulkForm ? loc.translate('cancel') : loc.translate('bulkAdd'),
            icon: _showBulkForm ? Icons.close_rounded : Icons.playlist_add_rounded,
            onPressed: () => setState(() => _showBulkForm = !_showBulkForm),
            isOutlined: _showBulkForm,
          ),
          const SizedBox(height: 16),

          // ── Bulk Add Form ──
          if (_showBulkForm) ...[
            networksAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (networks) => AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.translate('bulkAdd'), style: AppTheme.headingSmall),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _bulkNetworkId.isNotEmpty ? _bulkNetworkId : null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.adaptiveCardColor(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      hint: Text(loc.translate('selectNetwork')),
                      items: networks.map((n) => DropdownMenuItem(
                        value: n.id,
                        child: Text('${n.emoji} ${n.name}'),
                      )).toList(),
                      onChanged: (v) => setState(() => _bulkNetworkId = v ?? ''),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _bulkTier.isNotEmpty ? _bulkTier : null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.adaptiveCardColor(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      hint: Text(loc.translate('selectTier')),
                      items: AppConstants.defaultTiers.map((t) => DropdownMenuItem(
                        value: t['tier'] as String,
                        child: Text('${t['icon']} ${t['tier']} - ${t['price']} ر.ي'),
                      )).toList(),
                      onChanged: (v) => setState(() => _bulkTier = v ?? ''),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: loc.translate('pasteCodes'),
                      controller: _bulkCodesCtrl,
                      hint: 'Paste one code per line',
                      prefixIcon: Icons.paste_rounded,
                      maxLines: 8,
                    ),
                    if (_bulkTotal > 0) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _bulkProgress / _bulkTotal,
                        backgroundColor: AppTheme.dividerColor,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 4),
                      Text('$_bulkProgress / $_bulkTotal', style: AppTheme.bodySmall),
                    ],
                    const SizedBox(height: 16),
                    AppButton(
                      text: loc.translate('add'),
                      icon: Icons.playlist_add_rounded,
                      onPressed: _bulkTotal > 0 ? null : _addBulkCards,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Filters ──
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(
                label: loc.translate('allNetworks'),
                isSelected: _filterNetwork == 'all',
                onTap: () => setState(() => _filterNetwork = 'all'),
                color: AppTheme.primaryColor,
              ),
              ...networksAsync.value?.map((n) => InfoChip(
                    label: '${n.emoji} ${n.name}',
                    isSelected: _filterNetwork == n.id,
                    onTap: () => setState(() => _filterNetwork = n.id),
                    color: _parseColor(n.color, AppTheme.primaryColor),
                  )) ?? [],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(label: loc.translate('all'), isSelected: _filterTier == 'all', onTap: () => setState(() => _filterTier = 'all'), color: AppTheme.primaryColor),
              InfoChip(label: '200', isSelected: _filterTier == '200', onTap: () => setState(() => _filterTier = '200'), color: AppTheme.tier200),
              InfoChip(label: '300', isSelected: _filterTier == '300', onTap: () => setState(() => _filterTier = '300'), color: AppTheme.tier300),
              InfoChip(label: '500', isSelected: _filterTier == '500', onTap: () => setState(() => _filterTier = '500'), color: AppTheme.tier500),
              InfoChip(label: '1000', isSelected: _filterTier == '1000', onTap: () => setState(() => _filterTier = '1000'), color: AppTheme.tier1000),
              InfoChip(label: '2000', isSelected: _filterTier == '2000', onTap: () => setState(() => _filterTier = '2000'), color: AppTheme.tier2000),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(label: loc.translate('all'), isSelected: _filterStatus == 'all', onTap: () => setState(() => _filterStatus = 'all'), color: AppTheme.primaryColor),
              InfoChip(label: loc.translate('available'), icon: Icons.check_circle_rounded, isSelected: _filterStatus == 'available', onTap: () => setState(() => _filterStatus = 'available'), color: AppTheme.accentGreen),
              InfoChip(label: loc.translate('sold'), icon: Icons.sell_rounded, isSelected: _filterStatus == 'sold', onTap: () => setState(() => _filterStatus = 'sold'), color: AppTheme.secondaryColor),
            ],
          ),
          const SizedBox(height: 16),

          // ── Cards List ──
          cardsAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 6),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (allCards) {
              final cards = _filterCards(allCards);
              if (cards.isEmpty) {
                return EmptyStateWidget(icon: Icons.style_rounded, title: loc.translate('noCards'));
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${loc.translate('totalCards')}: ${cards.length}',
                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ...cards.take(100).map((card) => AppCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.getTierColor(card.tier).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Icon(
                            Icons.style_rounded,
                            color: AppTheme.getTierColor(card.tier),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.code,
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    '${card.networkName} | ${card.tier} | ${card.price.toInt()} ر.ي',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.adaptiveTextSecondary(context),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  StatusBadge(
                                    text: card.isUsed ? loc.translate('used') : loc.translate('available'),
                                    color: card.isUsed ? AppTheme.accentRed : AppTheme.accentGreen,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppTheme.accentRed, size: 20),
                          onPressed: () => _deleteCard(card),
                        ),
                      ],
                    ),
                  )),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 5 — DEPOSITS MANAGEMENT
// ═══════════════════════════════════════════════════════════════

class _DepositsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DepositsTab> createState() => _DepositsTabState();
}

class _DepositsTabState extends ConsumerState<_DepositsTab> {
  String _filterStatus = 'pending';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final depositsAsync = ref.watch(depositsProvider);

    return Column(
      children: [
        // ── Status Filters ──
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(
                label: loc.translate('pending'),
                icon: Icons.pending_rounded,
                isSelected: _filterStatus == 'pending',
                onTap: () => setState(() => _filterStatus = 'pending'),
                color: AppTheme.warningColor,
              ),
              InfoChip(
                label: loc.translate('approved'),
                icon: Icons.check_circle_rounded,
                isSelected: _filterStatus == 'approved',
                onTap: () => setState(() => _filterStatus = 'approved'),
                color: AppTheme.accentGreen,
              ),
              InfoChip(
                label: loc.translate('rejected'),
                icon: Icons.cancel_rounded,
                isSelected: _filterStatus == 'rejected',
                onTap: () => setState(() => _filterStatus = 'rejected'),
                color: AppTheme.accentRed,
              ),
              InfoChip(
                label: loc.translate('all'),
                isSelected: _filterStatus == 'all',
                onTap: () => setState(() => _filterStatus = 'all'),
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),

        // ── Deposits List ──
        Expanded(
          child: depositsAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 6),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (deposits) {
              var filtered = deposits;
              if (_filterStatus != 'all') {
                filtered = deposits.where((d) => d.status == _filterStatus).toList();
              }
              if (filtered.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.account_balance_rounded,
                  title: loc.translate('noDeposits'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final deposit = filtered[index];
                  return _DepositCard(deposit: deposit, loc: loc);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DepositCard extends ConsumerWidget {
  final DepositRequest deposit;
  final AppLocalizations loc;

  const _DepositCard({required this.deposit, required this.loc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = deposit.status == 'approved'
        ? AppTheme.accentGreen
        : deposit.status == 'rejected'
            ? AppTheme.accentRed
            : AppTheme.warningColor;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(
                  deposit.status == 'approved'
                      ? Icons.check_circle_rounded
                      : deposit.status == 'rejected'
                          ? Icons.cancel_rounded
                          : Icons.pending_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deposit.userName,
                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      deposit.userEmail,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.adaptiveTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${deposit.amount.toInt()} ر.ي',
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  StatusBadge(text: loc.translate(deposit.status), color: statusColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoRow(icon: Icons.account_balance_rounded, label: loc.translate('bank'), value: deposit.bankName),
          InfoRow(icon: Icons.confirmation_number_rounded, label: loc.translate('referenceNumber'), value: deposit.referenceNumber),
          if (deposit.createdAt != null)
            InfoRow(icon: Icons.access_time_rounded, label: loc.translate('date'), value: _formatDate(deposit.createdAt!)),
          if (deposit.rejectionReason != null)
            InfoRow(
              icon: Icons.info_rounded,
              label: loc.translate('rejectionReason'),
              value: deposit.rejectionReason!,
              iconColor: AppTheme.accentRed,
            ),

          // ── Action Buttons ──
          if (deposit.status == 'pending') ...[
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: loc.translate('approve'),
                    icon: Icons.check_rounded,
                    onPressed: () => _approveDeposit(ref),
                    isSmall: true,
                    backgroundColor: AppTheme.accentGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    text: loc.translate('reject'),
                    icon: Icons.close_rounded,
                    onPressed: () => _rejectDeposit(ref),
                    isSmall: true,
                    isOutlined: true,
                    backgroundColor: AppTheme.accentRed,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _approveDeposit(WidgetRef ref) async {
    try {
      // Update deposit status
      await FirebaseDatabase.instance
          .ref('${AppConstants.fbDeposits}/${deposit.id}')
          .update({'status': 'approved'});

      // Add balance to user
      await FirebaseDatabase.instance
          .ref('${AppConstants.fbUsers}/${deposit.userId}/balance')
          .set(ServerValue.increment(deposit.amount));

      // Add credit history
      await FirebaseDatabase.instance
          .ref('${AppConstants.fbCredit}/${deposit.userId}/history')
          .push()
          .set({
        'type': 'deposit',
        'amount': deposit.amount,
        'description': 'Deposit approved - ${deposit.bankName}',
        'date': DateTime.now().toIso8601String(),
      });

      // Send notification
      await FirebaseDatabase.instance
          .ref('${AppConstants.fbNotifications}/${deposit.userId}')
          .push()
          .set({
        'type': 'deposit',
        'title': loc.translate('depositApproved'),
        'message': '${deposit.amount.toInt()} ر.ي - ${deposit.bankName}',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Error handled silently
    }
  }

  Future<void> _rejectDeposit(WidgetRef ref) async {
    final reasonCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: ref.context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(loc.translate('rejectDeposit')),
        content: AppTextField(
          controller: reasonCtrl,
          label: loc.translate('rejectionReason'),
          hint: loc.translate('enterRejectionReason'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: Text(loc.translate('reject')),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseDatabase.instance
        .ref('${AppConstants.fbDeposits}/${deposit.id}')
        .update({
      'status': 'rejected',
      'rejectionReason': reasonCtrl.text.trim(),
    });

    // Send notification
    await FirebaseDatabase.instance
        .ref('${AppConstants.fbNotifications}/${deposit.userId}')
        .push()
        .set({
      'type': 'deposit',
      'title': loc.translate('depositRejected'),
      'message': reasonCtrl.text.trim(),
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 6 — ADVERTISEMENTS MANAGEMENT
// ═══════════════════════════════════════════════════════════════

class _AdminAdsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AdminAdsTab> createState() => _AdminAdsTabState();
}

class _AdminAdsTabState extends ConsumerState<_AdminAdsTab> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageBase64Ctrl = TextEditingController();
  bool _isActive = true;
  String? _editingId;
  bool _isSaving = false;
  bool _showForm = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _imageBase64Ctrl.dispose();
    super.dispose();
  }

  Future<void> _saveAd() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final db = FirebaseDatabase.instance;
      if (_editingId != null) {
        final updates = <String, dynamic>{
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'isActive': _isActive,
        };
        if (_imageBase64Ctrl.text.trim().isNotEmpty) {
          updates['imageBase64'] = _imageBase64Ctrl.text.trim();
        }
        await db.ref('${AppConstants.fbAds}/$_editingId').update(updates);
      } else {
        final ref = db.ref(AppConstants.fbAds).push();
        await ref.set({
          'id': ref.key,
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'imageBase64': _imageBase64Ctrl.text.trim().isNotEmpty ? _imageBase64Ctrl.text.trim() : null,
          'isActive': _isActive,
        });
      }
      _clearForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _clearForm() {
    _titleCtrl.clear();
    _descCtrl.clear();
    _imageBase64Ctrl.clear();
    setState(() {
      _editingId = null;
      _isActive = true;
      _showForm = false;
    });
  }

  void _populateForm(Advertisement ad) {
    _titleCtrl.text = ad.title;
    _descCtrl.text = ad.description;
    _imageBase64Ctrl.text = ad.imageBase64 ?? '';
    setState(() {
      _editingId = ad.id;
      _isActive = ad.isActive;
      _showForm = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final adsAsync = ref.watch(adsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppButton(
            text: _showForm ? loc.translate('cancel') : loc.translate('addAd'),
            icon: _showForm ? Icons.close_rounded : Icons.add_rounded,
            onPressed: () {
              if (_showForm) _clearForm();
              else setState(() => _showForm = true);
            },
            isOutlined: _showForm,
          ),
          const SizedBox(height: 16),

          if (_showForm) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_editingId != null ? loc.translate('editAd') : loc.translate('addAd'), style: AppTheme.headingSmall),
                  const SizedBox(height: 16),
                  AppTextField(label: loc.translate('title'), controller: _titleCtrl, prefixIcon: Icons.title_rounded),
                  const SizedBox(height: 12),
                  AppTextField(label: loc.translate('description'), controller: _descCtrl, maxLines: 3, prefixIcon: Icons.description_rounded),
                  const SizedBox(height: 12),
                  AppTextField(label: loc.translate('imageBase64'), controller: _imageBase64Ctrl, hint: 'Base64 encoded image (optional)', prefixIcon: Icons.image_rounded, maxLines: 3),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _isActive,
                    title: Text(loc.translate('active')),
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  const SizedBox(height: 16),
                  AppButton(text: loc.translate('save'), icon: Icons.save_rounded, isLoading: _isSaving, onPressed: _saveAd),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          adsAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 3),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (ads) {
              if (ads.isEmpty) return EmptyStateWidget(icon: Icons.campaign_rounded, title: loc.translate('noAds'));
              return Column(
                children: ads.map((ad) => AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (ad.isActive ? AppTheme.primaryColor : AppTheme.textHint).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: Icon(Icons.campaign_rounded,
                            color: ad.isActive ? AppTheme.primaryColor : AppTheme.textHint, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ad.title, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                            Text(ad.description, style: AppTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      StatusBadge(text: ad.isActive ? loc.translate('active') : loc.translate('inactive'),
                          color: ad.isActive ? AppTheme.accentGreen : AppTheme.textHint),
                      PopupMenuButton<String>(
                        onSelected: (action) {
                          if (action == 'edit') _populateForm(ad);
                          if (action == 'toggle') {
                            FirebaseDatabase.instance.ref('${AppConstants.fbAds}/${ad.id}/isActive').set(!ad.isActive);
                          }
                          if (action == 'delete') {
                            FirebaseDatabase.instance.ref('${AppConstants.fbAds}/${ad.id}').remove();
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'edit', child: Text(loc.translate('edit'))),
                          PopupMenuItem(value: 'toggle', child: Text(ad.isActive ? loc.translate('deactivate') : loc.translate('activate'))),
                          PopupMenuItem(value: 'delete', child: Text(loc.translate('delete'), style: const TextStyle(color: AppTheme.accentRed))),
                        ],
                      ),
                    ],
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 7 — STARLINK MANAGEMENT
// ═══════════════════════════════════════════════════════════════

class _AdminStarlinkTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AdminStarlinkTab> createState() => _AdminStarlinkTabState();
}

class _AdminStarlinkTabState extends ConsumerState<_AdminStarlinkTab> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final productsAsync = ref.watch(starlinkProductsProvider);
    final ordersAsync = ref.watch(starlinkOrdersProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: loc.translate('products')),
              Tab(text: loc.translate('orders')),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // ── Products Tab ──
                productsAsync.when(
                  loading: () => const LoadingShimmer(type: ShimmerType.list),
                  error: (e, _) => AppErrorWidget(message: e.toString()),
                  data: (products) => ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return AppCard(
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.tier300.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              ),
                              child: const Icon(Icons.satellite_alt_rounded, color: AppTheme.tier300, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                  Text('\$${p.priceUSD.toInt()} | Qty: ${p.quantity}', style: AppTheme.bodySmall),
                                ],
                              ),
                            ),
                            StatusBadge(text: p.isActive ? loc.translate('active') : loc.translate('inactive'),
                                color: p.isActive ? AppTheme.accentGreen : AppTheme.textHint),
                            IconButton(
                              icon: Icon(p.isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                                  color: p.isActive ? AppTheme.accentGreen : AppTheme.textHint),
                              onPressed: () => FirebaseDatabase.instance
                                  .ref('${AppConstants.fbStarlinkProducts}/${p.id}/isActive')
                                  .set(!p.isActive),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ── Orders Tab ──
                ordersAsync.when(
                  loading: () => const LoadingShimmer(type: ShimmerType.list),
                  error: (e, _) => AppErrorWidget(message: e.toString()),
                  data: (orders) {
                    if (orders.isEmpty) return EmptyStateWidget(icon: Icons.shopping_cart_rounded, title: loc.translate('noOrders'));
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final o = orders[index];
                        final statusColor = o.status == 'delivered' ? AppTheme.accentGreen
                            : o.status == 'cancelled' ? AppTheme.accentRed
                            : AppTheme.warningColor;
                        return AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(o.userName, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                        Text(o.productName, style: AppTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  StatusBadge(text: o.status, color: statusColor),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('\$${o.priceUSD.toInt()}', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                                  const Spacer(),
                                  if (o.status == 'pending')
                                    DropdownButton<String>(
                                      value: o.status,
                                      items: ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled']
                                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                          .toList(),
                                      onChanged: (newStatus) {
                                        if (newStatus != null) {
                                          FirebaseDatabase.instance
                                              .ref('${AppConstants.fbStarlinkOrders}/${o.id}/status')
                                              .set(newStatus);
                                        }
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 8 — REDEEM CODES MANAGEMENT
// ═══════════════════════════════════════════════════════════════

class _RedeemCodesTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_RedeemCodesTab> createState() => _RedeemCodesTabState();
}

class _RedeemCodesTabState extends ConsumerState<_RedeemCodesTab> {
  final _codeCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _createCode() async {
    if (_codeCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final ref = FirebaseDatabase.instance.ref(AppConstants.fbRedeemCodes).push();
      await ref.set({
        'id': ref.key,
        'code': _codeCtrl.text.trim(),
        'amount': double.tryParse(_amountCtrl.text) ?? 0,
        'isUsed': false,
        'createdBy': fb_auth.FirebaseAuth.instance.currentUser?.uid,
        'createdAt': DateTime.now().toIso8601String(),
      });
      _codeCtrl.clear();
      _amountCtrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _generateRandomCode() async {
    final random = DateTime.now().millisecondsSinceEpoch;
    final code = 'APPLE${random.toString().substring(random.toString().length - 6)}';
    _codeCtrl.text = code;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final codesAsync = ref.watch(redeemCodesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Create Code Form ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.translate('createRedeemCode'), style: AppTheme.headingSmall),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: loc.translate('code'),
                        controller: _codeCtrl,
                        hint: 'APPLE123456',
                        prefixIcon: Icons.vpn_key_rounded,
                        keyboardType: TextInputType.visiblePassword,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        icon: const Icon(Icons.casino_rounded),
                        onPressed: _generateRandomCode,
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: loc.translate('amount'),
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.payments_rounded,
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: loc.translate('create'),
                  icon: Icons.add_rounded,
                  isLoading: _isSaving,
                  onPressed: _createCode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Codes List ──
          codesAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 4),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (codes) {
              if (codes.isEmpty) {
                return EmptyStateWidget(icon: Icons.vpn_key_rounded, title: loc.translate('noRedeemCodes'));
              }
              return Column(
                children: codes.map((code) => AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (code.isUsed ? AppTheme.accentRed : AppTheme.accentGreen).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: Icon(Icons.vpn_key_rounded,
                            color: code.isUsed ? AppTheme.accentRed : AppTheme.accentGreen, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(code.code, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontFamily: 'monospace')),
                            Text('${code.amount.toInt()} ر.ي ${code.isUsed ? '- ${code.usedByName ?? ''}' : ''}',
                                style: AppTheme.bodySmall),
                          ],
                        ),
                      ),
                      StatusBadge(
                        text: code.isUsed ? loc.translate('used') : loc.translate('available'),
                        color: code.isUsed ? AppTheme.accentRed : AppTheme.accentGreen,
                      ),
                      if (!code.isUsed)
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: code.code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate('copied'))),
                            );
                          },
                        ),
                    ],
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 9 — NOTIFICATIONS (Bulk Send)
// ═══════════════════════════════════════════════════════════════

class _AdminNotificationsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AdminNotificationsTab> createState() => _AdminNotificationsTabState();
}

class _AdminNotificationsTabState extends ConsumerState<_AdminNotificationsTab> {
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _type = 'general';
  bool _isSending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendBulkNotification() async {
    if (_titleCtrl.text.trim().isEmpty || _messageCtrl.text.trim().isEmpty) return;
    setState(() => _isSending = true);

    try {
      final db = FirebaseDatabase.instance;
      final loc = AppLocalizations.of(context);

      // Get all users
      final usersSnapshot = await db.ref(AppConstants.fbUsers).get();
      int count = 0;
      if (usersSnapshot.exists) {
        final usersMap = usersSnapshot.value as Map<dynamic, dynamic>;
        for (final entry in usersMap.entries) {
          await db.ref('${AppConstants.fbNotifications}/${entry.key}').push().set({
            'type': _type,
            'title': _titleCtrl.text.trim(),
            'message': _messageCtrl.text.trim(),
            'isRead': false,
            'createdAt': DateTime.now().toIso8601String(),
          });
          count++;
        }
      }

      // Save to bulk notifications log
      await db.ref(AppConstants.fbBulkNotifications).push().set({
        'title': _titleCtrl.text.trim(),
        'message': _messageCtrl.text.trim(),
        'type': _type,
        'targetCount': count,
        'sentAt': DateTime.now().toIso8601String(),
        'sentBy': fb_auth.FirebaseAuth.instance.currentUser?.uid,
      });

      _titleCtrl.clear();
      _messageCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.translate('sentTo')} $count ${loc.translate('users')}'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.accentRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final bulkAsync = ref.watch(bulkNotificationsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Send Notification Form ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active_rounded, color: AppTheme.primaryColor, size: 22),
                    const SizedBox(width: 8),
                    Text(loc.translate('sendNotification'), style: AppTheme.headingSmall),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.adaptiveCardColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'general', child: Text(loc.translate('general'))),
                    DropdownMenuItem(value: 'important', child: Text(loc.translate('important'))),
                    DropdownMenuItem(value: 'promotion', child: Text(loc.translate('promotion'))),
                    DropdownMenuItem(value: 'update', child: Text(loc.translate('update'))),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? 'general'),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: loc.translate('title'),
                  controller: _titleCtrl,
                  prefixIcon: Icons.title_rounded,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: loc.translate('message'),
                  controller: _messageCtrl,
                  maxLines: 4,
                  prefixIcon: Icons.message_rounded,
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: loc.translate('sendToAll'),
                  icon: Icons.send_rounded,
                  isLoading: _isSending,
                  onPressed: _sendBulkNotification,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Sent History ──
          SectionHeader(title: loc.translate('sentHistory'), icon: Icons.history_rounded),
          const SizedBox(height: 8),
          bulkAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 3),
            error: (_, __) => const SizedBox.shrink(),
            data: (bulks) {
              if (bulks.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.notifications_rounded,
                  title: loc.translate('noNotifications'),
                );
              }
              return Column(
                children: bulks.map((b) => AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.campaign_rounded, color: AppTheme.primaryColor, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(b.title, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600))),
                          InfoChip(label: '${b.targetCount} ${loc.translate('users')}', color: AppTheme.primaryColor),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(b.message, style: AppTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 10 — SETTINGS
// ═══════════════════════════════════════════════════════════════

class _AdminSettingsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends ConsumerState<_AdminSettingsTab> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settingsAsync = ref.watch(appSettingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── App Settings ──
          SectionHeader(title: loc.translate('appSettings'), icon: Icons.settings_rounded),
          const SizedBox(height: 8),
          settingsAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.card, itemCount: 2),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (settings) => Column(
              children: [
                // Maintenance Mode
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.build_rounded, color: AppTheme.warningColor, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(loc.translate('maintenanceMode'), style: AppTheme.titleMedium),
                                Text(loc.translate('maintenanceModeDesc'), style: AppTheme.bodySmall),
                              ],
                            ),
                          ),
                          Switch(
                            value: settings.maintenanceMode,
                            onChanged: (v) => FirebaseDatabase.instance
                                .ref('${AppConstants.fbSettings}/maintenanceMode')
                                .set(v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Force Update
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.system_update_rounded, color: AppTheme.tier300, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(loc.translate('forceUpdate'), style: AppTheme.titleMedium),
                                Text(loc.translate('forceUpdateDesc'), style: AppTheme.bodySmall),
                              ],
                            ),
                          ),
                          Switch(
                            value: settings.forceUpdate,
                            onChanged: (v) => FirebaseDatabase.instance
                                .ref('${AppConstants.fbSettings}/forceUpdate')
                                .set(v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Registration Open
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_add_rounded, color: AppTheme.accentGreen, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(loc.translate('registrationOpen'), style: AppTheme.titleMedium),
                                Text(loc.translate('registrationOpenDesc'), style: AppTheme.bodySmall),
                              ],
                            ),
                          ),
                          Switch(
                            value: settings.registrationOpen,
                            onChanged: (v) => FirebaseDatabase.instance
                                .ref('${AppConstants.fbSettings}/registrationOpen')
                                .set(v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Deposit Enabled
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet_rounded, color: AppTheme.secondaryColor, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(loc.translate('depositEnabled'), style: AppTheme.titleMedium),
                                Text(loc.translate('depositEnabledDesc'), style: AppTheme.bodySmall),
                              ],
                            ),
                          ),
                          Switch(
                            value: settings.depositEnabled,
                            onChanged: (v) => FirebaseDatabase.instance
                                .ref('${AppConstants.fbSettings}/depositEnabled')
                                .set(v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Min Deposit Amount
                AppCard(
                  child: _SettingsField(
                    icon: Icons.payments_rounded,
                    iconColor: AppTheme.primaryColor,
                    title: loc.translate('minDeposit'),
                    description: loc.translate('minDepositDesc'),
                    currentValue: '${(settings.minDeposit ?? 0).toInt()} ر.ي',
                    firebasePath: '${AppConstants.fbSettings}/minDeposit',
                    isNumber: true,
                  ),
                ),

                // Max Balance
                AppCard(
                  child: _SettingsField(
                    icon: Icons.account_balance_rounded,
                    iconColor: AppTheme.tier500,
                    title: loc.translate('maxBalance'),
                    description: loc.translate('maxBalanceDesc'),
                    currentValue: '${(settings.maxBalance ?? 0).toInt()} ر.ي',
                    firebasePath: '${AppConstants.fbSettings}/maxBalance',
                    isNumber: true,
                  ),
                ),

                // App Version
                AppCard(
                  child: _SettingsField(
                    icon: Icons.info_rounded,
                    iconColor: AppTheme.tier300,
                    title: loc.translate('appVersion'),
                    description: loc.translate('appVersionDesc'),
                    currentValue: settings.latestVersion ?? '',
                    firebasePath: '${AppConstants.fbSettings}/latestVersion',
                    isNumber: false,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Banks Management ──
          SectionHeader(title: loc.translate('bankAccounts'), icon: Icons.account_balance_rounded),
          const SizedBox(height: 8),
          _BanksManagement(),

          const SizedBox(height: 20),

          // ── App Info ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_rounded, color: AppTheme.primaryColor, size: 22),
                    const SizedBox(width: 8),
                    Text(loc.translate('appInfo'), style: AppTheme.headingSmall),
                  ],
                ),
                const Divider(height: 24),
                InfoRow(icon: Icons.apps_rounded, label: loc.translate('appName'), value: AppConstants.appName),
                InfoRow(icon: Icons.tag_rounded, label: loc.translate('version'), value: AppConstants.version),
                InfoRow(icon: Icons.code_rounded, label: loc.translate('developer'), value: AppConstants.developerName),
                InfoRow(icon: Icons.email_rounded, label: loc.translate('contact'), value: AppConstants.developerEmail),
                InfoRow(icon: Icons.person_rounded, label: loc.translate('owner'), value: AppConstants.ownerName),
                InfoRow(icon: Icons.phone_rounded, label: loc.translate('ownerPhone'), value: AppConstants.ownerPhone),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Field Widget ──
class _SettingsField extends ConsumerStatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String currentValue;
  final String firebasePath;
  final bool isNumber;

  const _SettingsField({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.currentValue,
    required this.firebasePath,
    required this.isNumber,
  });

  @override
  ConsumerState<_SettingsField> createState() => _SettingsFieldState();
}

class _SettingsFieldState extends ConsumerState<_SettingsField> {
  bool _isEditing = false;
  final _ctrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final value = widget.isNumber
          ? double.tryParse(_ctrl.text) ?? 0
          : _ctrl.text.trim();
      await FirebaseDatabase.instance.ref(widget.firebasePath).set(value);
      setState(() => _isEditing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(widget.icon, color: widget.iconColor, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: AppTheme.titleMedium),
                  Text(widget.description, style: AppTheme.bodySmall),
                ],
              ),
            ),
            if (!_isEditing)
              Text(widget.currentValue, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
            IconButton(
              icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_rounded, size: 18),
              onPressed: () {
                if (_isEditing) {
                  setState(() => _isEditing = false);
                } else {
                  _ctrl.text = widget.currentValue.replaceAll(' ر.ي', '');
                  setState(() => _isEditing = true);
                }
              },
            ),
          ],
        ),
        if (_isEditing) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _ctrl,
                  keyboardType: widget.isNumber ? TextInputType.number : TextInputType.text,
                ),
              ),
              const SizedBox(width: 8),
              AppButton(
                text: AppLocalizations.of(context).translate('save'),
                icon: Icons.save_rounded,
                isLoading: _isSaving,
                onPressed: _save,
                isSmall: true,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Banks Management Widget ──
class _BanksManagement extends ConsumerStatefulWidget {
  @override
  ConsumerState<_BanksManagement> createState() => _BanksManagementState();
}

class _BanksManagementState extends ConsumerState<_BanksManagement> {
  final _bankNameCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  String? _editingId;
  bool _isSaving = false;
  bool _showForm = false;

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _accountNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    super.dispose();
  }

  void _clearForm() {
    _bankNameCtrl.clear();
    _accountNameCtrl.clear();
    _accountNumberCtrl.clear();
    setState(() { _editingId = null; _showForm = false; });
  }

  Future<void> _saveBank() async {
    if (_bankNameCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      if (_editingId != null) {
        await FirebaseDatabase.instance.ref('${AppConstants.fbBanks}/$_editingId').update({
          'bankName': _bankNameCtrl.text.trim(),
          'accountName': _accountNameCtrl.text.trim(),
          'accountNumber': _accountNumberCtrl.text.trim(),
        });
      } else {
        final ref = FirebaseDatabase.instance.ref(AppConstants.fbBanks).push();
        await ref.set({
          'id': ref.key,
          'bankName': _bankNameCtrl.text.trim(),
          'accountName': _accountNameCtrl.text.trim(),
          'accountNumber': _accountNumberCtrl.text.trim(),
          'isActive': true,
        });
      }
      _clearForm();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final banksAsync = ref.watch(banksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppButton(
          text: _showForm ? loc.translate('cancel') : loc.translate('addBank'),
          icon: _showForm ? Icons.close_rounded : Icons.add_rounded,
          onPressed: () {
            if (_showForm) _clearForm();
            else setState(() => _showForm = true);
          },
          isOutlined: _showForm,
          isSmall: true,
        ),
        const SizedBox(height: 12),

        if (_showForm) ...[
          AppCard(
            child: Column(
              children: [
                AppTextField(label: loc.translate('bankName'), controller: _bankNameCtrl, prefixIcon: Icons.account_balance_rounded),
                const SizedBox(height: 12),
                AppTextField(label: loc.translate('accountName'), controller: _accountNameCtrl, prefixIcon: Icons.person_rounded),
                const SizedBox(height: 12),
                AppTextField(label: loc.translate('accountNumber'), controller: _accountNumberCtrl, prefixIcon: Icons.confirmation_number_rounded, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                AppButton(text: loc.translate('save'), icon: Icons.save_rounded, isLoading: _isSaving, onPressed: _saveBank),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        banksAsync.when(
          loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 2),
          error: (e, _) => AppErrorWidget(message: e.toString()),
          data: (banks) {
            if (banks.isEmpty) return EmptyStateWidget(icon: Icons.account_balance_rounded, title: loc.translate('noBanks'));
            return Column(
              children: banks.map((bank) => AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(Icons.account_balance_rounded, color: AppTheme.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bank.bankName, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                          Text('${bank.accountName} - ${bank.accountNumber}', style: AppTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'edit') {
                          _bankNameCtrl.text = bank.bankName;
                          _accountNameCtrl.text = bank.accountName;
                          _accountNumberCtrl.text = bank.accountNumber;
                          setState(() { _editingId = bank.id; _showForm = true; });
                        }
                        if (action == 'toggle') {
                          FirebaseDatabase.instance.ref('${AppConstants.fbBanks}/${bank.id}/isActive').set(!bank.isActive);
                        }
                        if (action == 'delete') {
                          FirebaseDatabase.instance.ref('${AppConstants.fbBanks}/${bank.id}').remove();
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'edit', child: Text(loc.translate('edit'))),
                        PopupMenuItem(value: 'toggle', child: Text(bank.isActive ? loc.translate('deactivate') : loc.translate('activate'))),
                        PopupMenuItem(value: 'delete', child: Text(loc.translate('delete'), style: const TextStyle(color: AppTheme.accentRed))),
                      ],
                    ),
                  ],
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// UTILITY — Parse color from hex string
// ═══════════════════════════════════════════════════════════════

Color _parseColor(String hex, Color fallback) {
  try {
    final hexValue = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexValue', radix: 16));
  } catch (_) {
    return fallback;
  }
}
