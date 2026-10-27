import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/auth/presentation/validators/auth_form_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/gawen_widgets.dart';
import '../bloc/auth_bloc.dart';
import '../validators/password_validator.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({
    super.key,
    required this.isOwner,
    this.invitationToken,
  });

  final bool isOwner;
  final String? invitationToken;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (widget.isOwner) {
      context.read<AuthBloc>().add(
        OwnerRegistrationSubmitted(
          name: _nameController.text,
          organizationName: _organizationController.text,
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    } else {
      context.read<AuthBloc>().add(
        EmployeeRegistrationSubmitted(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthBloc, AuthState>(
    listenWhen: (previous, current) =>
        previous.status != current.status &&
        current.status == AuthStatus.registered,
    listener: (context, state) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message ?? 'Registrasi diproses.')),
      );
      context.go(
        AppRoutes.login,
        extra: widget.invitationToken == null
            ? null
            : InvitationLoginIntent(widget.invitationToken!),
      );
    },
    builder: (context, state) {
      final loading = state.status == AuthStatus.loading;
      final owner = widget.isOwner;
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  onBack: () => widget.invitationToken == null
                      ? context.go(AppRoutes.welcome)
                      : context.go(
                          AppRoutes.invitation,
                          extra: widget.invitationToken,
                        ),
                ),
                const SizedBox(height: 14),
                ScreenIntro(
                  title: owner
                      ? 'Buat Akun Pemilik Usaha'
                      : 'Buat Akun Karyawan',
                  description: owner
                      ? 'Mulai kelola tim kerjamu dengan lebih praktis.'
                      : 'Buat akun untuk terhubung dengan tempat kerjamu.',
                ),
                if (state.status == AuthStatus.failure && state.message != null)
                  RequestError(message: state.message!),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GawenTextField(
                        controller: _nameController,
                        label: 'Nama lengkap',
                        hint: 'Masukkan nama lengkap',
                        icon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        maxLength: 120,
                        validator: (value) {
                          final name = value?.trim() ?? '';
                          if (name.isEmpty) return 'Nama wajib diisi.';
                          if (name.length > 120) {
                            return 'Maksimal 120 karakter.';
                          }
                          return null;
                        },
                      ),
                      if (owner)
                        GawenTextField(
                          controller: _organizationController,
                          label: 'Nama usaha',
                          hint: 'Contoh: Kopi Pagi',
                          icon: Icons.work_outline,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final organization = value?.trim() ?? '';
                            if (organization.length < 2) {
                              return 'Nama usaha minimal 2 karakter.';
                            }
                            if (organization.length > 120) {
                              return 'Maksimal 120 karakter.';
                            }
                            return null;
                          },
                        ),
                      GawenTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'nama@email.com',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: validateAuthEmail,
                      ),
                      GawenTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Minimal 8 karakter',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        validator: PasswordValidator.validateNewPassword,
                      ),
                      GawenTextField(
                        controller: _confirmationController,
                        label: 'Konfirmasi Password',
                        hint: 'Ulangi password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) =>
                            PasswordValidator.validateConfirmation(
                              confirmation: value,
                              password: _passwordController.text,
                            ),
                      ),
                      
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: loading ? null : _submit,
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(owner ? 'Buat Akun' : 'Daftar'),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Wrap(
                      children: [
                        const Text('Sudah punya akun? '),
                        TextButton(
                          onPressed: loading
                              ? null
                              : () => context.push(
                                  AppRoutes.login,
                                  extra: widget.invitationToken == null
                                      ? null
                                      : InvitationLoginIntent(
                                          widget.invitationToken!,
                                        ),
                                ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Masuk', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
