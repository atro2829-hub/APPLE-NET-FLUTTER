// ============================================================
// Apple.NET — SIM Cards Screen (Coming Soon)
// ============================================================

import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../l10n/app_localizations.dart';

class SimsScreen extends StatelessWidget {
  const SimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('simCards'))),
      body: EmptyStateWidget(
        icon: Icons.sim_card_rounded,
        title: loc.translate('comingSoon'),
        subtitle: loc.translate('featureNotAvailable'),
      ),
    );
  }
}
