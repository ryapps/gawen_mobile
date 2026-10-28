import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/gawen_widgets.dart';
import 'package:frontend/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/modules/invitation/presentation/bloc/invitation_bloc.dart';
import 'package:go_router/go_router.dart';

class JoinOrganizationPage extends StatefulWidget {
  const JoinOrganizationPage({super.key});

  @override
  State<JoinOrganizationPage> createState() => _JoinOrganizationPageState();
}

class _JoinOrganizationPageState extends State<JoinOrganizationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<InvitationBloc>().add(
      BusinessCodeSubmitted(_codeController.text),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<InvitationBloc, InvitationState>(
    listenWhen: (previous, current) =>
        previous.status != current.status &&
        (current.status == InvitationStatus.submitted ||
            current.status == InvitationStatus.accepted),
    listener: (context, state) {
      if (state.status == InvitationStatus.submitted) {
        context.read<AuthBloc>().add(const SessionRestoreRequested());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message ?? 'Permintaan telah diperiksa.'),
          ),
        );
        context.go(AppRoutes.requests);
      }
    },
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
                const PageHeader(),
                const SizedBox(height: 24),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: GawenColors.primarySoft,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.work_outline_rounded,
                    color: GawenColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                const ScreenIntro(
                  title: 'Gabung ke Tempat Kerja',
                  description:
                      'Masukkan kode bisnis 8 karakter yang diberikan pemilik usaha.',
                ),
                if (!authenticated)
                  RequestError(
                    message:
                        'Masuk ke akun karyawan terlebih dahulu untuk mengajukan permintaan bergabung.',
                  ),
                if (state.status == InvitationStatus.failure &&
                    state.message != null)
                  RequestError(message: state.message!),
                Form(
                  key: _formKey,
                  child: GawenTextField(
                    controller: _codeController,
                    label: 'Kode bisnis',
                    hint: 'CONTOH: KOPI2024',
                    icon: Icons.key_outlined,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    maxLength: 8,
                    validator: (value) {
                      final code = value?.trim() ?? '';
                      if (!RegExp(r'^[A-Za-z0-9]{8}$').hasMatch(code)) {
                        return 'Masukkan kode 8 huruf atau angka.';
                      }
                      return null;
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Kode biasanya terdiri dari 8 huruf atau angka.',
                    style: TextStyle(color: GawenColors.muted, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: loading || !authenticated ? null : _submit,
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Lanjutkan'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: GawenColors.border)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'atau',
                          style: TextStyle(
                            color: GawenColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: GawenColors.border)),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.invitation),
                    icon: const Icon(Icons.mail_outline),
                    label: const Text('Terima Undangan'),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.login),
                    child: const Text('Sudah punya akun? Masuk'),
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
