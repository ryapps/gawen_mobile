import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/modules/auth/presentation/validators/auth_form_validators.dart';
import 'package:frontend/modules/auth/presentation/validators/password_validator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/gawen_widgets.dart';
import '../bloc/auth_bloc.dart';
import 'login_mode.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.returnTo, this.invitationToken});

  final String? returnTo;
  final String? invitationToken;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  LoginMode _mode = LoginMode.employee;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      LoginSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthBloc, AuthState>(
    listenWhen: (previous, current) =>
        previous.status != current.status &&
        current.status == AuthStatus.authenticated,
    listener: (context, state) {
      if (widget.invitationToken != null) {
        context.go(AppRoutes.invitation, extra: widget.invitationToken);
      } else {
        final destination = switch (state.membershipAccess) {
          MembershipAccess.none => AppRoutes.join,
          MembershipAccess.pending => AppRoutes.pending,
          MembershipAccess.active =>
            safeAuthReturnPath(widget.returnTo) ?? AppRoutes.home,
        };
        context.go(destination);
      }
    },
    builder: (context, state) {
      final loading = state.status == AuthStatus.loading;
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
                const SizedBox(height: 18),
                if (widget.invitationToken == null) ...[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3,vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1FAF5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: GawenColors.primary.withOpacity(0.12),
                        ),
                      ),
                      child: SegmentedButton<LoginMode>(
                        showSelectedIcon: false,
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return GawenColors.primary.withOpacity(0.16);
                                }
                                return Colors.transparent;
                              }),
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color>((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return GawenColors.primary;
                                }
                                return const Color(0xFF68756C);
                              }),
                          textStyle: WidgetStateProperty.resolveWith<TextStyle>(
                            (states) {
                              return TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    states.contains(WidgetState.selected)
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              );
                            },
                          ),
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          side: const WidgetStatePropertyAll(
                            BorderSide(color: Colors.transparent),
                          ),
                          overlayColor: WidgetStatePropertyAll(
                            GawenColors.primary.withOpacity(0.08),
                          ),
                          animationDuration: const Duration(milliseconds: 250),
                          visualDensity: VisualDensity.standard,
                        ),
                        segments: const [
                          ButtonSegment<LoginMode>(
                            value: LoginMode.owner,
                            icon: Icon(Icons.storefront_outlined, size: 18),
                            label: Text('Pemilik'),
                          ),
                          ButtonSegment<LoginMode>(
                            value: LoginMode.employee,
                            icon: Icon(Icons.badge_outlined, size: 18),
                            label: Text('Karyawan'),
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: loading
                            ? null
                            : (selection) {
                                setState(() => _mode = selection.first);
                              },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                ScreenIntro(
                  title: widget.invitationToken != null
                      ? 'Masuk untuk menerima undangan'
                      : _mode == LoginMode.owner
                      ? 'Masuk sebagai Pemilik'
                      : 'Masuk sebagai Karyawan',
                  description: widget.invitationToken != null
                      ? 'Gunakan akun yang menerima undangan untuk melanjutkan.'
                      : _mode == LoginMode.employee
                      ? 'Jika akun belum terhubung ke perusahaan, kamu akan diarahkan untuk memasukkan kode bisnis.'
                      : 'Akses usaha menggunakan akun pemilik yang terdaftar.',
                ),
                if (state.status == AuthStatus.failure && state.message != null)
                  RequestError(message: state.message!),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                        hint: 'Masukkan password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) => PasswordValidator.validateAuthPassword(password: value),
                      ),

                      SizedBox(height: 18),
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
                              : const Text('Masuk'),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 18),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1FAF5),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Color(0xFF21865B)),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Data akunmu dilindungi dan hanya digunakan untuk akses kerja.',
                          style: TextStyle(
                            color: Color(0xFF68756C),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Wrap(
                      children: [
                        const Text('Belum punya akun? '),
                        TextButton(
                          onPressed: loading
                              ? null
                              : () => context.push(
                                  widget.invitationToken == null
                                      ? _mode == LoginMode.owner
                                            ? AppRoutes.ownerRegistration
                                            : AppRoutes.employeeRegistration
                                      : AppRoutes.employeeRegistration,
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
                          child: const Text('Daftar sekarang', style: TextStyle(fontWeight: FontWeight.w700)),
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
