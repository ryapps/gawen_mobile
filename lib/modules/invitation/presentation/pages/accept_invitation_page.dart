import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/gawen_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/invitation_bloc.dart';

class AcceptInvitationPage extends StatefulWidget {
  const AcceptInvitationPage({super.key, this.initialToken});

  final String? initialToken;

  @override
  State<AcceptInvitationPage> createState() => _AcceptInvitationPageState();
}

class _AcceptInvitationPageState extends State<AcceptInvitationPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tokenController.text = widget.initialToken ?? '';
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (!context.read<AuthBloc>().state.hasVerifiedSession) {
      context.go(
        AppRoutes.login,
        extra: InvitationLoginIntent(_tokenController.text.trim()),
      );
      return;
    }
    context.read<InvitationBloc>().add(
      InvitationAccepted(_tokenController.text),
    );
  }

  Future<void> _restoreAfterAcceptance() async {
    final authBloc = context.read<AuthBloc>();
    if (authBloc.state.status == AuthStatus.loading ||
        authBloc.state.status == AuthStatus.restoring) {
      await authBloc.stream.firstWhere(
        (next) =>
            next.status != AuthStatus.loading &&
            next.status != AuthStatus.restoring,
      );
    }
    final loading = authBloc.stream.firstWhere(
      (next) =>
          next.status == AuthStatus.loading ||
          next.status == AuthStatus.restoring,
    );
    authBloc.add(const SessionRestoreRequested());
    await loading;
    final restored = await authBloc.stream.firstWhere(
      (next) =>
          next.status != AuthStatus.loading &&
          next.status != AuthStatus.restoring,
    );
    if (!mounted) return;
    if (restored.status == AuthStatus.authenticated &&
        restored.membershipAccess == MembershipAccess.active) {
      context.go(AppRoutes.home);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          restored.message ??
              'Undangan diterima, tetapi status keanggotaan belum dapat diverifikasi. Coba periksa kembali.',
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<InvitationBloc, InvitationState>(
    listenWhen: (previous, current) =>
        previous.status != current.status &&
        current.status == InvitationStatus.accepted,
    listener: (context, state) => unawaited(_restoreAfterAcceptance()),
    builder: (context, state) {
      final loading = state.status == InvitationStatus.loading;
      final authenticated = context.select(
        (AuthBloc bloc) => bloc.state.hasVerifiedSession,
      );
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Terima Undangan',
                  onBack: () => context.go(
                    authenticated ? AppRoutes.home : AppRoutes.welcome,
                  ),
                ),
                const SizedBox(height: 22),
                const ScreenIntro(
                  title: 'Undangan untukmu',
                  description:
                      'Tempel token undangan dari tautan yang diberikan pemilik usaha. Detail undangan akan dikonfirmasi oleh server saat diterima.',
                ),
                if (!authenticated)
                  RequestError(
                    message:
                        'Masuk dengan alamat email yang menerima undangan sebelum menerimanya.',
                  ),
                if (state.status == InvitationStatus.failure &&
                    state.message != null)
                  RequestError(message: state.message!),
                if (state.status == InvitationStatus.accepted)
                  const RequestError(
                    message:
                        'Undangan diterima. Sedang memverifikasi akses organisasi.',
                  ),
                Form(
                  key: _formKey,
                  child: GawenTextField(
                    controller: _tokenController,
                    label: 'Token undangan',
                    hint: 'Tempel token dari tautan undangan',
                    icon: Icons.mail_outline,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      final token = value?.trim() ?? '';
                      if (!RegExp(r'^[A-Za-z0-9_-]{43,64}$').hasMatch(token)) {
                        return 'Token undangan tidak sesuai format.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
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
                        : Text(
                            authenticated
                                ? 'Terima Undangan'
                                : 'Masuk dan lanjutkan',
                          ),
                  ),
                ),
                if (!authenticated)
                  Center(
                    child: TextButton(
                      onPressed: () => context.go(
                        AppRoutes.login,
                        extra: InvitationLoginIntent(
                          _tokenController.text.trim(),
                        ),
                      ),
                      child: const Text('Masuk ke akun'),
                    ),
                  ),
                if (!authenticated)
                  Center(
                    child: TextButton(
                      onPressed: () => context.push(
                        AppRoutes.employeeRegistration,
                        extra: InvitationLoginIntent(
                          _tokenController.text.trim(),
                        ),
                      ),
                      child: const Text('Buat akun karyawan'),
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
