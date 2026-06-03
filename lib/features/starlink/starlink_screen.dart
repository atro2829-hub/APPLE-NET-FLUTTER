// ============================================================
// Apple.NET — Starlink Screen (Standalone)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_database/firebase_database.dart';
import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';

class StarlinkScreen extends ConsumerWidget {
  const StarlinkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final productsAsync = ref.watch(starlinkProductsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('starlinkProducts'))),
      body: CustomScrollView(
        slivers: [
          // ── Hero Section ──
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F1419), Color(0xFF1A1F2E), Color(0xFF242B33)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppTheme.radiusXl)),
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
            loading: () => const SliverFillRemaining(child: LoadingShimmer(type: ShimmerType.list)),
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
                  (context, i) => _StarlinkProductItem(product: active[i], loc: loc),
                  childCount: active.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StarlinkProductItem extends ConsumerWidget {
  final StarlinkProduct product;
  final AppLocalizations loc;
  const _StarlinkProductItem({required this.product, required this.loc});

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
            const Divider(height: 16),
            Text(loc.translate('specs'), style: AppTheme.labelMedium),
            const SizedBox(height: 8),
            ...product.specs.entries.map((e) => InfoRow(
              icon: Icons.info_outline,
              label: e.key,
              value: e.value,
              iconColor: AppTheme.primaryColor,
            )),
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
    final user = ref.read(currentUserProvider).valueOrNull;
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
