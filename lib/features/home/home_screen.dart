// ============================================================
// Apple.NET — Home Screen with 5 Bottom Nav Tabs
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_database/firebase_database.dart';
import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _currentIndex;
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.mediumImpact();
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final tabs = [
      _HomeContent(),
      _CardsContent(),
      _StarlinkContent(),
      _CreditContent(),
      _MoreContent(),
    ];

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: tabs.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (_, i) => tabs[i],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        loc: loc,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Custom Bottom Navigation Bar
// ═══════════════════════════════════════════════════════════════
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppLocalizations loc;
  const _BottomNav({required this.currentIndex, required this.onTap, required this.loc});

  static const _items = [
    _NavItem(Icons.home_rounded, 'home'),
    _NavItem(Icons.wifi_rounded, 'cards'),
    _NavItem(Icons.satellite_alt_rounded, 'starlink'),
    _NavItem(Icons.account_balance_wallet_rounded, 'credit'),
    _NavItem(Icons.more_horiz_rounded, 'more'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surfaceColor,
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -2))],
        border: isDark ? Border(top: BorderSide(color: AppTheme.darkDivider, width: 0.5)) : null,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final selected = i == currentIndex;
              final color = selected ? AppTheme.primaryColor : AppTheme.textHint;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: AppTheme.animNormal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: selected ? 1.15 : 1.0,
                        duration: AppTheme.animNormal,
                        curve: Curves.elasticOut,
                        child: Icon(_items[i].icon, color: color, size: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.translate(_items[i].label),
                        style: AppTheme.bodySmall.copyWith(
                          color: color,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

// ═══════════════════════════════════════════════════════════════
// TAB 1: Home Content
// ═══════════════════════════════════════════════════════════════
class _HomeContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);
    final networksAsync = ref.watch(networksProvider);
    final adsAsync = ref.watch(adsProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return CustomScrollView(
      slivers: [
        // ── SliverAppBar ──
        SliverAppBar(
          floating: true,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          title: Row(
            children: [
              Text(
                '${loc.translate('welcome')}, ${userAsync.value?.displayName ?? ''}',
                style: AppTheme.titleMedium,
              ),
            ],
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push('/notifications'),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppTheme.accentRed, shape: BoxShape.circle),
                      child: Text('$unreadCount', style: AppTheme.bodySmall.copyWith(color: AppTheme.textOnPrimary, fontSize: 10)),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // ── Balance Card ──
        SliverToBoxAdapter(
          child: BalanceCard(
            balance: userAsync.value?.balance ?? 0,
            maxBalance: AppConstants.defaultMaxBalance,
          ),
        ),

        // ── Quick Actions ──
        SliverToBoxAdapter(child: _QuickActions()),
        SliverToBoxAdapter(child: const SizedBox(height: 8)),

        // ── Networks ──
        SliverToBoxAdapter(
          child: SectionHeader(
            title: loc.translate('availableNetworks'),
            icon: Icons.wifi_rounded,
            actionText: loc.translate('view'),
            onActionTap: () {},
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 120,
            child: networksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (networks) => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: networks.isEmpty ? AppConstants.defaultNetworks.length : networks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final n = networks.isNotEmpty
                      ? networks[i]
                      : NetworkModel.fromMap(Map<String, dynamic>.from(AppConstants.defaultNetworks[i]));
                  return _NetworkCard(network: n);
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 16)),

        // ── Stats ──
        SliverToBoxAdapter(child: _StatsRow()),
        SliverToBoxAdapter(child: const SizedBox(height: 16)),

        // ── Ads Carousel ──
        SliverToBoxAdapter(
          child: SectionHeader(
            title: loc.translate('ads'),
            icon: Icons.campaign_rounded,
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 140,
            child: adsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
              data: (ads) {
                final active = ads.where((a) => a.isActive).toList();
                if (active.isEmpty) return const SizedBox.shrink();
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: active.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _AdCard(ad: active[i]),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 100)),
      ],
    );
  }
}

class _QuickActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final actions = [
      _QuickAction(Icons.wifi_rounded, loc.translate('cards'), () => context.push('/home?tab=1')),
      _QuickAction(Icons.add_card_rounded, loc.translate('deposit'), () => context.push('/deposit')),
      _QuickAction(Icons.sim_card_rounded, loc.translate('sims'), () => context.push('/sims')),
      _QuickAction(Icons.account_balance_rounded, loc.translate('bankAccounts'), () => context.push('/banks')),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) => GestureDetector(
          onTap: a.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(a.icon, color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(height: 6),
              Text(a.label, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(this.icon, this.label, this.onTap);
}

class _NetworkCard extends StatelessWidget {
  final NetworkModel network;
  const _NetworkCard({required this.network});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: AppTheme.adaptiveCardDecoration(context, borderRadius: AppTheme.radiusMd),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(network.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(network.name, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (network.provinceName != null)
            Text(network.provinceName!, style: AppTheme.bodySmall.copyWith(fontSize: 10, color: AppTheme.adaptiveTextSecondary(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final networksAsync = ref.watch(networksProvider);
    final cardsAsync = ref.watch(cardsProvider);
    final netCount = networksAsync.value?.length ?? 0;
    final cardCount = cardsAsync.value?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: StatCard(icon: Icons.check_circle_rounded, value: '98%', title: loc.translate('successRate'), color: AppTheme.accentGreen)),
          const SizedBox(width: 12),
          Expanded(child: StatCard(icon: Icons.people_rounded, value: '${cardCount > 100 ? cardCount ~/ 10 : 12}', title: loc.translate('users'), color: AppTheme.primaryColor)),
          const SizedBox(width: 12),
          Expanded(child: StatCard(icon: Icons.wifi_rounded, value: '$netCount', title: loc.translate('networks'), color: AppTheme.secondaryColor)),
        ],
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  final Advertisement ad;
  const _AdCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: AppTheme.adaptiveCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primaryDark, AppTheme.primaryColor]),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLg),
                  topRight: Radius.circular(AppTheme.radiusLg),
                ),
              ),
              child: Center(child: Icon(Icons.campaign_rounded, color: AppTheme.textOnPrimary.withValues(alpha: 0.5), size: 36)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(ad.title, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 2: Cards Content
// ═══════════════════════════════════════════════════════════════
class _CardsContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final networksAsync = ref.watch(networksProvider);
    final tiersAsync = ref.watch(tiersProvider);
    final cardsAsync = ref.watch(cardsProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text(loc.translate('internetCards')),
        ),
        networksAsync.when(
          loading: () => SliverFillRemaining(child: LoadingShimmer(type: ShimmerType.list)),
          error: (e, _) => SliverFillRemaining(child: AppErrorWidget(message: e.toString())),
          data: (networks) {
            if (networks.isEmpty) {
              return SliverFillRemaining(
                child: EmptyStateWidget(icon: Icons.wifi_rounded, title: loc.translate('noCards')),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _NetworkDetailCard(
                  network: networks[i],
                  tiers: tiersAsync.value ?? [],
                  cards: cardsAsync.value ?? [],
                  loc: loc,
                ),
                childCount: networks.length,
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _NetworkDetailCard extends ConsumerWidget {
  final NetworkModel network;
  final List<TierModel> tiers;
  final List<CardModel> cards;
  final AppLocalizations loc;
  const _NetworkDetailCard({required this.network, required this.tiers, required this.cards, required this.loc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkTiers = tiers.where((t) => t.networkId == network.id || t.networkId == null).toList();
    final availableCount = cards.where((c) => c.network == network.id && !c.isUsed).length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Text(network.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(network.name, style: AppTheme.titleMedium),
                    if (network.location != null)
                      Text(network.location!, style: AppTheme.bodySmall.copyWith(color: AppTheme.adaptiveTextSecondary(context))),
                  ],
                ),
              ),
              StatusBadge(text: '$availableCount ${loc.translate('available')}', color: AppTheme.accentGreen, icon: Icons.inventory_2_rounded),
            ],
          ),
          const SizedBox(height: 12),

          // ── Tier Chips ──
          if (networkTiers.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: networkTiers.map((t) => _TierChip(
                tier: t,
                onTap: () => _showBuyDialog(context, ref, t, network),
              )).toList(),
            ),
        ],
      ),
    );
  }

  void _showBuyDialog(BuildContext context, WidgetRef ref, TierModel tier, NetworkModel network) {
    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.value;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: Text(loc.translate('confirmPurchase')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow(icon: Icons.wifi_rounded, label: loc.translate('network'), value: network.name),
            InfoRow(icon: Icons.sell_rounded, label: loc.translate('tier'), value: tier.tier),
            InfoRow(icon: Icons.attach_money_rounded, label: loc.translate('price'), value: '${tier.price.toInt()} ر.ي'),
            InfoRow(icon: Icons.data_usage_rounded, label: loc.translate('data'), value: tier.data),
            InfoRow(icon: Icons.timer_rounded, label: loc.translate('duration'), value: '${tier.duration} ${loc.translate('days')}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.translate('cancel'))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _purchaseCard(context, ref, tier, network, user);
            },
            child: Text(loc.translate('confirm')),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseCard(BuildContext context, WidgetRef ref, TierModel tier, NetworkModel network, AppUser user) async {
    if (user.balance < tier.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('insufficientBalance')), backgroundColor: AppTheme.accentRed),
      );
      return;
    }

    try {
      final uid = user.uid;
      // Deduct balance
      await FirebaseDatabase.instance.ref('${AppConstants.fbUsers}/$uid/balance')
          .set(ServerValue.increment(-tier.price));

      // Find an available card
      final cardsSnapshot = await FirebaseDatabase.instance
          .ref(AppConstants.fbCards)
          .orderByChild('network')
          .equalTo(network.id)
          .limitToFirst(1)
          .get();

      if (!cardsSnapshot.exists) {
        // Refund
        await FirebaseDatabase.instance.ref('${AppConstants.fbUsers}/$uid/balance')
            .set(ServerValue.increment(tier.price));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.translate('noCardsAvailable')), backgroundColor: AppTheme.accentRed),
          );
        }
        return;
      }

      final cardEntry = cardsSnapshot.children.first;
      final cardId = cardEntry.key!;

      // Mark card as used
      await FirebaseDatabase.instance.ref('${AppConstants.fbCards}/$cardId').update({
        'isUsed': true,
        'usedBy': uid,
        'usedAt': DateTime.now().toIso8601String(),
      });

      // Add to orders
      await FirebaseDatabase.instance.ref(AppConstants.fbOrders).push().set({
        'userId': uid,
        'userName': user.displayName,
        'cardId': cardId,
        'networkName': network.name,
        'tier': tier.tier,
        'price': tier.price,
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'completed',
      });

      // Add notification
      await FirebaseDatabase.instance.ref('${AppConstants.fbNotifications}/$uid').push().set({
        'type': 'purchase',
        'title': loc.translate('cardPurchased'),
        'message': '${tier.tier} - ${network.name}',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Add credit history
      await FirebaseDatabase.instance.ref('${AppConstants.fbCredit}/$uid/history').push().set({
        'type': 'purchase',
        'amount': -tier.price,
        'description': '${tier.tier} - ${network.name}',
        'date': DateTime.now().toIso8601String(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('cardPurchased')), backgroundColor: AppTheme.accentGreen),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('cardPurchaseFailed')), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }
}

class _TierChip extends StatelessWidget {
  final TierModel tier;
  final VoidCallback onTap;
  const _TierChip({required this.tier, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getTierColor(tier.tier);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tier.icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text('${tier.price.toInt()} ر.ي', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w700, color: color)),
              ],
            ),
            Text(tier.data, style: AppTheme.bodySmall.copyWith(fontSize: 10, color: AppTheme.adaptiveTextSecondary(context))),
            Text('${tier.duration} ${AppLocalizations.of(context).translate('days')}', style: AppTheme.bodySmall.copyWith(fontSize: 10, color: AppTheme.adaptiveTextSecondary(context))),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 3: Starlink Content
// ═══════════════════════════════════════════════════════════════
class _StarlinkContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final productsAsync = ref.watch(starlinkProductsProvider);

    return CustomScrollView(
      slivers: [
        // ── Hero Section ──
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F1419), Color(0xFF1A1F2E), Color(0xFF242B33)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.satellite_alt_rounded, size: 40, color: AppTheme.primaryLight),
                ),
                const SizedBox(height: 16),
                Text(loc.translate('starlinkProducts'), style: AppTheme.headingMedium.copyWith(color: AppTheme.textOnPrimary)),
                const SizedBox(height: 4),
                Text(loc.translate('highSpeed'), style: AppTheme.bodySmall.copyWith(color: AppTheme.textOnPrimary.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ),

        // ── Products List ──
        productsAsync.when(
          loading: () => SliverFillRemaining(child: LoadingShimmer(type: ShimmerType.list)),
          error: (e, _) => SliverFillRemaining(child: AppErrorWidget(message: e.toString())),
          data: (products) {
            final active = products.where((p) => p.isActive).toList();
            if (active.isEmpty) {
              return SliverFillRemaining(
                child: EmptyStateWidget(icon: Icons.satellite_alt_rounded, title: loc.translate('noStarlinkProducts')),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _StarlinkProductCard(product: active[i], loc: loc),
                childCount: active.length,
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _StarlinkProductCard extends ConsumerWidget {
  final StarlinkProduct product;
  final AppLocalizations loc;
  const _StarlinkProductCard({required this.product, required this.loc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GradientCard(
      headerIcon: Icons.satellite_alt_rounded,
      title: product.name,
      subtitle: product.description,
      gradientColors: const [Color(0xFF1A1F2E), Color(0xFF242B33)],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(icon: Icons.attach_money, label: loc.translate('priceUSD'), value: '\$${product.priceUSD.toInt()}', iconColor: AppTheme.secondaryColor),
          InfoRow(icon: Icons.inventory_2_rounded, label: loc.translate('quantity'), value: '${product.quantity}'),
          if (product.specs.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...product.specs.entries.map((e) => InfoRow(icon: Icons.info_outline, label: e.key, value: e.value, iconColor: AppTheme.primaryColor)),
          ],
          const SizedBox(height: 12),
          AppButton(
            text: loc.translate('orderNow'),
            icon: Icons.shopping_cart_rounded,
            onPressed: () => _orderStarlink(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _orderStarlink(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    try {
      await FirebaseDatabase.instance.ref(AppConstants.fbStarlinkOrders).push().set({
        'userId': user.uid,
        'userName': user.displayName,
        'userEmail': user.email,
        'userPhone': user.phone,
        'productId': product.id,
        'productName': product.name,
        'priceUSD': product.priceUSD,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      await FirebaseDatabase.instance.ref('${AppConstants.fbNotifications}/${user.uid}').push().set({
        'type': 'starlink',
        'title': loc.translate('starlinkOrder'),
        'message': '${product.name} - ${loc.translate('pending')}',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('orderPlaced')), backgroundColor: AppTheme.accentGreen),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 4: Credit Content
// ═══════════════════════════════════════════════════════════════
class _CreditContent extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CreditContent> createState() => _CreditContentState();
}

class _CreditContentState extends ConsumerState<_CreditContent> {
  StreamSubscription? _creditSub;
  List<CreditHistory> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCreditHistory();
  }

  @override
  void dispose() {
    _creditSub?.cancel();
    super.dispose();
  }

  void _loadCreditHistory() {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final ref = FirebaseDatabase.instance.ref('${AppConstants.fbCredit}/$uid/history');
    _creditSub = ref.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) {
        if (mounted) setState(() { _history = []; _loading = false; });
        return;
      }
      final map = data as Map<dynamic, dynamic>;
      final list = map.entries.map((e) => CreditHistory.fromMap(Map<String, dynamic>.from(e.value as Map))).toList();
      list.sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return b.date!.compareTo(a.date!);
      });
      if (mounted) setState(() { _history = list; _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(floating: true, title: Text(loc.translate('myBalance'))),
        SliverToBoxAdapter(
          child: BalanceCard(
            balance: userAsync.value?.balance ?? 0,
            maxBalance: AppConstants.defaultMaxBalance,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: loc.translate('depositBalance'),
                    icon: Icons.add_rounded,
                    onPressed: () => context.push('/deposit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: loc.translate('redeemCode'),
                    icon: Icons.card_giftcard_rounded,
                    isOutlined: true,
                    onPressed: () => _showRedeemDialog(),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SectionHeader(title: loc.translate('transactionHistory'), icon: Icons.history_rounded),
        ),
        if (_loading)
          SliverFillRemaining(child: LoadingShimmer(type: ShimmerType.list))
        else if (_history.isEmpty)
          SliverFillRemaining(child: EmptyStateWidget(icon: Icons.history_rounded, title: loc.translate('noCreditHistory')))
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _CreditHistoryItem(item: _history[i], loc: loc),
              childCount: _history.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  void _showRedeemDialog() {
    final loc = AppLocalizations.of(context);
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: Text(loc.translate('redeemCode')),
        content: AppTextField(
          controller: codeController,
          label: loc.translate('enterCode'),
          prefixIcon: Icons.vpn_key_rounded,
          keyboardType: TextInputType.visiblePassword,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.translate('cancel'))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _redeemCode(codeController.text.trim());
            },
            child: Text(loc.translate('redeem')),
          ),
        ],
      ),
    );
  }

  Future<void> _redeemCode(String code) async {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || code.isEmpty) return;
    final loc = AppLocalizations.of(context);

    try {
      // Check redeem codes
      final snapshot = await FirebaseDatabase.instance.ref(AppConstants.fbRedeemCodes).orderByChild('code').equalTo(code).get();
      if (!snapshot.exists) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('codeNotFound')), backgroundColor: AppTheme.accentRed));
        return;
      }

      final entry = snapshot.children.first;
      final data = Map<String, dynamic>.from(entry.value as Map);
      if (data['isUsed'] == true) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('codeAlreadyUsed')), backgroundColor: AppTheme.accentRed));
        return;
      }

      final amount = (data['amount'] as num?)?.toDouble() ?? 0;

      // Mark code as used
      await FirebaseDatabase.instance.ref('${AppConstants.fbRedeemCodes}/${entry.key}').update({
        'isUsed': true,
        'usedBy': uid,
        'usedAt': DateTime.now().toIso8601String(),
      });

      // Add balance
      await FirebaseDatabase.instance.ref('${AppConstants.fbUsers}/$uid/balance').set(ServerValue.increment(amount));

      // Credit history
      await FirebaseDatabase.instance.ref('${AppConstants.fbCredit}/$uid/history').push().set({
        'type': 'redeem',
        'amount': amount,
        'description': loc.translate('redeemCode'),
        'date': DateTime.now().toIso8601String(),
      });

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('redeemSuccess')), backgroundColor: AppTheme.accentGreen));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('redeemFailed')), backgroundColor: AppTheme.accentRed));
    }
  }
}

class _CreditHistoryItem extends StatelessWidget {
  final CreditHistory item;
  final AppLocalizations loc;
  const _CreditHistoryItem({required this.item, required this.loc});

  IconData _typeIcon(String type) {
    switch (type) {
      case 'deposit': return Icons.add_circle_rounded;
      case 'purchase': return Icons.shopping_cart_rounded;
      case 'gift': return Icons.card_giftcard_rounded;
      case 'redeem': return Icons.vpn_key_rounded;
      case 'commission': return Icons.percent_rounded;
      case 'refund': return Icons.undo_rounded;
      default: return Icons.swap_horiz_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'deposit': case 'gift': case 'redeem': case 'commission': case 'refund': return AppTheme.accentGreen;
      case 'purchase': return AppTheme.accentRed;
      default: return AppTheme.primaryColor;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'deposit': return loc.translate('creditDeposit');
      case 'purchase': return loc.translate('creditPurchase');
      case 'gift': return loc.translate('creditGift');
      case 'redeem': return loc.translate('creditRedeem');
      case 'commission': return loc.translate('creditCommission');
      case 'refund': return loc.translate('creditRefund');
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(item.type);
    final isPositive = item.amount > 0;
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(_typeIcon(item.type), color: color, size: 20),
      ),
      title: Text(_typeLabel(item.type), style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(item.description, style: AppTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(
        '${isPositive ? '+' : ''}${item.amount.toInt()} ر.ي',
        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: isPositive ? AppTheme.accentGreen : AppTheme.accentRed),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 5: More Content
// ═══════════════════════════════════════════════════════════════
class _MoreContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final isManager = ref.watch(isManagerProvider);
    final user = userAsync.value;

    return CustomScrollView(
      slivers: [
        SliverAppBar(floating: true, title: Text(loc.translate('more'))),

        // ── User Profile Card ──
        SliverToBoxAdapter(
          child: AppCard(
            onTap: () => context.push('/profile'),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    (user?.displayName.isNotEmpty == true) ? user!.displayName[0].toUpperCase() : '?',
                    style: AppTheme.headingMedium.copyWith(color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? '', style: AppTheme.titleMedium),
                      Text(user?.email ?? '', style: AppTheme.bodySmall.copyWith(color: AppTheme.adaptiveTextSecondary(context))),
                    ],
                  ),
                ),
                StatusBadge(
                  text: user?.role == 'admin' ? loc.translate('admin') : (user?.role == 'network_manager' ? loc.translate('manager') : loc.translate('roleUser')),
                  color: user?.role == 'admin' ? AppTheme.accentRed : (user?.role == 'network_manager' ? AppTheme.secondaryColor : AppTheme.primaryColor),
                ),
              ],
            ),
          ),
        ),

        // ── Menu Items ──
        SliverToBoxAdapter(child: _MenuSection(items: [
          if (isAdmin) _MenuItem(Icons.admin_panel_settings_rounded, loc.translate('admin'), () => context.push('/admin'), color: AppTheme.accentRed),
          if (isManager) _MenuItem(Icons.manage_accounts_rounded, loc.translate('manager'), () => context.push('/manager'), color: AppTheme.secondaryColor),
          _MenuItem(Icons.person_rounded, loc.translate('profile'), () => context.push('/profile')),
          _MenuItem(Icons.shopping_bag_rounded, loc.translate('purchasedCards'), () => context.push('/purchased')),
          _MenuItem(Icons.account_balance_rounded, loc.translate('bankAccounts'), () => context.push('/banks')),
          _MenuItem(Icons.campaign_rounded, loc.translate('advertisements'), () => context.push('/ads')),
          _MenuItem(Icons.wifi_tethering_rounded, loc.translate('submitNetwork'), () => context.push('/submit-network')),
          _MenuItem(Icons.privacy_tip_rounded, loc.translate('privacyPolicy'), () {}),
          _MenuItem(Icons.description_rounded, loc.translate('termsOfUse'), () {}),
          _MenuItem(Icons.support_agent_rounded, loc.translate('contactSupport'), () {}),
          _MenuItem(Icons.info_outline_rounded, loc.translate('aboutApp'), () => context.push('/about')),
        ])),

        // ── Settings ──
        SliverToBoxAdapter(
          child: AppCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(loc.translate('darkMode'), style: AppTheme.bodyMedium),
                  secondary: const Icon(Icons.dark_mode_rounded, color: AppTheme.primaryColor),
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: Text(loc.translate('language'), style: AppTheme.bodyMedium),
                  leading: const Icon(Icons.language_rounded, color: AppTheme.primaryColor),
                  trailing: Text(
                    ref.watch(localeProvider).languageCode == 'ar' ? loc.translate('arabic') : loc.translate('english'),
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                  ),
                  onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),

        // ── Logout ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              text: loc.translate('logout'),
              icon: Icons.logout_rounded,
              isOutlined: true,
              backgroundColor: AppTheme.accentRed,
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(loc.translate('confirmLogout')),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.translate('cancel'))),
                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(loc.translate('logout'))),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await fb_auth.FirebaseAuth.instance.signOut();
                  if (context.mounted) context.go('/login');
                }
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: items.map((item) => ListTile(
          leading: Icon(item.icon, color: item.color ?? AppTheme.primaryColor, size: 22),
          title: Text(item.label, style: AppTheme.bodyMedium),
          trailing: Icon(Icons.chevron_left_rounded, color: AppTheme.adaptiveTextHint(context), size: 20),
          onTap: item.onTap,
        )).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem(this.icon, this.label, this.onTap, {this.color});
}
