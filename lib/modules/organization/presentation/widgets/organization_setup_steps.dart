import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../../../../core/widgets/gawen_text_field.dart';
import '../../../../core/widgets/gawen_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/organization_business_type.dart';
import '../../../regions/domain/entities/administrative_region.dart';
import '../../../regions/presentation/widgets/organization_region_fields.dart';

class OrganizationSetupProgress extends StatelessWidget {
  const OrganizationSetupProgress({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  });

  final int currentStep;
  final int totalSteps;

  static const _labels = ['Profil', 'Bisnis', 'Kontak', 'Alamat', 'Identitas'];
  static const _icons = [
    CupertinoIcons.person,
    Icons.storefront_outlined,
    CupertinoIcons.phone,
    CupertinoIcons.location,
    CupertinoIcons.doc,
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 360;
      final size = compact ? 32.0 : 35.0;
      return Container(
        padding: EdgeInsets.fromLTRB(
          compact ? 13 : 19,
          14,
          compact ? 13 : 19,
          12,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: GawenColors.border)),
        ),
        child: Column(
          children: [
            Row(
              children: List.generate(totalSteps, (index) {
                final completed = index < currentStep;
                final current = index == currentStep;
                return Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      if (index < totalSteps - 1)
                        Positioned(
                          top: size / 2 - 1,
                          left: size / 2 + 5,
                          right: -size / 2 - 5,
                          child: Container(
                            height: 2,
                            color: completed
                                ? GawenColors.primary
                                : const Color(0xFFE1E6E2),
                          ),
                        ),
                      Column(
                        children: [
                          Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: completed || current
                                  ? GawenColors.primary
                                  : const Color(0xFFEEF1EF),
                              boxShadow: current
                                  ? const [
                                      BoxShadow(
                                        color: GawenColors.primarySoft,
                                        spreadRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              completed ? Icons.check : _icons[index],
                              size: compact ? 18 : 19,
                              color: completed || current
                                  ? Colors.white
                                  : const Color(0xFF98A29B),
                            ),
                          ),
                          const SizedBox(height: 7),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _labels[index],
                              maxLines: 1,
                              style: TextStyle(
                                color: completed || current
                                    ? GawenColors.primaryDark
                                    : const Color(0xFF8A958E),
                                fontSize: compact ? 9 : 10,
                                fontWeight: completed || current
                                    ? FontWeight.w900
                                    : FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Langkah ${currentStep + 1} dari $totalSteps',
                  style: const TextStyle(
                    color: GawenColors.muted,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${(((currentStep + 1) / totalSteps) * 100).round()}%',
                  style: const TextStyle(
                    color: GawenColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class OrganizationSetupHeader extends StatelessWidget {
  const OrganizationSetupHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
    color: Colors.white,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 1),
              Text(
                'Lengkapi Profil Bisnis',
                style: TextStyle(
                  color: GawenColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Isi informasi bisnis untuk mulai menggunakan Gawen.',
                style: TextStyle(color: GawenColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class OrganizationSetupSectionHeading extends StatelessWidget {
  const OrganizationSetupSectionHeading({
    required this.title,
    required this.description,
    required this.icon,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: GawenColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: GawenColors.primary),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: GawenColors.muted,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class OrganizationSetupNavigation extends StatelessWidget {
  const OrganizationSetupNavigation({
    required this.currentStep,
    required this.totalSteps,
    required this.isSaving,
    required this.onBack,
    required this.onNext,
    super.key,
  });

  final int currentStep;
  final int totalSteps;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (currentStep > 0) ...[
        Expanded(
          child: OutlinedButton(
            onPressed: isSaving ? null : onBack,
            child: const Text('Kembali'),
          ),
        ),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: FilledButton(
          onPressed: isSaving ? null : onNext,
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(currentStep == totalSteps - 1 ? 'Simpan' : 'Lanjut'),
        ),
      ),
    ],
  );
}

class PersonalProfileStep extends StatelessWidget {
  const PersonalProfileStep({
    required this.name,
    required this.email,
    required this.phone,
    required this.photoProfile,
    required this.onPickAvatar,
    required this.onCancelAvatar,
    required this.selectedAvatarPath,
    required this.isUploadingAvatar,
    required this.phoneValidator,
    required this.nameValidator,
    super.key,
  });

  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController photoProfile;
  final VoidCallback onPickAvatar;
  final VoidCallback onCancelAvatar;
  final String? selectedAvatarPath;
  final bool isUploadingAvatar;
  final String? Function(String?) phoneValidator;
  final String? Function(String?) nameValidator;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: isUploadingAvatar ? null : onPickAvatar,
          customBorder: const CircleBorder(),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 39,
                backgroundColor: GawenColors.primarySoft,
                child: selectedAvatarPath != null
                    ? ClipOval(
                        child: Image.file(
                          File(selectedAvatarPath!),
                          width: 78,
                          height: 78,
                          fit: BoxFit.cover,
                        ),
                      )
                    : photoProfile.text.trim().isNotEmpty
                    ? ClipOval(
                        child: GawenImage(
                          source: photoProfile.text,
                          width: 78,
                          height: 78,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.person_outline,
                        size: 38,
                        color: GawenColors.primary,
                      ),
              ),
              Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: GawenColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      GawenTextField(
        controller: name,
        label: 'Nama lengkap *',
        hint: 'Jhon Doe',
        validator: nameValidator,
      ),
      GawenTextField(
        controller: email,
        label: 'Email',
        hint: 'john.doe@example.com',
        keyboardType: TextInputType.emailAddress,
        enabled: false,
      ),
      GawenTextField(
        controller: phone,
        label: 'Nomor telepon *',
        hint: '81234567890',
        keyboardType: TextInputType.phone,
        indonesianPhone: true,
        validator: phoneValidator,
      ),
      const SizedBox(height: 22),
    ],
  );
}

class BusinessInformationStep extends StatelessWidget {
  const BusinessInformationStep({
    required this.name,
    required this.businessType,
    required this.onBusinessTypeChanged,
    required this.description,
    required this.nameValidator,
    required this.businessTypeValidator,
    super.key,
  });

  final TextEditingController name;
  final OrganizationBusinessType? businessType;
  final ValueChanged<OrganizationBusinessType?> onBusinessTypeChanged;
  final TextEditingController description;
  final String? Function(String?) nameValidator;
  final String? Function(OrganizationBusinessType?) businessTypeValidator;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      GawenTextField(
        controller: name,
        label: 'Nama usaha *',
        hint: 'Yanto Kopi',
        maxLength: 120,
        validator: nameValidator,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 7),
              child: Text(
                'Jenis usaha *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            DropdownMenu<OrganizationBusinessType>(
              width: MediaQuery.sizeOf(context).width - 48,
              initialSelection: businessType,
              inputDecorationTheme: const InputDecorationTheme(
                contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              menuStyle: MenuStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
              ),
              hintText: 'Pilih jenis usaha',
              dropdownMenuEntries: OrganizationBusinessType.values
                  .map(
                    (type) => DropdownMenuEntry(value: type, label: type.label),
                  )
                  .toList(),
              onSelected: onBusinessTypeChanged,
            ),
          ],
        ),
      ),
      GawenTextField(
        controller: description,
        label: 'Deskripsi',
        hint: 'Ceritakan tentang usaha',
        maxLines: 4,
        maxLength: 2000,
      ),
    ],
  );
}

class BusinessContactStep extends StatelessWidget {
  const BusinessContactStep({
    required this.phone,
    required this.email,
    required this.website,
    required this.phoneValidator,
    required this.emailValidator,
    required this.websiteValidator,
    super.key,
  });

  final TextEditingController phone;
  final TextEditingController email;
  final TextEditingController website;
  final String? Function(String?) phoneValidator;
  final String? Function(String?) emailValidator;
  final String? Function(String?) websiteValidator;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      GawenTextField(
        controller: phone,
        label: 'Telepon usaha',
        hint: '81234567890',
        keyboardType: TextInputType.phone,
        indonesianPhone: true,
        validator: phoneValidator,
      ),
      GawenTextField(
        controller: email,
        label: 'Email usaha',
        hint: 'usaha@email.com',
        keyboardType: TextInputType.emailAddress,
        validator: emailValidator,
      ),
      GawenTextField(
        controller: website,
        label: 'Website',
        hint: 'https://contoh.com',
        validator: websiteValidator,
      ),
    ],
  );
}

class BusinessAddressStep extends StatelessWidget {
  const BusinessAddressStep({
    required this.address,
    required this.province,
    required this.regency,
    required this.district,
    required this.village,
    required this.legacyProvinceName,
    required this.legacyRegencyName,
    required this.onProvinceChanged,
    required this.onRegencyChanged,
    required this.onDistrictChanged,
    required this.onVillageChanged,
    required this.postalCode,
    required this.validator,
    super.key,
  });

  final TextEditingController address;
  final AdministrativeRegion? province;
  final AdministrativeRegion? regency;
  final AdministrativeRegion? district;
  final AdministrativeRegion? village;
  final String? legacyProvinceName;
  final String? legacyRegencyName;
  final ValueChanged<AdministrativeRegion?> onProvinceChanged;
  final ValueChanged<AdministrativeRegion?> onRegencyChanged;
  final ValueChanged<AdministrativeRegion?> onDistrictChanged;
  final ValueChanged<AdministrativeRegion?> onVillageChanged;
  final TextEditingController postalCode;
  final String? Function(String?) Function(int, String) validator;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _field(address, 'Alamat lengkap', 255),
      OrganizationRegionFields(
        province: province,
        regency: regency,
        district: district,
        village: village,
        legacyProvinceName: legacyProvinceName,
        legacyRegencyName: legacyRegencyName,
        onProvinceChanged: onProvinceChanged,
        onRegencyChanged: onRegencyChanged,
        onDistrictChanged: onDistrictChanged,
        onVillageChanged: onVillageChanged,
      ),
      _field(postalCode, 'Kode pos', 20),
    ],
  );

  Widget _field(TextEditingController controller, String label, int max) =>
      GawenTextField(
        controller: controller,
        label: label,
        hint: label,
        maxLength: max,
        validator: validator(max, label),
      );
}

class BusinessIdentityStep extends StatelessWidget {
  const BusinessIdentityStep({
    required this.logo,
    required this.selectedLogoPath,
    required this.isUploadingLogo,
    required this.onPickLogo,
    required this.onRemoveLogo,
    super.key,
  });

  final TextEditingController logo;
  final String? selectedLogoPath;
  final bool isUploadingLogo;
  final VoidCallback onPickLogo;
  final VoidCallback onRemoveLogo;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 17),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 7),
          child: Text(
            'Logo usaha',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: GawenColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Container(
                width: 116,
                height: 116,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: GawenColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: selectedLogoPath != null
                    ? Image.file(File(selectedLogoPath!), fit: BoxFit.cover)
                    : logo.text.isNotEmpty
                    ? GawenImage(
                        source: logo.text,
                        width: 116,
                        height: 116,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.storefront_outlined,
                        size: 48,
                        color: GawenColors.primary,
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                selectedLogoPath != null || logo.text.isNotEmpty
                    ? 'Logo usaha'
                    : 'Tambahkan logo usaha',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Format JPEG, PNG, atau WebP · Maksimal 5 MB',
                textAlign: TextAlign.center,
                style: TextStyle(color: GawenColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isUploadingLogo ? null : onPickLogo,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(
                        selectedLogoPath != null || logo.text.isNotEmpty
                            ? 'Ganti gambar'
                            : 'Pilih gambar',
                      ),
                    ),
                  ),
                  if (selectedLogoPath != null || logo.text.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Hapus logo',
                      onPressed: isUploadingLogo ? null : onRemoveLogo,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ],
              ),
              if (isUploadingLogo) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
