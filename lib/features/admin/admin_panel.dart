// ============================================================
// Apple.NET — Admin Panel (Stub — to be implemented)
// ============================================================

import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../l10n/app_localizations.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('admin'))),
      body: EmptyStateWidget(
        icon: Icons.admin_panel_settings_rounded,
        title: loc.translate('admin'),
        subtitle: loc.translate('comingSoon'),
      ),
    );
  }
}
