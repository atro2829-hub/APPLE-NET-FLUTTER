// ============================================================
// Apple.NET — SIM Cards Screen (Complete)
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';

class SimsScreen extends ConsumerStatefulWidget {
  const SimsScreen({super.key});

  @override
  ConsumerState<SimsScreen> createState() => _SimsScreenState();
}

class _SimsScreenState extends ConsumerState<SimsScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final simsAsync = ref.watch(simsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('simCards'))),
      body: simsAsync.when(
        loading: () => const LoadingShimmer(type: ShimmerType.list, itemCount: 6),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (sims) {
          if (sims.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.sim_card_rounded,
              title: loc.translate('noSims'),
              subtitle: loc.translate('simCardsWillAppear'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: sims.length,
            itemBuilder: (context, index) {
              final sim = sims[index];
              return _SimCardWidget(sim: sim, loc: loc);
            },
          );
        },
      ),
    );
  }
}

class _SimCardWidget extends StatelessWidget {
  final SimCard sim;
  final AppLocalizations loc;

  const _SimCardWidget({required this.sim, required this.loc});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(Icons.sim_card_rounded,
                color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sim.phoneNumber ?? sim.simId,
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      sim.provider,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.adaptiveTextSecondary(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      text: sim.isActive ? loc.translate('active') : loc.translate('inactive'),
                      color: sim.isActive ? AppTheme.accentGreen : AppTheme.accentRed,
                    ),
                  ],
                ),
                if (sim.networkId != null && sim.networkId!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${loc.translate('network')}: ${sim.networkId}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.adaptiveTextSecondary(context),
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            sim.isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: sim.isActive ? AppTheme.accentGreen : AppTheme.accentRed,
            size: 20,
          ),
        ],
      ),
    );
  }
}
