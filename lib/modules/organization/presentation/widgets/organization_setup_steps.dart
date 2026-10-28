import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/gawen_text_field.dart';
import '../../../../core/theme/app_theme.dart';

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

            SizedBox(height:20),
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
                style: TextStyle(
                  color: GawenColors.muted,
                  fontSize: 11,
                ),
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
    required this.phoneValidator,
    required this.urlValidator,
    required this.nameValidator,
    super.key,
  });

  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController photoProfile;
  final String? Function(String?) phoneValidator;
  final String? Function(String?) urlValidator;
  final String? Function(String?) nameValidator;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      GawenTextField(
        controller: name,
        label: 'Nama lengkap *',
        hint: 'Nama lengkap',
        icon: Icons.person_outline,
        validator: nameValidator,
      ),
      GawenTextField(
        controller: email,
        label: 'Email',
        hint: 'Email',
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        enabled: false,
      ),
      GawenTextField(
        controller: phone,
        label: 'Nomor telepon *',
        hint: '81234567890',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        indonesianPhone: true,
        validator: phoneValidator,
      ),
      GawenTextField(
        controller: photoProfile,
        label: 'Foto profil (URL)',
        hint: 'https://...',
        icon: Icons.image_outlined,
        validator: urlValidator,
      ),
    ],
  );
}

class BusinessInformationStep extends StatelessWidget {
  const BusinessInformationStep({
    required this.name,
    required this.businessType,
    required this.description,
    required this.nameValidator,
    required this.businessTypeValidator,
    super.key,
  });

  final TextEditingController name;
  final TextEditingController businessType;
  final TextEditingController description;
  final String? Function(String?) nameValidator;
  final String? Function(String?) businessTypeValidator;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      GawenTextField(
        controller: name,
        label: 'Nama usaha *',
        hint: 'Contoh: Yanto Kopi',
        icon: Icons.storefront_outlined,
        maxLength: 120,
        validator: nameValidator,
      ),
      GawenTextField(
        controller: businessType,
        label: 'Jenis usaha *',
        hint: 'Contoh: Kedai kopi',
        icon: Icons.category_outlined,
        maxLength: 80,
        validator: businessTypeValidator,
      ),
      GawenTextField(
        controller: description,
        label: 'Deskripsi',
        hint: 'Ceritakan tentang usaha',
        icon: Icons.notes_outlined,
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
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        indonesianPhone: true,
        validator: phoneValidator,
      ),
      GawenTextField(
        controller: email,
        label: 'Email usaha',
        hint: 'usaha@email.com',
        icon: Icons.mail_outline,
        keyboardType: TextInputType.emailAddress,
        validator: emailValidator,
      ),
      GawenTextField(
        controller: website,
        label: 'Website',
        hint: 'https://contoh.com',
        icon: Icons.language_outlined,
        validator: websiteValidator,
      ),
    ],
  );
}

class BusinessAddressStep extends StatelessWidget {
  const BusinessAddressStep({
    required this.address,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.validator,
    super.key,
  });

  final TextEditingController address;
  final TextEditingController city;
  final TextEditingController province;
  final TextEditingController postalCode;
  final String? Function(String?) Function(int, String) validator;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _field(address, 'Alamat lengkap', Icons.location_on_outlined, 255),
      _field(city, 'Kota', Icons.location_city_outlined, 120),
      _field(province, 'Provinsi', Icons.map_outlined, 120),
      _field(postalCode, 'Kode pos', Icons.markunread_mailbox_outlined, 20),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon,
    int max,
  ) => GawenTextField(
    controller: controller,
    label: label,
    hint: label,
    icon: icon,
    maxLength: max,
    validator: validator(max, label),
  );
}

class BusinessIdentityStep extends StatelessWidget {
  const BusinessIdentityStep({
    required this.logo,
    required this.logoValidator,
    super.key,
  });

  final TextEditingController logo;
  final String? Function(String?) logoValidator;

  @override
  Widget build(BuildContext context) => GawenTextField(
    controller: logo,
    label: 'Logo usaha (URL)',
    hint: 'https://contoh.com/logo.png',
    icon: Icons.image_outlined,
    validator: logoValidator,
  );
}
