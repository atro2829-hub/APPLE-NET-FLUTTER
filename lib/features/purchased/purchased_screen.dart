// ============================================================
// Apple.NET — Purchased Cards Screen
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../app/theme.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';

class PurchasedScreen extends ConsumerStatefulWidget {
  const PurchasedScreen({super.key});

  @override
  ConsumerState<PurchasedScreen> createState() => _PurchasedScreenState();
}

class _PurchasedScreenState extends ConsumerState<PurchasedScreen> {
  String? _filterNetwork;
  String? _filterStatus; // 'used' or 'valid'

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cardsAsync = ref.watch(cardsProvider);
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('myPurchases'))),
      body: Column(
        children: [
          // ── Filters ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: InfoChip(
                    label: loc.translate('all'),
                    isSelected: _filterStatus == null,
                    onTap: () => setState(() => _filterStatus = null),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InfoChip(
                    label: loc.translate('cardValid'),
                    color: AppTheme.accentGreen,
                    isSelected: _filterStatus == 'valid',
                    onTap: () => setState(() => _filterStatus = 'valid'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InfoChip(
                    label: loc.translate('cardUsed'),
                    color: AppTheme.accentRed,
                    isSelected: _filterStatus == 'used',
                    onTap: () => setState(() => _filterStatus = 'used'),
                  ),
                ),
              ],
            ),
          ),

          // ── Cards List ──
          Expanded(
            child: cardsAsync.when(
              loading: () => LoadingShimmer(type: ShimmerType.list),
              error: (e, _) => AppErrorWidget(message: e.toString()),
              data: (cards) {
                var purchased = cards.where((c) => c.usedBy == uid).toList();

                // Apply filters
                if (_filterStatus == 'valid') {
                  purchased = purchased.where((c) => !c.isUsed).toList();
                } else if (_filterStatus == 'used') {
                  purchased = purchased.where((c) => c.isUsed).toList();
                }

                if (purchased.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.shopping_bag_outlined,
                    title: loc.translate('noCardsPurchased'),
                    subtitle: loc.translate('noData'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: purchased.length,
                  itemBuilder: (context, i) {
                    final card = purchased[i];
                    final isUsed = card.isUsed;
                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppTheme.getTierColor(card.tier).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                                child: Center(
                                  child: Text(
                                    card.tier,
                                    style: AppTheme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.getTierColor(card.tier),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(card.networkName, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                    Text(
                                      '${card.price.toInt()} ر.ي · ${card.data} · ${card.duration} ${loc.translate('days')}',
                                      style: AppTheme.bodySmall.copyWith(color: AppTheme.adaptiveTextSecondary(context)),
                                    ),
                                  ],
                                ),
                              ),
                              StatusBadge(
                                text: isUsed ? loc.translate('cardUsed') : loc.translate('cardValid'),
                                color: isUsed ? AppTheme.accentRed : AppTheme.accentGreen,
                                icon: isUsed ? Icons.check_circle_rounded : Icons.verified_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ── Card Code ──
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.adaptiveBackground(context),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    card.code,
                                    style: AppTheme.bodyMedium.copyWith(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, size: 18),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: card.code));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(loc.translate('copiedToClipboard'))),
                                    );
                                  },
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
          ),
        ],
      ),
    );
  }
}
