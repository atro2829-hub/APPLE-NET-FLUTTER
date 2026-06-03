// ============================================================
// Apple.NET — Banks Screen
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';

class BanksScreen extends ConsumerWidget {
  const BanksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final banksAsync = ref.watch(banksProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('bankAccounts'))),
      body: banksAsync.when(
        loading: () => LoadingShimmer(type: ShimmerType.list),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (banks) {
          final active = banks.where((b) => b.isActive).toList();
          if (active.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.account_balance_rounded,
              title: loc.translate('noBanks'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: active.length,
            itemBuilder: (context, i) {
              final bank = active[i];
              return AppCard(
                child: Row(
                  children: [
                    // ── Bank Icon ──
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // ── Bank Details ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bank.bankName,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${loc.translate('accountName')}: ${bank.accountName}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.adaptiveTextSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${loc.translate('accountNumber')}: ${bank.accountNumber}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.adaptiveTextSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Copy Button ──
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 20),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: bank.accountNumber),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loc.translate('copiedToClipboard')),
                          ),
                        );
                      },
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
