import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_bar.dart';
import 'package:frontend/core/widgets/gawen_widgets.dart';
import 'package:frontend/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/modules/invitation/domain/entities/invitation_entity.dart';
import 'package:frontend/modules/invitation/presentation/bloc/invitation_bloc.dart';
import 'package:frontend/modules/invitation/presentation/widgets/join_code_card.dart';
import 'package:frontend/modules/organization/presentation/bloc/organization_bloc.dart';
import 'package:share_plus/share_plus.dart';

class InviteEmployeePage extends StatefulWidget {
  const InviteEmployeePage({super.key});

  @override
  State<InviteEmployeePage> createState() => _InviteEmployeePageState();
}

class _InviteEmployeePageState extends State<InviteEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final organizationId = context.read<AuthBloc>().state.organizationId;
      if (organizationId == null) return;
      context.read<OrganizationBloc>().add(
        BusinessJoinCodeRequested(organizationId),
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = context.select((AuthBloc bloc) => bloc.state.isOwner);
    if (!isOwner) return const _InviteAccessDenied();
    return MultiBlocListener(
      listeners: [
        BlocListener<OrganizationBloc, OrganizationState>(
          listenWhen: (previous, current) =>
              previous.businessJoinCodeMessage !=
                  current.businessJoinCodeMessage &&
              current.businessJoinCodeMessage != null,
          listener: (context, state) =>
              _showMessage(state.businessJoinCodeMessage!),
        ),
        BlocListener<InvitationBloc, InvitationState>(
          listenWhen: (previous, current) =>
              previous.createdInvitation?.invitation.id !=
                  current.createdInvitation?.invitation.id &&
              current.createdInvitation != null,
          listener: (context, state) =>
              _showEmailInvitation(state.createdInvitation!),
        ),
      ],
      child: Scaffold(
        appBar: CustomAppBar(title: 'Undang Karyawan', isLeadingEnabled:true),
        body: SafeArea(
          child: BlocBuilder<OrganizationBloc, OrganizationState>(
            builder: (context, organizationState) {
              final organizationId = context
                  .read<AuthBloc>()
                  .state
                  .organizationId;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                children: [
                  JoinCodeCard(
                    code:
                        organizationState.businessJoinCodeOrganizationId ==
                            organizationId
                        ? organizationState.businessJoinCode
                        : null,
                    loading:
                        organizationState.businessJoinCodeStatus ==
                            BusinessJoinCodeStatus.initial ||
                        organizationState.businessJoinCodeStatus ==
                            BusinessJoinCodeStatus.loading,
                    rotating:
                        organizationState.businessJoinCodeStatus ==
                        BusinessJoinCodeStatus.rotating,
                    message: organizationState.businessJoinCodeMessage,
                    onRetry: _loadBusinessCode,
                    onCopy: _copyBusinessCode,
                    onShare: _shareBusinessCode,
                    onGenerate: _confirmCodeRotation,
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<InvitationBloc, InvitationState>(
                    builder: (context, invitationState) =>
                        _EmailInvitationSection(
                          formKey: _formKey,
                          controller: _emailController,
                          state: invitationState,
                          onSubmit: _createEmailInvitation,
                        ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _loadBusinessCode() {
    final organizationId = context.read<AuthBloc>().state.organizationId;
    if (organizationId != null) {
      context.read<OrganizationBloc>().add(
        BusinessJoinCodeRequested(organizationId),
      );
    }
  }

  Future<void> _confirmCodeRotation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Generate kode baru?'),
        content: const Text(
          'Kode lama tidak akan dapat digunakan lagi. Karyawan yang belum mengirim permintaan perlu menggunakan kode baru.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final organizationId = context.read<AuthBloc>().state.organizationId;
    if (organizationId != null) {
      context.read<OrganizationBloc>().add(
        BusinessJoinCodeRotationRequested(organizationId),
      );
    }
  }

  String? get _businessCode {
    final state = context.read<OrganizationBloc>().state;
    final organizationId = context.read<AuthBloc>().state.organizationId;
    if (state.businessJoinCodeOrganizationId != organizationId) return null;
    return state.businessJoinCode;
  }

  Future<void> _copyBusinessCode() async {
    final code = _businessCode;
    if (code == null) return;
    try {
      await Clipboard.setData(ClipboardData(text: code));
      if (mounted) _showMessage('Kode bergabung disalin.');
    } on PlatformException {
      if (mounted) {
        _showMessage('Kode tidak dapat disalin. Silakan salin manual.');
      }
    }
  }

  Future<void> _shareBusinessCode() async {
    final code = _businessCode;
    if (code == null) return;
    try {
      await SharePlus.instance.share(
        ShareParams(
          text:
              'Gunakan kode $code untuk mengajukan permintaan bergabung di Gawen.',
        ),
      );
    } on PlatformException {
      if (mounted) _showMessage('Kode tidak dapat dibagikan saat ini.');
    }
  }

  void _createEmailInvitation() {
    if (!_formKey.currentState!.validate()) return;
    final organizationId = context.read<AuthBloc>().state.organizationId;
    if (organizationId == null) return;
    context.read<InvitationBloc>().add(
      EmailInvitationCreatedRequested(
        organizationId: organizationId,
        email: _emailController.text.trim(),
      ),
    );
  }

  Future<void> _showEmailInvitation(CreatedInvitation created) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Undangan berhasil dibuat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bagikan token ini kepada karyawan melalui kanal yang aman. Token hanya ditampilkan pada respons pembuatan undangan.',
            ),
            const SizedBox(height: 12),
            SelectableText(created.token),
            const SizedBox(height: 10),
            Text(
              'Berlaku sampai ${created.invitation.expiresAt}',
              style: const TextStyle(color: GawenColors.muted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await Clipboard.setData(ClipboardData(text: created.token));
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (mounted) _showMessage('Token undangan disalin.');
              } on PlatformException {
                if (mounted) _showMessage('Token tidak dapat disalin.');
              }
            },
            child: const Text('Salin token'),
          ),
          TextButton(
            onPressed: () async {
              final organizationId = context
                  .read<AuthBloc>()
                  .state
                  .organizationId;
              if (organizationId == null) return;
              final shouldRevoke = await showDialog<bool>(
                context: context,
                builder: (confirmContext) => AlertDialog(
                  title: const Text('Cabut undangan?'),
                  content: const Text(
                    'Token ini tidak dapat digunakan setelah dicabut.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(confirmContext, false),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(confirmContext, true),
                      child: const Text('Cabut'),
                    ),
                  ],
                ),
              );
              if (shouldRevoke != true || !mounted) return;
              context.read<InvitationBloc>().add(
                EmailInvitationRevokedRequested(
                  organizationId: organizationId,
                  invitationId: created.invitation.id,
                ),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Cabut undangan'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _EmailInvitationSection extends StatelessWidget {
  const _EmailInvitationSection({
    required this.formKey,
    required this.controller,
    required this.state,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final InvitationState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Card(
    child: ExpansionTile(
      leading: const Icon(Icons.mail_outline),
      title: const Text(
        'Undang lewat email',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: const Text('Buat undangan khusus untuk satu alamat email.'),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        if (state.emailInvitationStatus == EmailInvitationStatus.failure)
          RequestError(
            message: state.emailInvitationMessage ?? 'Undangan gagal dibuat.',
          ),
        Form(
          key: formKey,
          child: GawenTextField(
            controller: controller,
            label: 'Email karyawan',
            hint: 'nama@email.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty ||
                  email.length > 254 ||
                  !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return 'Masukkan alamat email yang valid.';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed:
                state.emailInvitationStatus == EmailInvitationStatus.mutating
                ? null
                : onSubmit,
            child: state.emailInvitationStatus == EmailInvitationStatus.mutating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Buat Undangan Email'),
          ),
        ),
      ],
    ),
  );
}

class _InviteAccessDenied extends StatelessWidget {
  const _InviteAccessDenied();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Text(
        'Undangan karyawan hanya dapat dikelola oleh pemilik usaha.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}
