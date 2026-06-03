// ============================================================
// Apple.NET — Deposit Screen
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';

class DepositScreen extends ConsumerStatefulWidget {
  const DepositScreen({super.key});

  @override
  ConsumerState<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends ConsumerState<DepositScreen> {
  final _amountController = TextEditingController();
  final _refController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedBankId;
  String? _selectedBankName;
  String? _receiptBase64;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    super.dispose();
  }

  Future<void> _pickReceiptImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image == null) return;

      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _receiptBase64 = base64Encode(bytes);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('imageUploaded')),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('imageUploadFailed')),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _submitDeposit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('selectBank')),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final userAsync = ref.read(currentUserProvider);
      final user = userAsync.value;

      await FirebaseDatabase.instance.ref(AppConstants.fbDeposits).push().set({
        'userId': uid,
        'userName': user?.displayName ?? '',
        'userEmail': user?.email ?? '',
        'bankId': _selectedBankId,
        'bankName': _selectedBankName,
        'amount': double.tryParse(_amountController.text) ?? 0,
        'referenceNumber': _refController.text.trim(),
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        if (_receiptBase64 != null) 'imageBase64': _receiptBase64,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('depositSubmitted')),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.accentRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final banksAsync = ref.watch(banksProvider);
    final depositsAsync = ref.watch(depositsProvider);
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('depositBalance'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Bank List ──
              SectionHeader(title: loc.translate('chooseBank'), icon: Icons.account_balance_rounded),
              banksAsync.when(
                loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => AppErrorWidget(message: e.toString()),
                data: (banks) {
                  final active = banks.where((b) => b.isActive).toList();
                  if (active.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.account_balance_rounded,
                      title: loc.translate('noBanks'),
                    );
                  }
                  return Column(
                    children: active.map((bank) => AppCard(
                      onTap: () => setState(() {
                        _selectedBankId = bank.id;
                        _selectedBankName = bank.bankName;
                      }),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: const Icon(Icons.account_balance_rounded, color: AppTheme.primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bank.bankName, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                Text(bank.accountName, style: AppTheme.bodySmall.copyWith(color: AppTheme.adaptiveTextSecondary(context))),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: bank.accountNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(loc.translate('copiedToClipboard'))),
                              );
                            },
                          ),
                          if (_selectedBankId == bank.id)
                            const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 22),
                        ],
                      ),
                    )).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ── Amount ──
              AppTextField(
                controller: _amountController,
                label: loc.translate('amount'),
                prefixIcon: Icons.attach_money_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return loc.translate('fieldRequired');
                  final val = double.tryParse(v);
                  if (val == null || val < AppConstants.minDeposit) return '${loc.translate('minDeposit')}: ${AppConstants.minDeposit.toInt()} ر.ي';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Reference Number ──
              AppTextField(
                controller: _refController,
                label: loc.translate('referenceNumber'),
                prefixIcon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return loc.translate('fieldRequired');
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Receipt Upload ──
              Text(loc.translate('uploadReceipt'), style: AppTheme.labelMedium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickReceiptImage,
                child: Container(
                  height: 120,
                  decoration: AppTheme.adaptiveCardDecoration(context).copyWith(
                    border: Border.all(color: AppTheme.adaptiveDivider(context), width: 2, strokeAlign: BorderSide.strokeAlignInside),
                  ),
                  child: _receiptBase64 != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          child: Image.memory(
                            base64Decode(_receiptBase64!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_rounded, size: 36, color: AppTheme.adaptiveTextHint(context)),
                            const SizedBox(height: 8),
                            Text(loc.translate('upload'), style: AppTheme.bodySmall.copyWith(color: AppTheme.adaptiveTextHint(context))),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Submit Button ──
              AppButton(
                text: loc.translate('sendDepositRequest'),
                isLoading: _isSubmitting,
                onPressed: _submitDeposit,
              ),

              const SizedBox(height: 32),

              // ── Pending Deposits ──
              SectionHeader(title: loc.translate('depositHistory'), icon: Icons.history_rounded),
              depositsAsync.when(
                loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => AppErrorWidget(message: e.toString()),
                data: (deposits) {
                  final myDeposits = deposits.where((d) => d.userId == uid).toList();
                  if (myDeposits.isEmpty) {
                    return EmptyStateWidget(icon: Icons.history_rounded, title: loc.translate('noData'));
                  }
                  return Column(
                    children: myDeposits.take(5).map((d) => AppCard(
                      child: Row(
                        children: [
                          Icon(
                            d.status == 'pending' ? Icons.schedule_rounded : (d.status == 'approved' ? Icons.check_circle_rounded : Icons.cancel_rounded),
                            color: d.status == 'pending' ? AppTheme.warningColor : (d.status == 'approved' ? AppTheme.accentGreen : AppTheme.accentRed),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${d.amount.toInt()} ر.ي', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                Text(d.bankName, style: AppTheme.bodySmall),
                              ],
                            ),
                          ),
                          StatusBadge(
                            text: loc.translate(d.status),
                            color: d.status == 'pending' ? AppTheme.warningColor : (d.status == 'approved' ? AppTheme.accentGreen : AppTheme.accentRed),
                          ),
                        ],
                      ),
                    )).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
