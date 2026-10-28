import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/gawen_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/organization_entity.dart';
import '../bloc/organization_bloc.dart';

class EditOrganizationPage extends StatefulWidget {
  const EditOrganizationPage({super.key});

  @override
  State<EditOrganizationPage> createState() => _EditOrganizationPageState();
}

class _EditOrganizationPageState extends State<EditOrganizationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _timezoneController = TextEditingController();
  String? _initializedOrganizationId;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (!auth.isOwner || auth.organizationId == null) return;

    final organizationId = auth.organizationId!;
    final organizationBloc = context.read<OrganizationBloc>();
    final organization = organizationBloc.state.organization;
    if (organization?.id == organizationId) {
      _populateForm(organization!);
    } else {
      organizationBloc.add(OrganizationLoadRequested(organizationId));
    }
  }

  void _populateForm(OrganizationEntity organization) {
    if (_initializedOrganizationId == organization.id) return;
    _nameController.text = organization.name;
    _timezoneController.text = organization.timezone;
    _initializedOrganizationId = organization.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (!auth.isOwner) {
      return const Scaffold(
        body: Center(child: Text('Hanya pemilik usaha yang dapat mengedit.')),
      );
    }
    return BlocConsumer<OrganizationBloc, OrganizationState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          (current.status == OrganizationStatus.ready ||
              current.status == OrganizationStatus.failure),
      listener: (context, state) {
        final organization = state.organization;
        if (state.status == OrganizationStatus.ready &&
            organization != null &&
            organization.id == context.read<AuthBloc>().state.organizationId) {
          _populateForm(organization);
        }
        if (state.status == OrganizationStatus.ready && state.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
          context.go(AppRoutes.organization);
        }
      },
      builder: (context, state) {
        final loading = state.status == OrganizationStatus.saving;
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Informasi Usaha')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                const ScreenIntro(
                  title: 'Perbarui informasi usaha',
                  description:
                      'Perubahan akan disimpan setelah dikonfirmasi server.',
                ),
                if (state.status == OrganizationStatus.failure &&
                    state.message != null)
                  RequestError(message: state.message!),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GawenTextField(
                        controller: _nameController,
                        label: 'Nama usaha',
                        hint: 'Nama organisasi',
                        icon: Icons.storefront_outlined,
                        maxLength: 120,
                        validator: (value) {
                          final name = value?.trim() ?? '';
                          if (name.length < 2) {
                            return 'Nama usaha minimal 2 karakter.';
                          }
                          if (name.length > 120) {
                            return 'Maksimal 120 karakter.';
                          }
                          return null;
                        },
                      ),
                      GawenTextField(
                        controller: _timezoneController,
                        label: 'Zona waktu',
                        hint: 'Asia/Jakarta',
                        icon: Icons.schedule_outlined,
                        maxLength: 64,
                        validator: (value) {
                          final timezone = value?.trim() ?? '';
                          if (timezone.isEmpty) {
                            return 'Zona waktu wajib diisi.';
                          }
                          if (timezone.length > 64) {
                            return 'Maksimal 64 karakter.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: loading
                              ? null
                              : () {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  final id = auth.organizationId;
                                  if (id == null) return;
                                  context.read<OrganizationBloc>().add(
                                    OrganizationUpdateRequested(
                                      organizationId: id,
                                      name: _nameController.text.trim(),
                                      timezone: _timezoneController.text.trim(),
                                    ),
                                  );
                                },
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Simpan Perubahan'),
                        ),
                      ),
                      TextButton(
                        onPressed: loading
                            ? null
                            : () => context.go(AppRoutes.organization),
                        child: const Text('Batal'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
