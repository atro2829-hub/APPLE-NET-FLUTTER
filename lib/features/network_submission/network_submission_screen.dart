// ============================================================
// Apple.NET — Network Submission Screen
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../l10n/app_localizations.dart';

class NetworkSubmissionScreen extends ConsumerStatefulWidget {
  const NetworkSubmissionScreen({super.key});

  @override
  ConsumerState<NetworkSubmissionScreen> createState() =>
      _NetworkSubmissionScreenState();
}

class _NetworkSubmissionScreenState
    extends ConsumerState<NetworkSubmissionScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _coverageController = TextEditingController();
  final _speedController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedProvinceId;
  String? _selectedDistrict;
  String? _selectedNetworkType;
  String? _imageBase64;
  bool _isSubmitting = false;

  final List<String> _networkTypes = [
    'Hotspot',
    'Wi-Fi',
    'WISP',
    'Fiber',
    'LTE',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _coverageController.dispose();
    _speedController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
      setState(() => _imageBase64 = base64Encode(bytes));
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

  Future<void> _submitNetwork() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProvinceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('selectProvince')),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
      final user = ref.read(currentUserProvider).valueOrNull ?? AppUser(uid: uid ?? '', email: '', displayName: '', phone: '', role: 'user', managedNetwork: '', balance: 0, isActive: true);
      final provinceName = AppConstants.getProvinceName(_selectedProvinceId!);

      await FirebaseDatabase.instance
          .ref(AppConstants.fbNetworkSubmissions)
          .push()
          .set({
        'networkName': _nameController.text.trim(),
        'provinceId': _selectedProvinceId,
        'provinceName': provinceName,
        'district': _selectedDistrict ?? '',
        'exactLocation': _locationController.text.trim(),
        'networkType': _selectedNetworkType ?? '',
        'coverage': _coverageController.text.trim(),
        'speed': _speedController.text.trim(),
        'description': _descriptionController.text.trim(),
        'submittedBy': uid,
        'submitterName': user?.displayName ?? '',
        'submitterEmail': user?.email ?? '',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        if (_imageBase64 != null) 'imageBase64': _imageBase64,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context).translate('submitSuccess')),
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

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('submitNewNetwork'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Network Name ──
              AppTextField(
                controller: _nameController,
                label: loc.translate('networkName'),
                prefixIcon: Icons.wifi_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? loc.translate('fieldRequired') : null,
              ),
              const SizedBox(height: 16),

              // ── Province Dropdown ──
              Text(loc.translate('province'), style: AppTheme.labelMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedProvinceId,
                decoration: InputDecoration(
                  hintText: loc.translate('selectProvince'),
                  prefixIcon: const Icon(Icons.location_on_rounded, size: 20),
                ),
                items: AppConstants.provinces.map((p) {
                  return DropdownMenuItem(
                    value: p['id'] as String,
                    child: Text(
                      p['name'] as String,
                      style: AppTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProvinceId = value;
                    _selectedDistrict = null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // ── District Dropdown ──
              if (_selectedProvinceId != null) ...[
                Text(loc.translate('district'), style: AppTheme.labelMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: InputDecoration(
                    hintText: loc.translate('selectDistrict'),
                    prefixIcon: const Icon(Icons.location_city_rounded, size: 20),
                  ),
                  items: AppConstants.getDistricts(_selectedProvinceId!)
                      .map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Text(d, style: AppTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedDistrict = value);
                  },
                ),
                const SizedBox(height: 16),
              ],

              // ── Exact Location ──
              AppTextField(
                controller: _locationController,
                label: loc.translate('exactLocation'),
                prefixIcon: Icons.place_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? loc.translate('fieldRequired') : null,
              ),
              const SizedBox(height: 16),

              // ── Network Type Dropdown ──
              Text(loc.translate('networkType'), style: AppTheme.labelMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedNetworkType,
                decoration: InputDecoration(
                  hintText: loc.translate('networkType'),
                  prefixIcon: const Icon(Icons.router_rounded, size: 20),
                ),
                items: _networkTypes.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t, style: AppTheme.bodyMedium),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedNetworkType = value);
                },
              ),
              const SizedBox(height: 16),

              // ── Coverage ──
              AppTextField(
                controller: _coverageController,
                label: loc.translate('coverage'),
                prefixIcon: Icons.signal_cellular_alt_rounded,
              ),
              const SizedBox(height: 16),

              // ── Speed ──
              AppTextField(
                controller: _speedController,
                label: loc.translate('speed'),
                prefixIcon: Icons.speed_rounded,
              ),
              const SizedBox(height: 16),

              // ── Description ──
              AppTextField(
                controller: _descriptionController,
                label: loc.translate('description'),
                prefixIcon: Icons.description_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // ── Image Upload ──
              Text(loc.translate('image'), style: AppTheme.labelMedium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  decoration: AppTheme.adaptiveCardDecoration(context),
                  child: _imageBase64 != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          child: Image.memory(
                            base64Decode(_imageBase64!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_rounded,
                                size: 36, color: AppTheme.adaptiveTextHint(context)),
                            const SizedBox(height: 8),
                            Text(loc.translate('upload'),
                                style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.adaptiveTextHint(context))),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Submit Button ──
              AppButton(
                text: loc.translate('submitNewNetwork'),
                icon: Icons.send_rounded,
                isLoading: _isSubmitting,
                onPressed: _submitNetwork,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
