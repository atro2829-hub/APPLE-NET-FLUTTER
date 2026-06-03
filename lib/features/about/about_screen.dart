// ============================================================
// Apple.NET — About Screen
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('aboutApp'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── App Logo & Name ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryDark, AppTheme.primaryColor, AppTheme.primaryLight],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.textOnPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wifi_rounded,
                      size: 40,
                      color: AppTheme.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Apple.NET',
                    style: AppTheme.headingLarge.copyWith(
                      color: AppTheme.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.translate('appTagline'),
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textOnPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${loc.translate('version')} ${AppConstants.version}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textOnPrimary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── App Description ──
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(loc.translate('aboutApp'), style: AppTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.translate('appTagline'),
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.adaptiveTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Developer Section ──
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code_rounded, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(loc.translate('developerInfo'), style: AppTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          loc.translate('developerBy'),
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: AppConstants.developerEmail));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate('copiedToClipboard'))),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.email_rounded, size: 16, color: AppTheme.adaptiveTextSecondary(context)),
                              const SizedBox(width: 6),
                              Text(
                                AppConstants.developerEmail,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Owner Section ──
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business_rounded, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(loc.translate('ownerInfo'), style: AppTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Owner Photo
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryDark, AppTheme.primaryColor],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            AppConstants.ownerPhotoAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                AppConstants.ownerName.isNotEmpty
                                    ? AppConstants.ownerName[0]
                                    : '?',
                                style: AppTheme.headingMedium.copyWith(
                                  color: AppTheme.textOnPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.ownerName,
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: AppConstants.ownerPhone));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(loc.translate('copiedToClipboard'))),
                                );
                              },
                              child: InfoRow(
                                icon: Icons.phone_rounded,
                                label: loc.translate('phone'),
                                value: AppConstants.ownerPhone,
                                iconColor: AppTheme.primaryColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: AppConstants.ownerEmail));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(loc.translate('copiedToClipboard'))),
                                );
                              },
                              child: InfoRow(
                                icon: Icons.email_rounded,
                                label: loc.translate('email'),
                                value: AppConstants.ownerEmail,
                                iconColor: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Social / Links ──
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.chat_rounded, color: AppTheme.whatsappBrand),
                    title: Text(loc.translate('whatsapp'), style: AppTheme.bodyMedium),
                    trailing: const Icon(Icons.chevron_left_rounded, size: 20),
                    onTap: () {
                      // Open WhatsApp
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: Icon(Icons.privacy_tip_rounded, color: AppTheme.adaptiveTextSecondary(context)),
                    title: Text(loc.translate('privacyPolicy'), style: AppTheme.bodyMedium),
                    trailing: const Icon(Icons.chevron_left_rounded, size: 20),
                    onTap: () {},
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: Icon(Icons.description_rounded, color: AppTheme.adaptiveTextSecondary(context)),
                    title: Text(loc.translate('termsOfUse'), style: AppTheme.bodyMedium),
                    trailing: const Icon(Icons.chevron_left_rounded, size: 20),
                    onTap: () {},
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Footer ──
            Text(
              'Apple.NET v${AppConstants.version}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.adaptiveTextHint(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
