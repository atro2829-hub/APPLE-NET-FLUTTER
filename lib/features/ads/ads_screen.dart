// ============================================================
// Apple.NET — Ads Screen
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';

class AdsScreen extends ConsumerWidget {
  const AdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final adsAsync = ref.watch(adsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('advertisements'))),
      body: adsAsync.when(
        loading: () => LoadingShimmer(type: ShimmerType.list),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (ads) {
          final active = ads.where((a) => a.isActive).toList();
          if (active.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.campaign_rounded,
              title: loc.translate('noAds'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: active.length,
            itemBuilder: (context, i) {
              final ad = active[i];
              return GradientCard(
                headerIcon: Icons.campaign_rounded,
                title: ad.title,
                subtitle: ad.description,
                body: const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
