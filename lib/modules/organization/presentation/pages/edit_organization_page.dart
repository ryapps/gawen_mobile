import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/organization/presentation/validators/edit_organization_validator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gawen_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/organization_entity.dart';
import '../bloc/organization_bloc.dart';
import '../widgets/organization_setup_steps.dart';

class EditOrganizationPage extends StatefulWidget {
  const EditOrganizationPage({super.key, this.isSetup = false});

  final bool isSetup;

  @override
  State<EditOrganizationPage> createState() => _EditOrganizationPageState();
}

class _EditOrganizationPageState extends State<EditOrganizationPage> {
  final _formKey = GlobalKey<FormState>();
  final _profileName = TextEditingController();
  final _profileEmail = TextEditingController();
  final _profilePhone = TextEditingController();
  final _photoProfile = TextEditingController();
  final _name = TextEditingController();
  final _businessType = TextEditingController();
  final _description = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _website = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _province = TextEditingController();
  final _postalCode = TextEditingController();
  final _logo = TextEditingController();
  final _timezone = TextEditingController(text: 'Asia/Jakarta');
  final _currency = TextEditingController(text: 'IDR');
  bool _loading = true;
  bool _saving = false;
  String? _error;
  int _step = 0;
  String? _loadedId;

  static const _titles = [
    'Profil Pribadi',
    'Informasi Dasar Usaha',
    'Kontak Usaha',
    'Alamat Usaha',
    'Identitas Usaha',
  ];
  static const _descriptions = [
    'Mulai dengan informasi dasar pemilik bisnis.',
    'Ceritakan sedikit tentang bisnis yang kamu kelola.',
    'Tambahkan informasi agar pelanggan atau tim dapat menghubungi bisnis kamu.',
    'Masukkan lokasi bisnis untuk melengkapi informasi organisasi.',
    'Lengkapi identitas bisnis untuk menyelesaikan pengaturan organisasi.',
  ];
  static const _stepIcons = [
    CupertinoIcons.person,
    Icons.storefront_outlined,
    CupertinoIcons.phone,
    CupertinoIcons.location,
    CupertinoIcons.doc,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthBloc>().state;
    final id = auth.organizationId;
    if (id == null || (widget.isSetup && !auth.isOwner)) {
      setState(() {
        _loading = false;
        _error = 'Akses onboarding tidak tersedia.';
      });
      return;
    }
    try {
      final bloc = context.read<OrganizationBloc>();
      bloc.add(OrganizationLoadRequested(id));
      final loaded = await bloc.stream.firstWhere(
        (state) =>
            state.status == OrganizationStatus.ready ||
            state.status == OrganizationStatus.failure,
      );
      if (loaded.status == OrganizationStatus.failure ||
          loaded.organization == null) {
        throw StateError(loaded.message ?? 'Gagal memuat informasi usaha.');
      }
      final org = loaded.organization!;
      if (!mounted) return;
      final profile = auth.user;
      _profileName.text = profile?.name ?? '';
      _profileEmail.text = profile?.email ?? '';
      _profilePhone.text = EditOrganizationValidator.digitsOnly(profile?.phone);
      _photoProfile.text = profile?.photoProfile ?? '';
      _setOrganization(org);
      if (widget.isSetup) _resume(org);
      setState(() {
        _loadedId = id;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$error';
      });
    }
  }

  void _setOrganization(OrganizationEntity org) {
    _name.text = org.name;
    _businessType.text = org.businessType ?? '';
    _description.text = org.description ?? '';
    _phone.text = EditOrganizationValidator.digitsOnly(org.phone);
    _email.text = org.email ?? '';
    _website.text = org.website ?? '';
    _address.text = org.address ?? '';
    _city.text = org.city ?? '';
    _province.text = org.province ?? '';
    _postalCode.text = org.postalCode ?? '';
    _logo.text = org.logoUrl ?? '';
    _timezone.text = org.timezone;
    _currency.text = org.currency ?? 'IDR';
  }

  void _resume(OrganizationEntity org) {
    _step = org.setupStep.clamp(0, 4);
  }

  @override
  void dispose() {
    for (final controller in [
      _profileName,
      _profilePhone,
      _photoProfile,
      _name,
      _businessType,
      _description,
      _phone,
      _email,
      _website,
      _address,
      _city,
      _province,
      _postalCode,
      _logo,
      _timezone,
      _currency,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSetup && !context.watch<AuthBloc>().state.isOwner) {
      return const Scaffold(body: Center(child: Text('Khusus pemilik usaha.')));
    }
    return Scaffold(
      appBar: widget.isSetup
          ? null
          : AppBar(title: const Text('Pengaturan Perusahaan')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : widget.isSetup
            ? Column(
                children: [
                  OrganizationSetupHeader(
                    onBack: () {
                      if (_step > 0) {
                        setState(() => _step--);
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
                  ),
                  OrganizationSetupProgress(
                    currentStep: _step,
                    totalSteps: _titles.length,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(21, 20, 21, 18),
                      children: [
                        OrganizationSetupSectionHeading(
                          title: _titles[_step],
                          description: _descriptions[_step],
                          icon: _stepIcons[_step],
                        ),
                        if (_error != null) RequestError(message: _error!),
                        Form(key: _formKey, child: _activeStep()),
                        if (_step == 1)
                          _setupHelper(
                            Icons.info_outline,
                            'Informasi ini membantu tim mengenali tempat kerja mereka.',
                          ),
                        if (_step == 2)
                          _setupHelper(
                            Icons.shield_outlined,
                            'Kontak hanya digunakan untuk kebutuhan operasional bisnis.',
                          ),
                        if (_step == 4) _identityNote(),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 11, 20, 13),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: GawenColors.border),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0A1F412C),
                          blurRadius: 20,
                          offset: Offset(0, -7),
                        ),
                      ],
                    ),
                    child: OrganizationSetupNavigation(
                      currentStep: _step,
                      totalSteps: _titles.length,
                      isSaving: _saving,
                      onBack: () => setState(() => _step--),
                      onNext: _next,
                    ),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                children: [
                  ScreenIntro(
                    title: 'Perbarui informasi perusahaan',
                    description: 'Perubahan disimpan ke profil perusahaan.',
                  ),
                  if (_error != null) RequestError(message: _error!),
                  Form(key: _formKey, child: _activeStep()),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : _saveOrganization,
                    child: _saving
                        ? const CircularProgressIndicator()
                        : const Text('Simpan Perubahan'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _setupHelper(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(top: 11),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: GawenColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: GawenColors.muted,
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _identityNote() => Container(
    margin: const EdgeInsets.only(top: 18),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFEEF5FF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.description_outlined, color: GawenColors.info, size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Logo usaha',
                style: TextStyle(
                  color: Color(0xFF325D91),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tambahkan URL logo yang didukung oleh profil organisasi.',
                style: TextStyle(
                  color: Color(0xFF617D9D),
                  fontSize: 10,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _activeStep() {
    if (!widget.isSetup) {
      return Column(
        children: [
          BusinessInformationStep(
            name: _name,
            businessType: _businessType,
            description: _description,
            nameValidator: EditOrganizationValidator.requiredTextValidator(
              'Nama usaha',
              min: 2,
              max: 120,
            ),
            businessTypeValidator:
                EditOrganizationValidator.requiredTextValidator(
                  'Jenis usaha',
                  max: 80,
                ),
          ),
          BusinessContactStep(
            phone: _phone,
            email: _email,
            website: _website,
            phoneValidator: EditOrganizationValidator.optionalPhoneValidator,
            emailValidator: EditOrganizationValidator.emailValidator,
            websiteValidator: EditOrganizationValidator.urlValidator('Website'),
          ),
          BusinessAddressStep(
            address: _address,
            city: _city,
            province: _province,
            postalCode: _postalCode,
            validator: EditOrganizationValidator.maxLengthValidator,
          ),
          BusinessIdentityStep(
            logo: _logo,
            logoValidator: EditOrganizationValidator.urlValidator('Logo'),
          ),
          GawenTextField(
            controller: _timezone,
            label: 'Zona waktu',
            hint: 'Asia/Jakarta',
            icon: Icons.schedule_outlined,
            validator: EditOrganizationValidator.requiredTextValidator(
              'Zona waktu',
              max: 64,
            ),
          ),
          GawenTextField(
            controller: _currency,
            label: 'Mata uang',
            hint: 'IDR',
            icon: Icons.payments_outlined,
            maxLength: 3,
            validator: (value) {
              final currency = value?.trim() ?? '';
              return currency.isEmpty ||
                      RegExp(r'^[A-Za-z]{3}$').hasMatch(currency)
                  ? null
                  : 'Gunakan kode mata uang 3 huruf.';
            },
          ),
        ],
      );
    }

    return switch (_step) {
      0 => PersonalProfileStep(
        name: _profileName,
        email: _profileEmail,
        phone: _profilePhone,
        photoProfile: _photoProfile,
        nameValidator: EditOrganizationValidator.requiredTextValidator(
          'Nama',
          max: 120,
        ),
        phoneValidator: EditOrganizationValidator.validatePhone,
        urlValidator: EditOrganizationValidator.urlValidator('Foto profil'),
      ),
      1 => BusinessInformationStep(
        name: _name,
        businessType: _businessType,
        description: _description,
        nameValidator: EditOrganizationValidator.requiredTextValidator(
          'Nama usaha',
          min: 2,
          max: 120,
        ),
        businessTypeValidator: EditOrganizationValidator.requiredTextValidator(
          'Jenis usaha',
          max: 80,
        ),
      ),
      2 => BusinessContactStep(
        phone: _phone,
        email: _email,
        website: _website,
        phoneValidator: EditOrganizationValidator.optionalPhoneValidator,
        emailValidator: EditOrganizationValidator.emailValidator,
        websiteValidator: EditOrganizationValidator.urlValidator('Website'),
      ),
      3 => BusinessAddressStep(
        address: _address,
        city: _city,
        province: _province,
        postalCode: _postalCode,
        validator: EditOrganizationValidator.maxLengthValidator,
      ),
      _ => BusinessIdentityStep(
        logo: _logo,
        logoValidator: EditOrganizationValidator.urlValidator('Logo'),
      ),
    };
  }

  Future<void> _next() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final authBloc = context.read<AuthBloc>();
      final organizationBloc = context.read<OrganizationBloc>();
      if (_step == 0) {
        organizationBloc.add(
          OrganizationSetupStepSaveRequested(
            organizationId: authBloc.state.organizationId!,
            step: 0,
            fields: {
              'name': _profileName.text.trim(),
              'phone':
                  '+62${EditOrganizationValidator.digitsOnly(_profilePhone.text)}',
              'photoProfile': EditOrganizationValidator.nullable(
                _photoProfile.text,
              ),
            },
          ),
        );
        final saved = await organizationBloc.stream.firstWhere(
          (s) =>
              s.status == OrganizationStatus.ready ||
              s.status == OrganizationStatus.failure,
        );
        if (saved.status == OrganizationStatus.failure) {
          throw StateError(saved.message ?? 'Gagal menyimpan profil.');
        }
        authBloc.add(const SessionRestoreRequested());
      } else {
        await _saveOrganizationFields(
          _step,
          organizationBloc,
          authBloc.state.organizationId!,
        );
      }
      if (_step == 4) {
        organizationBloc.add(
          OrganizationSetupCompletionRequested(authBloc.state.organizationId!),
        );
        final completed = await organizationBloc.stream.firstWhere(
          (s) =>
              s.status == OrganizationStatus.ready ||
              s.status == OrganizationStatus.failure,
        );
        if (completed.status == OrganizationStatus.failure ||
            completed.organization?.isSetupComplete != true) {
          throw StateError(
            completed.message ?? 'Setup belum dapat diselesaikan.',
          );
        }
        if (!mounted) return;
        authBloc.add(const SessionRestoreRequested());
        context.go(AppRoutes.home);
      } else if (mounted) {
        setState(() => _step++);
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveOrganizationFields(
    int step,
    OrganizationBloc bloc,
    String id,
  ) async {
    final fields = switch (step) {
      1 => {
        'name': _name.text.trim(),
        'businessType': _businessType.text.trim(),
        'description': EditOrganizationValidator.nullable(_description.text),
      },
      2 => {
        'phone': EditOrganizationValidator.formatPhone(_phone.text),
        'email': EditOrganizationValidator.nullable(_email.text),
        'website': EditOrganizationValidator.nullable(_website.text),
      },
      3 => {
        'address': EditOrganizationValidator.nullable(_address.text),
        'city': EditOrganizationValidator.nullable(_city.text),
        'province': EditOrganizationValidator.nullable(_province.text),
        'postalCode': EditOrganizationValidator.nullable(_postalCode.text),
      },
      _ => {'logoUrl': EditOrganizationValidator.nullable(_logo.text)},
    };
    bloc.add(
      OrganizationSetupStepSaveRequested(
        organizationId: id,
        step: step,
        fields: {...fields, 'setupStep': step + 1},
      ),
    );
    final state = await bloc.stream.firstWhere(
      (s) =>
          s.status == OrganizationStatus.ready ||
          s.status == OrganizationStatus.failure,
    );
    if (state.status == OrganizationStatus.failure) {
      throw StateError(state.message ?? 'Gagal menyimpan progres.');
    }
  }

  Future<void> _saveOrganization() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      for (var step = 1; step <= 4; step++) {
        await _saveOrganizationFields(
          step,
          context.read<OrganizationBloc>(),
          _loadedId!,
        );
      }
      if (mounted) context.go(AppRoutes.organization);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
