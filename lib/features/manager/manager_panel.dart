// ============================================================
// Apple.NET — Manager Panel (Complete — 6 Tabs)
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════════
// MANAGER PANEL — ConsumerStatefulWidget
// ═══════════════════════════════════════════════════════════════

class ManagerPanel extends ConsumerStatefulWidget {
  const ManagerPanel({super.key});

  @override
  ConsumerState<ManagerPanel> createState() => _ManagerPanelState();
}

class _ManagerPanelState extends ConsumerState<ManagerPanel>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<_ManagerTab> _tabs = const [
    _ManagerTab(icon: Icons.dashboard_rounded, labelKey: 'overview'),
    _ManagerTab(icon: Icons.style_rounded, labelKey: 'cards'),
    _ManagerTab(icon: Icons.layers_rounded, labelKey: 'tiers'),
    _ManagerTab(icon: Icons.settings_rounded, labelKey: 'settings'),
    _ManagerTab(icon: Icons.monetization_on_rounded, labelKey: 'commissions'),
    _ManagerTab(icon: Icons.place_rounded, labelKey: 'saleLocations'),
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
    final loc = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(loc.translate('manager'))),
        body: const LoadingShimmer(type: ShimmerType.card, itemCount: 4),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(loc.translate('manager'))),
        body: AppErrorWidget(message: e.toString()),
      ),
      data: (user) {
        if (user == null || user.managedNetwork == null) {
          return Scaffold(
            appBar: AppBar(title: Text(loc.translate('manager'))),
            body: EmptyStateWidget(
              icon: Icons.warning_amber_rounded,
              title: loc.translate('noData'),
              subtitle: 'No network assigned',
            ),
          );
        }

        final isWide = MediaQuery.of(context).size.width >= 900;

        return Scaffold(
          appBar: AppBar(
            title: Text(loc.translate('manager')),
            leading: isWide
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  ),
          ),
          body: isWide
              ? _buildWideLayout(user.managedNetwork!)
              : _buildNarrowLayout(user.managedNetwork!),
          bottomNavigationBar: isWide ? null : _buildBottomNav(loc),
        );
      },
    );
  }

  // ─── Bottom Navigation (Mobile) ───
  Widget _buildBottomNav(AppLocalizations loc) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: _onTabChanged,
      destinations: _tabs.map((tab) {
        return NavigationDestination(
          icon: Icon(tab.icon),
          label: loc.translate(tab.labelKey),
        );
      }).toList(),
    );
  }

  // ─── Wide Layout (Tablet/Desktop) ───
  Widget _buildWideLayout(String networkId) {
    final loc = AppLocalizations.of(context);
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabChanged,
          labelType: NavigationRailLabelType.all,
          destinations: _tabs.map((tab) {
            return NavigationRailDestination(
              icon: Icon(tab.icon),
              label: Text(loc.translate(tab.labelKey)),
            );
          }).toList(),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildTabContent(networkId),
          ),
        ),
      ],
    );
  }

  // ─── Narrow Layout (Mobile) ───
  Widget _buildNarrowLayout(String networkId) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildTabContent(networkId),
    );
  }

  // ─── Tab Content Router ───
  Widget _buildTabContent(String networkId) {
    switch (_currentIndex) {
      case 0:
        return _OverviewTab(networkId: networkId);
      case 1:
        return _CardsTab(networkId: networkId);
      case 2:
        return _TiersTab(networkId: networkId);
      case 3:
        return _SettingsTab(networkId: networkId);
      case 4:
        return _CommissionsTab(networkId: networkId);
      case 5:
        return _SaleLocationsTab(networkId: networkId);
      default:
        return _OverviewTab(networkId: networkId);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB DATA CLASS
// ═══════════════════════════════════════════════════════════════

class _ManagerTab {
  final IconData icon;
  final String labelKey;
  const _ManagerTab({required this.icon, required this.labelKey});
}

// ═══════════════════════════════════════════════════════════════
// TAB 1 — OVERVIEW
// ═══════════════════════════════════════════════════════════════

class _OverviewTab extends ConsumerWidget {
  final String networkId;
  const _OverviewTab({required this.networkId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final networksAsync = ref.watch(networksProvider);
    final cardsAsync = ref.watch(cardsProvider);
    final commissionsAsync = ref.watch(commissionEntriesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Network Info Card ──
          networksAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.card, itemCount: 1),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (networks) {
              final network = networks.where((n) => n.id == networkId).firstOrNull;
              if (network == null) {
                return EmptyStateWidget(
                  icon: Icons.wifi_off_rounded,
                  title: loc.translate('noNetworks'),
                );
              }
              return _buildNetworkInfoCard(context, network, loc);
            },
          ),
          const SizedBox(height: 16),

          // ── Quick Stats ──
          cardsAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 4),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (allCards) {
              final myCards = allCards.where((c) => c.network == networkId).toList();
              final available = myCards.where((c) => !c.isUsed).length;
              final sold = myCards.where((c) => c.isUsed).length;
              final now = DateTime.now();
              final thisMonth = myCards.where((c) {
                if (!c.isUsed || c.usedAt == null) return false;
                return c.usedAt!.year == now.year && c.usedAt!.month == now.month;
              }).toList();
              final revenue = thisMonth.fold<double>(0, (sum, c) => sum + c.price);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: loc.translate('stats'),
                    icon: Icons.bar_chart_rounded,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      StatCard(
                        icon: Icons.style_rounded,
                        value: '${myCards.length}',
                        title: loc.translate('totalCards'),
                        color: AppTheme.primaryColor,
                      ),
                      StatCard(
                        icon: Icons.check_circle_rounded,
                        value: '$available',
                        title: loc.translate('available'),
                        color: AppTheme.accentGreen,
                      ),
                      StatCard(
                        icon: Icons.sell_rounded,
                        value: '$sold',
                        title: loc.translate('sold'),
                        color: AppTheme.secondaryColor,
                      ),
                      StatCard(
                        icon: Icons.payments_rounded,
                        value: '${revenue.toInt()} ر.ي',
                        title: loc.translate('totalRevenue'),
                        subtitle: 'هذا الشهر',
                        color: AppTheme.tier500,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // ── Commission Summary ──
          commissionsAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 2),
            error: (e, _) => const SizedBox.shrink(),
            data: (entries) {
              final myEntries = entries.where((e) => e.networkId == networkId).toList();
              final unpaid = myEntries.where((e) => !e.isPaid).toList();
              final totalUnpaid = unpaid.fold<double>(0, (s, e) => s + e.commissionAmount);
              final now = DateTime.now();
              final thisMonthEntries = myEntries.where((e) {
                if (e.soldAt == null) return false;
                return e.soldAt!.year == now.year && e.soldAt!.month == now.month;
              }).toList();
              final monthTotal = thisMonthEntries.fold<double>(0, (s, e) => s + e.commissionAmount);

              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.monetization_on_rounded, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(loc.translate('commissions'), style: AppTheme.headingSmall),
                      ],
                    ),
                    const Divider(height: 24),
                    InfoRow(
                      icon: Icons.account_balance_wallet_rounded,
                      label: loc.translate('payoutPending'),
                      value: '${totalUnpaid.toInt()} ر.ي',
                      iconColor: AppTheme.secondaryColor,
                    ),
                    InfoRow(
                      icon: Icons.calendar_month_rounded,
                      label: 'هذا الشهر',
                      value: '${monthTotal.toInt()} ر.ي',
                      iconColor: AppTheme.accentGreen,
                    ),
                    InfoRow(
                      icon: Icons.receipt_long_rounded,
                      label: loc.translate('commissionEntries'),
                      value: '${myEntries.length}',
                      iconColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // ── Active Users / Pending Orders (placeholder from orders) ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.people_rounded, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(loc.translate('quickActions'), style: AppTheme.headingSmall),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InfoChip(
                      label: loc.translate('myCards'),
                      icon: Icons.style_rounded,
                      color: AppTheme.primaryColor,
                    ),
                    InfoChip(
                      label: loc.translate('myTiers'),
                      icon: Icons.layers_rounded,
                      color: AppTheme.secondaryColor,
                    ),
                    InfoChip(
                      label: loc.translate('myCommissions'),
                      icon: Icons.monetization_on_rounded,
                      color: AppTheme.accentGreen,
                    ),
                    InfoChip(
                      label: loc.translate('mySaleLocations'),
                      icon: Icons.place_rounded,
                      color: AppTheme.tier300,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkInfoCard(BuildContext context, NetworkModel network, AppLocalizations loc) {
    return GradientCard(
      headerIcon: Icons.wifi_rounded,
      title: network.name,
      subtitle: network.networkType ?? loc.translate('network'),
      gradientColors: [
        _parseColor(network.color, AppTheme.primaryDark),
        _parseColor(network.color, AppTheme.primaryColor),
      ],
      body: Column(
        children: [
          if (network.provinceName != null)
            InfoRow(
              icon: Icons.location_on_rounded,
              label: loc.translate('province'),
              value: network.provinceName!,
            ),
          if (network.district != null)
            InfoRow(
              icon: Icons.map_rounded,
              label: loc.translate('district'),
              value: network.district!,
            ),
          if (network.exactLocation != null)
            InfoRow(
              icon: Icons.pin_drop_rounded,
              label: loc.translate('exactLocation'),
              value: network.exactLocation!,
            ),
          if (network.networkType != null)
            InfoRow(
              icon: Icons.router_rounded,
              label: loc.translate('networkType'),
              value: network.networkType!,
            ),
          if (network.connectionIP != null)
            InfoRow(
              icon: Icons.dns_rounded,
              label: loc.translate('connectionIP'),
              value: network.connectionIP!,
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 2 — CARDS
// ═══════════════════════════════════════════════════════════════

class _CardsTab extends ConsumerStatefulWidget {
  final String networkId;
  const _CardsTab({required this.networkId});

  @override
  ConsumerState<_CardsTab> createState() => _CardsTabState();
}

class _CardsTabState extends ConsumerState<_CardsTab> {
  String _filterTier = 'all';
  String _filterStatus = 'all'; // all / available / sold
  bool _showAddForm = false;
  bool _showBulkForm = false;

  final _codeCtrl = TextEditingController();
  final _tierCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _dataCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _bulkCodesCtrl = TextEditingController();
  final _bulkTierCtrl = TextEditingController();

  bool _isAdding = false;
  int _bulkProgress = 0;
  int _bulkTotal = 0;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _tierCtrl.dispose();
    _priceCtrl.dispose();
    _dataCtrl.dispose();
    _durationCtrl.dispose();
    _bulkCodesCtrl.dispose();
    _bulkTierCtrl.dispose();
    super.dispose();
  }

  List<CardModel> _filterCards(List<CardModel> cards) {
    var filtered = cards.where((c) => c.network == widget.networkId).toList();
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

  Future<void> _addSingleCard() async {
    if (_codeCtrl.text.trim().isEmpty || _tierCtrl.text.trim().isEmpty) return;
    setState(() => _isAdding = true);

    try {
      final networks = ref.read(networksProvider).value ?? [];
      final network = networks.firstWhere((n) => n.id == widget.networkId);
      final db = FirebaseDatabase.instance;
      final ref_ = db.ref(AppConstants.fbCards).push();
      final card = CardModel(
        id: ref_.key!,
        code: _codeCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text) ?? 0,
        data: _dataCtrl.text.trim(),
        duration: int.tryParse(_durationCtrl.text) ?? 0,
        isUsed: false,
        tier: _tierCtrl.text.trim(),
        network: widget.networkId,
        networkName: network.name,
        createdAt: DateTime.now(),
      );
      await ref_.set(card.toMap());
      _codeCtrl.clear();
      _tierCtrl.clear();
      _priceCtrl.clear();
      _dataCtrl.clear();
      _durationCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('added'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _addBulkCards() async {
    final lines = _bulkCodesCtrl.text.trim().split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty || _bulkTierCtrl.text.trim().isEmpty) return;

    setState(() {
      _bulkTotal = lines.length;
      _bulkProgress = 0;
    });

    final networks = ref.read(networksProvider).value ?? [];
    final network = networks.firstWhere((n) => n.id == widget.networkId);
    final db = FirebaseDatabase.instance;
    final loc = AppLocalizations.of(context);

    // Get tier info for price/data/duration defaults
    final allTiers = ref.read(tiersProvider).value ?? [];
    final networkTiers = allTiers.where((t) => t.networkId == widget.networkId || t.networkId == null).toList();
    final tierInfo = networkTiers.where((t) => t.tier == _bulkTierCtrl.text.trim()).firstOrNull;

    for (int i = 0; i < lines.length; i++) {
      try {
        final ref_ = db.ref(AppConstants.fbCards).push();
        final card = CardModel(
          id: ref_.key!,
          code: lines[i].trim(),
          price: tierInfo?.price ?? 0,
          data: tierInfo?.data ?? '',
          duration: tierInfo?.duration ?? 0,
          isUsed: false,
          tier: _bulkTierCtrl.text.trim(),
          network: widget.networkId,
          networkName: network.name,
          createdAt: DateTime.now(),
        );
        await ref_.set(card.toMap());
      } catch (_) {}
      if (mounted) {
        setState(() => _bulkProgress = i + 1);
      }
    }

    _bulkCodesCtrl.clear();
    _bulkTierCtrl.clear();
    if (mounted) {
      setState(() {
        _bulkTotal = 0;
        _bulkProgress = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.translate('added')} ${lines.length} cards')),
      );
    }
  }

  Future<void> _deleteCard(CardModel card) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('confirmDelete')),
        content: Text('${card.code}'),
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
    await FirebaseDatabase.instance.ref('${AppConstants.fbCards}/${card.id}').remove();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cardsAsync = ref.watch(cardsProvider);
    final tiersAsync = ref.watch(tiersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Add Buttons ──
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: loc.translate('singleAdd'),
                  icon: Icons.add_rounded,
                  onPressed: () => setState(() {
                    _showAddForm = !_showAddForm;
                    _showBulkForm = false;
                  }),
                  isSmall: true,
                  isOutlined: !_showAddForm,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: loc.translate('bulkAdd'),
                  icon: Icons.playlist_add_rounded,
                  onPressed: () => setState(() {
                    _showBulkForm = !_showBulkForm;
                    _showAddForm = false;
                  }),
                  isSmall: true,
                  isOutlined: !_showBulkForm,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Single Add Form ──
          if (_showAddForm) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.translate('singleAdd'), style: AppTheme.headingSmall),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: loc.translate('cardCode'),
                    controller: _codeCtrl,
                    hint: 'CARD-CODE-HERE',
                    prefixIcon: Icons.qr_code_rounded,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: loc.translate('tier'),
                    controller: _tierCtrl,
                    hint: '200 / 300 / 500 / 1000 / 2000',
                    prefixIcon: Icons.layers_rounded,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: loc.translate('price'),
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.payments_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: loc.translate('duration'),
                          controller: _durationCtrl,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.schedule_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: loc.translate('data'),
                    controller: _dataCtrl,
                    hint: '1 GB / 2 GB',
                    prefixIcon: Icons.data_usage_rounded,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: loc.translate('add'),
                    icon: Icons.add_rounded,
                    isLoading: _isAdding,
                    onPressed: _addSingleCard,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Bulk Add Form ──
          if (_showBulkForm) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.translate('bulkAdd'), style: AppTheme.headingSmall),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: loc.translate('pasteCodes'),
                    controller: _bulkCodesCtrl,
                    hint: 'Paste one code per line',
                    prefixIcon: Icons.paste_rounded,
                    maxLines: 8,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: loc.translate('tier'),
                    controller: _bulkTierCtrl,
                    hint: '200 / 300 / 500 / 1000 / 2000',
                    prefixIcon: Icons.layers_rounded,
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
            const SizedBox(height: 16),
          ],

          // ── Filter Chips ──
          tiersAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (allTiers) {
              final networkTiers = allTiers
                  .where((t) => t.networkId == widget.networkId || t.networkId == null)
                  .toList();
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoChip(
                    label: loc.translate('all'),
                    isSelected: _filterTier == 'all',
                    onTap: () => setState(() => _filterTier = 'all'),
                    color: AppTheme.primaryColor,
                  ),
                  ...networkTiers.map((tier) => InfoChip(
                        label: '${tier.icon} ${tier.tier}',
                        isSelected: _filterTier == tier.tier,
                        onTap: () => setState(() => _filterTier = tier.tier),
                        color: AppTheme.getTierColor(tier.tier),
                      )),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(
                label: loc.translate('all'),
                isSelected: _filterStatus == 'all',
                onTap: () => setState(() => _filterStatus = 'all'),
                color: AppTheme.primaryColor,
              ),
              InfoChip(
                label: loc.translate('available'),
                icon: Icons.check_circle_rounded,
                isSelected: _filterStatus == 'available',
                onTap: () => setState(() => _filterStatus = 'available'),
                color: AppTheme.accentGreen,
              ),
              InfoChip(
                label: loc.translate('sold'),
                icon: Icons.sell_rounded,
                isSelected: _filterStatus == 'sold',
                onTap: () => setState(() => _filterStatus = 'sold'),
                color: AppTheme.secondaryColor,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Card List ──
          cardsAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 6),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (allCards) {
              final cards = _filterCards(allCards);
              if (cards.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.style_rounded,
                  title: loc.translate('noCards'),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return AppCard(
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
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    '${card.tier} | ${card.price.toInt()} ر.ي',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.adaptiveTextSecondary(context),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusBadge(
                                    text: card.isUsed
                                        ? loc.translate('used')
                                        : loc.translate('available'),
                                    color: card.isUsed ? AppTheme.accentRed : AppTheme.accentGreen,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.accentRed, size: 20),
                          onPressed: () => _deleteCard(card),
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 3 — TIERS
// ═══════════════════════════════════════════════════════════════

class _TiersTab extends ConsumerStatefulWidget {
  final String networkId;
  const _TiersTab({required this.networkId});

  @override
  ConsumerState<_TiersTab> createState() => _TiersTabState();
}

class _TiersTabState extends ConsumerState<_TiersTab> {
  final _tierNameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _dataCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _iconCtrl = TextEditingController();
  String? _editingId;
  bool _isSaving = false;

  @override
  void dispose() {
    _tierNameCtrl.dispose();
    _priceCtrl.dispose();
    _dataCtrl.dispose();
    _durationCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  void _clearForm() {
    _tierNameCtrl.clear();
    _priceCtrl.clear();
    _dataCtrl.clear();
    _durationCtrl.clear();
    _iconCtrl.clear();
    setState(() => _editingId = null);
  }

  void _populateForm(TierModel tier) {
    _tierNameCtrl.text = tier.tier;
    _priceCtrl.text = tier.price.toString();
    _dataCtrl.text = tier.data;
    _durationCtrl.text = tier.duration.toString();
    _iconCtrl.text = tier.icon;
    setState(() => _editingId = tier.id);
  }

  Future<void> _saveTier() async {
    if (_tierNameCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final db = FirebaseDatabase.instance;
      final path = '${AppConstants.fbNetworkTiers}/${widget.networkId}';

      if (_editingId != null) {
        await db.ref('$path/${_editingId!}').update({
          'tier': _tierNameCtrl.text.trim(),
          'price': double.tryParse(_priceCtrl.text) ?? 0,
          'data': _dataCtrl.text.trim(),
          'duration': int.tryParse(_durationCtrl.text) ?? 0,
          'icon': _iconCtrl.text.trim().isNotEmpty ? _iconCtrl.text.trim() : '📶',
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } else {
        final ref_ = db.ref(path).push();
        await ref_.set({
          'id': ref_.key,
          'tier': _tierNameCtrl.text.trim(),
          'price': double.tryParse(_priceCtrl.text) ?? 0,
          'data': _dataCtrl.text.trim(),
          'duration': int.tryParse(_durationCtrl.text) ?? 0,
          'icon': _iconCtrl.text.trim().isNotEmpty ? _iconCtrl.text.trim() : '📶',
          'networkId': widget.networkId,
          'createdAt': DateTime.now().toIso8601String(),
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

  Future<void> _deleteTier(TierModel tier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('confirmDelete')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
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
        .ref('${AppConstants.fbNetworkTiers}/${widget.networkId}/${tier.id}')
        .remove();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Add/Edit Form ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editingId != null ? loc.translate('editTier') : loc.translate('addTier'),
                  style: AppTheme.headingSmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: AppTextField(
                        label: loc.translate('tierIcon'),
                        controller: _iconCtrl,
                        hint: '📶',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: loc.translate('tierName'),
                        controller: _tierNameCtrl,
                        hint: '200 / 300 / 500',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: loc.translate('price'),
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: loc.translate('duration'),
                        controller: _durationCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: loc.translate('data'),
                  controller: _dataCtrl,
                  hint: '1 GB / 2 GB',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: _editingId != null ? loc.translate('update') : loc.translate('add'),
                        icon: _editingId != null ? Icons.edit_rounded : Icons.add_rounded,
                        isLoading: _isSaving,
                        onPressed: _saveTier,
                      ),
                    ),
                    if (_editingId != null) ...[
                      const SizedBox(width: 8),
                      AppButton(
                        text: loc.translate('cancel'),
                        isOutlined: true,
                        onPressed: _clearForm,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Tier List ──
          SectionHeader(title: loc.translate('myTiers'), icon: Icons.layers_rounded),
          const SizedBox(height: 8),
          StreamBuilder<List<TierModel>>(
            stream: _networkTiersStream(widget.networkId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingShimmer(type: ShimmerType.list, itemCount: 3);
              }
              final tiers = snapshot.data ?? [];
              if (tiers.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.layers_rounded,
                  title: loc.translate('noTiers'),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tiers.length,
                itemBuilder: (context, index) {
                  final tier = tiers[index];
                  final color = AppTheme.getTierColor(tier.tier);
                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Text(tier.icon, style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tier.tier, style: AppTheme.titleMedium),
                              const SizedBox(height: 2),
                              Text(
                                '${tier.price.toInt()} ر.ي | ${tier.data} | ${tier.duration} ${loc.translate('days')}',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.adaptiveTextSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 20),
                          onPressed: () => _populateForm(tier),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.accentRed, size: 20),
                          onPressed: () => _deleteTier(tier),
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
    );
  }

  Stream<List<TierModel>> _networkTiersStream(String networkId) {
    final controller = StreamController<List<TierModel>>();
    final ref_ = FirebaseDatabase.instance.ref('${AppConstants.fbNetworkTiers}/$networkId');
    final sub = ref_.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) {
        controller.add([]);
        return;
      }
      final map = data as Map<dynamic, dynamic>;
      final list = map.entries
          .map((e) => TierModel.fromMap(Map<String, dynamic>.from(e.value as Map)))
          .toList();
      controller.add(list);
    });
    // ignore: discarded_futures
    controller.onCancel = () {
      sub.cancel();
      controller.close();
    };
    return controller.stream;
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 4 — SETTINGS
// ═══════════════════════════════════════════════════════════════

class _SettingsTab extends ConsumerStatefulWidget {
  final String networkId;
  const _SettingsTab({required this.networkId});

  @override
  ConsumerState<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<_SettingsTab> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ipCtrl = TextEditingController();
  final _exactLocationCtrl = TextEditingController();
  final _coverageCtrl = TextEditingController();
  final _speedCtrl = TextEditingController();
  final _latitudeCtrl = TextEditingController();
  final _longitudeCtrl = TextEditingController();

  String? _selectedProvinceId;
  String? _selectedDistrict;
  String? _networkType;
  String? _imageBase64;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _ipCtrl.dispose();
    _exactLocationCtrl.dispose();
    _coverageCtrl.dispose();
    _speedCtrl.dispose();
    _latitudeCtrl.dispose();
    _longitudeCtrl.dispose();
    super.dispose();
  }

  void _loadNetworkData(NetworkModel network) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = network.name;
    _phoneCtrl.text = network.ownerPhone ?? '';
    _ipCtrl.text = network.connectionIP ?? '';
    _exactLocationCtrl.text = network.exactLocation ?? '';
    _coverageCtrl.text = network.coverage ?? '';
    _speedCtrl.text = network.speed ?? '';
    _selectedProvinceId = network.provinceId;
    _selectedDistrict = network.district;
    _networkType = network.networkType;
    _imageBase64 = network.imageBase64;
  }

  Future<void> _saveSettings(NetworkModel network) async {
    setState(() => _isSaving = true);
    try {
      final provinceName = _selectedProvinceId != null
          ? AppConstants.getProvinceName(_selectedProvinceId!)
          : null;
      final location = <String, dynamic>{};
      if (_selectedProvinceId != null) location['provinceId'] = _selectedProvinceId;
      if (provinceName != null) location['provinceName'] = provinceName;
      if (_selectedDistrict != null) location['district'] = _selectedDistrict;
      if (_exactLocationCtrl.text.trim().isNotEmpty) {
        location['exactLocation'] = _exactLocationCtrl.text.trim();
      }

      final updates = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'ownerPhone': _phoneCtrl.text.trim(),
        'connectionIP': _ipCtrl.text.trim(),
        'coverage': _coverageCtrl.text.trim(),
        'speed': _speedCtrl.text.trim(),
        ...location,
      };

      if (_networkType != null) updates['networkType'] = _networkType;
      if (_imageBase64 != null) updates['imageBase64'] = _imageBase64;
      if (_latitudeCtrl.text.isNotEmpty) updates['latitude'] = _latitudeCtrl.text;
      if (_longitudeCtrl.text.isNotEmpty) updates['longitude'] = _longitudeCtrl.text;

      await FirebaseDatabase.instance
          .ref('${AppConstants.fbNetworks}/${network.id}')
          .update(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('saved'))),
        );
      }
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
    final loc = AppLocalizations.of(context);
    final networksAsync = ref.watch(networksProvider);

    return networksAsync.when(
      loading: () => const LoadingShimmer(type: ShimmerType.detail, itemCount: 2),
      error: (e, _) => AppErrorWidget(message: e.toString()),
      data: (networks) {
        final network = networks.where((n) => n.id == widget.networkId).firstOrNull;
        if (network == null) {
          return EmptyStateWidget(icon: Icons.wifi_off_rounded, title: loc.translate('noNetworks'));
        }
        _loadNetworkData(network);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Basic Info ──
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_rounded, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(loc.translate('networkName'), style: AppTheme.headingSmall),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: loc.translate('networkName') + ' (EN)',
                      controller: _nameCtrl,
                      prefixIcon: Icons.wifi_rounded,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: loc.translate('phone'),
                      controller: _phoneCtrl,
                      prefixIcon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: loc.translate('connectionIP'),
                      controller: _ipCtrl,
                      prefixIcon: Icons.dns_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Location ──
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: AppTheme.accentGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(loc.translate('networkLocation'), style: AppTheme.headingSmall),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Province dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.translate('province'), style: AppTheme.labelMedium),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.adaptiveBackground(context),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(color: AppTheme.adaptiveDivider(context)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text(loc.translate('selectProvince')),
                              value: _selectedProvinceId,
                              items: AppConstants.provinces.map((province) {
                                return DropdownMenuItem<String>(
                                  value: province['id'] as String,
                                  child: Text(
                                    province['name'] as String,
                                    style: AppTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedProvinceId = value;
                                  _selectedDistrict = null;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // District dropdown
                    if (_selectedProvinceId != null) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.translate('district'), style: AppTheme.labelMedium),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.adaptiveBackground(context),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: Border.all(color: AppTheme.adaptiveDivider(context)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text(loc.translate('selectDistrict')),
                                value: _selectedDistrict,
                                items: AppConstants.getDistricts(_selectedProvinceId!).map((d) {
                                  return DropdownMenuItem<String>(
                                    value: d,
                                    child: Text(d, style: AppTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedDistrict = value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    AppTextField(
                      label: loc.translate('exactLocation'),
                      controller: _exactLocationCtrl,
                      prefixIcon: Icons.pin_drop_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── GPS Coordinates ──
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.gps_fixed_rounded, color: AppTheme.tier300, size: 20),
                        const SizedBox(width: 8),
                        Text('GPS', style: AppTheme.headingSmall),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Latitude',
                            controller: _latitudeCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            prefixIcon: Icons.explore_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Longitude',
                            controller: _longitudeCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            prefixIcon: Icons.my_location_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Network Details ──
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.router_rounded, color: AppTheme.secondaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(loc.translate('networkType'), style: AppTheme.headingSmall),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Network Type dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.translate('networkType'), style: AppTheme.labelMedium),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.adaptiveBackground(context),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(color: AppTheme.adaptiveDivider(context)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text(loc.translate('select') + '...'),
                              value: _networkType,
                              items: ['Hotspot', 'WISP', 'Fiber', 'Wireless', 'Satellite'].map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type, style: AppTheme.bodyMedium),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _networkType = value),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: loc.translate('networkCoverage'),
                      controller: _coverageCtrl,
                      prefixIcon: Icons.wifi_tethering_rounded,
                      hint: '500m / 1km',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: loc.translate('networkSpeed'),
                      controller: _speedCtrl,
                      prefixIcon: Icons.speed_rounded,
                      hint: '10 Mbps / 50 Mbps',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Network Image ──
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.image_rounded, color: AppTheme.tier2000, size: 20),
                        const SizedBox(width: 8),
                        Text(loc.translate('image'), style: AppTheme.headingSmall),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_imageBase64 != null && _imageBase64!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: Image.memory(
                          base64Decode(_imageBase64!),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 120,
                            color: AppTheme.dividerColor,
                            child: const Center(child: Icon(Icons.broken_image_rounded)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppButton(
                        text: loc.translate('removeImage'),
                        icon: Icons.delete_rounded,
                        isOutlined: true,
                        onPressed: () => setState(() => _imageBase64 = null),
                        isSmall: true,
                        backgroundColor: AppTheme.accentRed,
                      ),
                    ] else ...[
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.adaptiveBackground(context),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                            color: AppTheme.adaptiveDivider(context),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          onTap: () {
                            // In production: use image_picker to select image, then convert to base64
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate('featureNotAvailable'))),
                            );
                          },
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.upload_rounded,
                                    size: 32, color: AppTheme.adaptiveTextHint(context)),
                                const SizedBox(height: 4),
                                Text(loc.translate('upload'),
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.adaptiveTextHint(context),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Save Button ──
              AppButton(
                text: loc.translate('save'),
                icon: Icons.save_rounded,
                isLoading: _isSaving,
                onPressed: () => _saveSettings(network),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 5 — COMMISSIONS
// ═══════════════════════════════════════════════════════════════

class _CommissionsTab extends ConsumerWidget {
  final String networkId;
  const _CommissionsTab({required this.networkId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final settingsAsync = ref.watch(commissionSettingsProvider);
    final entriesAsync = ref.watch(commissionEntriesProvider);
    final payoutsAsync = ref.watch(monthlyPayoutsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Commission Settings ──
          SectionHeader(
            title: loc.translate('commissionSettings'),
            icon: Icons.settings_applications_rounded,
          ),
          const SizedBox(height: 8),
          settingsAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 1),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (settings) {
              final mySetting = settings
                  .where((s) => s.networkId == networkId)
                  .firstOrNull;
              if (mySetting == null) {
                return AppCard(
                  child: EmptyStateWidget(
                    icon: Icons.monetization_on_outlined,
                    title: loc.translate('noCommissionSettings'),
                    subtitle: loc.translate('contactSupport'),
                  ),
                );
              }
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoRow(
                      icon: Icons.percent_rounded,
                      label: loc.translate('defaultRate'),
                      value: '${mySetting.defaultRate}%',
                      iconColor: AppTheme.primaryColor,
                    ),
                    if (mySetting.provinceRates.isNotEmpty)
                      InfoRow(
                        icon: Icons.map_rounded,
                        label: loc.translate('provinceRate'),
                        value: '${mySetting.provinceRates.length} ${loc.translate('settings')}',
                        iconColor: AppTheme.accentGreen,
                      ),
                    if (mySetting.districtRates.isNotEmpty)
                      InfoRow(
                        icon: Icons.location_city_rounded,
                        label: loc.translate('districtRate'),
                        value: '${mySetting.districtRates.length} ${loc.translate('settings')}',
                        iconColor: AppTheme.tier300,
                      ),
                    if (mySetting.tierRates.isNotEmpty)
                      InfoRow(
                        icon: Icons.layers_rounded,
                        label: loc.translate('tierRate'),
                        value: '${mySetting.tierRates.length} ${loc.translate('settings')}',
                        iconColor: AppTheme.secondaryColor,
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // ── Monthly Summary ──
          SectionHeader(
            title: loc.translate('monthlyPayouts'),
            icon: Icons.calendar_month_rounded,
          ),
          const SizedBox(height: 8),
          payoutsAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 2),
            error: (e, _) => const SizedBox.shrink(),
            data: (payouts) {
              final myPayouts = payouts.where((p) => p.networkId == networkId).toList();
              if (myPayouts.isEmpty) {
                return AppCard(
                  child: EmptyStateWidget(
                    icon: Icons.calendar_month_outlined,
                    title: loc.translate('noPayouts'),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myPayouts.length,
                itemBuilder: (context, index) {
                  final payout = myPayouts[index];
                  final statusColor = payout.status == 'paid'
                      ? AppTheme.accentGreen
                      : payout.status == 'pending'
                          ? AppTheme.secondaryColor
                          : AppTheme.accentRed;
                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Icon(Icons.receipt_long_rounded, color: statusColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(payout.month, style: AppTheme.titleMedium),
                              const SizedBox(height: 2),
                              Text(
                                '${payout.totalCommission.toInt()} ر.ي | ${payout.totalCards} ${loc.translate('cards')}',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.adaptiveTextSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(
                          text: payout.status == 'paid'
                              ? loc.translate('paid')
                              : loc.translate('pending'),
                          color: statusColor,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // ── Commission Entries ──
          SectionHeader(
            title: loc.translate('commissionEntries'),
            icon: Icons.list_alt_rounded,
          ),
          const SizedBox(height: 8),
          entriesAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 5),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (entries) {
              final myEntries = entries
                  .where((e) => e.networkId == networkId)
                  .toList()
                ..sort((a, b) {
                  if (a.soldAt == null && b.soldAt == null) return 0;
                  if (a.soldAt == null) return 1;
                  if (b.soldAt == null) return -1;
                  return b.soldAt!.compareTo(a.soldAt!);
                });

              if (myEntries.isEmpty) {
                return AppCard(
                  child: EmptyStateWidget(
                    icon: Icons.list_alt_outlined,
                    title: loc.translate('noCommissionEntries'),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myEntries.length,
                itemBuilder: (context, index) {
                  final entry = myEntries[index];
                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (entry.isPaid ? AppTheme.accentGreen : AppTheme.secondaryColor)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Icon(
                            Icons.monetization_on_rounded,
                            color: entry.isPaid ? AppTheme.accentGreen : AppTheme.secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.commissionAmount.toInt()} ر.ي (${entry.commissionRate}%)',
                                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${entry.cardTier ?? "-"} | ${entry.cardPrice.toInt()} ر.ي | ${entry.soldAt != null ? _formatDate(entry.soldAt!) : "-"}',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.adaptiveTextSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(
                          text: entry.isPaid ? loc.translate('paid') : loc.translate('pending'),
                          color: entry.isPaid ? AppTheme.accentGreen : AppTheme.secondaryColor,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // ── Request Payout ──
          AppButton(
            text: loc.translate('payoutPending') ?? 'Request Payout',
            icon: Icons.payment_rounded,
            isOutlined: true,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.translate('featureNotAvailable'))),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 6 — SALE LOCATIONS
// ═══════════════════════════════════════════════════════════════

class _SaleLocationsTab extends ConsumerStatefulWidget {
  final String networkId;
  const _SaleLocationsTab({required this.networkId});

  @override
  ConsumerState<_SaleLocationsTab> createState() => _SaleLocationsTabState();
}

class _SaleLocationsTabState extends ConsumerState<_SaleLocationsTab> {
  final _nameCtrl = TextEditingController();
  final _exactLocationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _selectedProvinceId;
  String? _selectedDistrict;
  String? _editingId;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _exactLocationCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameCtrl.clear();
    _exactLocationCtrl.clear();
    _phoneCtrl.clear();
    setState(() {
      _selectedProvinceId = null;
      _selectedDistrict = null;
      _editingId = null;
    });
  }

  void _populateForm(CardSaleLocation loc) {
    _nameCtrl.text = loc.name;
    _exactLocationCtrl.text = loc.exactLocation ?? '';
    _phoneCtrl.text = loc.phone ?? '';
    setState(() {
      _selectedProvinceId = loc.provinceId;
      _selectedDistrict = loc.district;
      _editingId = loc.id;
    });
  }

  Future<void> _saveLocation() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final networks = ref.read(networksProvider).value ?? [];
      final network = networks.firstWhere((n) => n.id == widget.networkId);
      final db = FirebaseDatabase.instance;
      final provinceName = _selectedProvinceId != null
          ? AppConstants.getProvinceName(_selectedProvinceId!)
          : null;

      if (_editingId != null) {
        final updates = <String, dynamic>{
          'name': _nameCtrl.text.trim(),
          'exactLocation': _exactLocationCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
        };
        if (_selectedProvinceId != null) updates['provinceId'] = _selectedProvinceId;
        if (provinceName != null) updates['provinceName'] = provinceName;
        if (_selectedDistrict != null) updates['district'] = _selectedDistrict;
        await db.ref('${AppConstants.fbCardSaleLocations}/${_editingId!}').update(updates);
      } else {
        final ref_ = db.ref(AppConstants.fbCardSaleLocations).push();
        final location = CardSaleLocation(
          id: ref_.key!,
          networkId: widget.networkId,
          networkName: network.name,
          name: _nameCtrl.text.trim(),
          provinceId: _selectedProvinceId,
          provinceName: provinceName,
          district: _selectedDistrict,
          exactLocation: _exactLocationCtrl.text.trim().isNotEmpty
              ? _exactLocationCtrl.text.trim()
              : null,
          phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
          isActive: true,
          createdAt: DateTime.now(),
        );
        await ref_.set(location.toMap());
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

  Future<void> _deleteLocation(CardSaleLocation loc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('confirmDelete')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
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
        .ref('${AppConstants.fbCardSaleLocations}/${loc.id}')
        .remove();
  }

  Future<void> _toggleActive(CardSaleLocation loc) async {
    await FirebaseDatabase.instance
        .ref('${AppConstants.fbCardSaleLocations}/${loc.id}')
        .update({'isActive': !loc.isActive});
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final locationsAsync = ref.watch(saleLocationsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Add/Edit Form ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editingId != null ? loc.translate('editSaleLocation') : loc.translate('addSaleLocation'),
                  style: AppTheme.headingSmall,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: loc.translate('locationName'),
                  controller: _nameCtrl,
                  prefixIcon: Icons.store_rounded,
                ),
                const SizedBox(height: 12),

                // Province dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.translate('province'), style: AppTheme.labelMedium),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.adaptiveBackground(context),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.adaptiveDivider(context)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text(loc.translate('selectProvince')),
                          value: _selectedProvinceId,
                          items: AppConstants.provinces.map((province) {
                            return DropdownMenuItem<String>(
                              value: province['id'] as String,
                              child: Text(
                                province['name'] as String,
                                style: AppTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedProvinceId = value;
                              _selectedDistrict = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // District dropdown
                if (_selectedProvinceId != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.translate('district'), style: AppTheme.labelMedium),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.adaptiveBackground(context),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.adaptiveDivider(context)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text(loc.translate('selectDistrict')),
                            value: _selectedDistrict,
                            items: AppConstants.getDistricts(_selectedProvinceId!).map((d) {
                              return DropdownMenuItem<String>(
                                value: d,
                                child: Text(d, style: AppTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedDistrict = value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                AppTextField(
                  label: loc.translate('exactLocation'),
                  controller: _exactLocationCtrl,
                  prefixIcon: Icons.pin_drop_rounded,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: loc.translate('phone'),
                  controller: _phoneCtrl,
                  prefixIcon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: _editingId != null ? loc.translate('update') : loc.translate('add'),
                        icon: _editingId != null ? Icons.edit_rounded : Icons.add_rounded,
                        isLoading: _isSaving,
                        onPressed: _saveLocation,
                      ),
                    ),
                    if (_editingId != null) ...[
                      const SizedBox(width: 8),
                      AppButton(
                        text: loc.translate('cancel'),
                        isOutlined: true,
                        onPressed: _clearForm,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Location List ──
          SectionHeader(title: loc.translate('mySaleLocations'), icon: Icons.place_rounded),
          const SizedBox(height: 8),
          locationsAsync.when(
            loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 4),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (locations) {
              final myLocations = locations.where((l) => l.networkId == widget.networkId).toList();
              if (myLocations.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.place_rounded,
                  title: loc.translate('noSaleLocations'),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myLocations.length,
                itemBuilder: (context, index) {
                  final location = myLocations[index];
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (location.isActive ? AppTheme.accentGreen : AppTheme.accentRed)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              ),
                              child: Icon(
                                Icons.store_rounded,
                                color: location.isActive ? AppTheme.accentGreen : AppTheme.accentRed,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(location.name, style: AppTheme.titleMedium),
                                  const SizedBox(height: 2),
                                  if (location.provinceName != null || location.district != null)
                                    Text(
                                      [
                                        location.provinceName ?? '',
                                        location.district ?? '',
                                      ].where((s) => s.isNotEmpty).join(' > '),
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.adaptiveTextSecondary(context),
                                      ),
                                    ),
                                  if (location.exactLocation != null)
                                    Text(
                                      location.exactLocation!,
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.adaptiveTextHint(context),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            Switch(
                              value: location.isActive,
                              onChanged: (_) => _toggleActive(location),
                              activeThumbColor: AppTheme.accentGreen,
                            ),
                          ],
                        ),
                        if (location.phone != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.phone_rounded, size: 14, color: AppTheme.adaptiveTextHint(context)),
                              const SizedBox(width: 4),
                              Text(
                                location.phone!,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.adaptiveTextSecondary(context),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 18),
                                onPressed: () => _populateForm(location),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: AppTheme.accentRed, size: 18),
                                onPressed: () => _deleteLocation(location),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 18),
                                onPressed: () => _populateForm(location),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: AppTheme.accentRed, size: 18),
                                onPressed: () => _deleteLocation(location),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════

Color _parseColor(String? hex, Color fallback) {
  if (hex == null || hex.isEmpty) return fallback;
  try {
    final hexStr = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hexStr', radix: 16));
  } catch (_) {
    return fallback;
  }
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
