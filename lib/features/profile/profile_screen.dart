// ============================================================
// Apple.NET — Profile Screen
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isEditing = false;
  bool _isChangingPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseDatabase.instance.ref('${AppConstants.fbUsers}/$uid').update({
        'displayName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('profileUpdated')),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.accentRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPassController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('passwordMismatch')),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) return;

      final credential = fb_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPassController.text,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPassController.text);

      setState(() => _isChangingPassword = false);
      _currentPassController.clear();
      _newPassController.clear();
      _confirmPassController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('passwordChanged')),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('passwordChangeFailed')),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final loc = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: Text(loc.translate('deleteAccount')),
        content: Text(loc.translate('deleteAccountWarning')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.translate('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.translate('delete'), style: const TextStyle(color: AppTheme.textOnPrimary)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Delete user data
      await FirebaseDatabase.instance.ref('${AppConstants.fbUsers}/$uid').remove();
      await FirebaseDatabase.instance.ref('${AppConstants.fbNotifications}/$uid').remove();

      // Delete Firebase Auth account
      await fb_auth.FirebaseAuth.instance.currentUser?.delete();

      if (mounted) context.go('/login');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;

    if (user != null && !_isEditing && !_isChangingPassword) {
      _nameController.text = user.displayName;
      _phoneController.text = user.phone;
    }

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('profile'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover + Avatar ──
            Container(
              height: 140,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryDark, AppTheme.primaryColor, AppTheme.primaryLight],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppTheme.radiusLg)),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -50),
              child: Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppTheme.adaptiveCardColor(context),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.adaptiveCardColor(context), width: 4),
                    boxShadow: AppTheme.adaptiveShadow(context),
                  ),
                  child: Center(
                    child: Text(
                      user?.displayName.isNotEmpty == true ? user!.displayName[0].toUpperCase() : '?',
                      style: AppTheme.headingLarge.copyWith(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Name & Email ──
            Center(
              child: Column(
                children: [
                  Text(user?.displayName ?? '', style: AppTheme.headingSmall),
                  Text(user?.email ?? '', style: AppTheme.bodySmall.copyWith(color: AppTheme.adaptiveTextSecondary(context))),
                  const SizedBox(height: 6),
                  StatusBadge(
                    text: user?.role == 'admin'
                        ? loc.translate('admin')
                        : (user?.role == 'network_manager' ? loc.translate('manager') : loc.translate('roleUser')),
                    color: user?.role == 'admin'
                        ? AppTheme.accentRed
                        : (user?.role == 'network_manager' ? AppTheme.secondaryColor : AppTheme.primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Edit Profile ──
            SectionHeader(
              title: loc.translate('personalInfo'),
              icon: Icons.person_rounded,
              actionText: _isEditing ? loc.translate('cancel') : loc.translate('edit'),
              onActionTap: () => setState(() => _isEditing = !_isEditing),
            ),
            AppCard(
              child: Column(
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: loc.translate('displayName'),
                    prefixIcon: Icons.person_outline,
                    readOnly: !_isEditing,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _phoneController,
                    label: loc.translate('phone'),
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    readOnly: !_isEditing,
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 16),
                    AppButton(
                      text: loc.translate('updateProfile'),
                      isLoading: _isLoading,
                      onPressed: _updateProfile,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Change Password ──
            SectionHeader(
              title: loc.translate('securitySettings'),
              icon: Icons.security_rounded,
              actionText: _isChangingPassword ? loc.translate('cancel') : loc.translate('changePassword'),
              onActionTap: () => setState(() => _isChangingPassword = !_isChangingPassword),
            ),
            if (_isChangingPassword)
              AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      controller: _currentPassController,
                      label: loc.translate('currentPassword'),
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _newPassController,
                      label: loc.translate('newPassword'),
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _confirmPassController,
                      label: loc.translate('confirmNewPassword'),
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: loc.translate('changePassword'),
                      isLoading: _isLoading,
                      onPressed: _changePassword,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // ── Delete Account ──
            AppButton(
              text: loc.translate('deleteAccount'),
              icon: Icons.delete_forever_rounded,
              isOutlined: true,
              backgroundColor: AppTheme.accentRed,
              onPressed: _deleteAccount,
            ),
            const SizedBox(height: 32),

            // ── Owner Info ──
            SectionHeader(title: loc.translate('ownerInfo'), icon: Icons.business_rounded),
            AppCard(
              child: Column(
                children: [
                  InfoRow(icon: Icons.person_rounded, label: loc.translate('name'), value: AppConstants.ownerName),
                  InfoRow(icon: Icons.phone_rounded, label: loc.translate('phone'), value: AppConstants.ownerPhone, trailing: IconButton(icon: const Icon(Icons.copy_rounded, size: 16), onPressed: () { Clipboard.setData(ClipboardData(text: AppConstants.ownerPhone)); })),
                  InfoRow(icon: Icons.email_rounded, label: loc.translate('email'), value: AppConstants.ownerEmail),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Developer Credit ──
            Center(
              child: Column(
                children: [
                  Text(
                    loc.translate('developerBy'),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.adaptiveTextSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.developerEmail,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
