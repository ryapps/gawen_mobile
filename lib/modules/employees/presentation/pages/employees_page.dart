import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/gawen_widgets.dart';
import 'package:frontend/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/modules/employees/presentation/bloc/employee_bloc.dart';
import 'package:frontend/modules/employees/domain/entities/join_request_entity.dart';
import 'package:frontend/modules/employees/domain/entities/membership_entity.dart';
import 'package:frontend/modules/invitation/domain/entities/invitation_entity.dart';
import 'package:frontend/modules/home/widgets/main_navigation.dart';
import 'package:go_router/go_router.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    final id = context.read<AuthBloc>().state.organizationId;
    if (id != null) {
      context.read<EmployeeBloc>().add(EmployeeDataRequested(id));
    }
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (!auth.isOwner) return const _EmployeeAccessDenied();
    return BlocConsumer<EmployeeBloc, EmployeeState>(
      listenWhen: (previous, current) =>
          previous.message != current.message && current.message != null,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message!)));
      },
      builder: (context, state) {
        final employees = state.members
            .where((member) {
              if (member.role != MembershipRole.employee) return false;
              final name = member.user?.name;
              final email = member.user?.email;
              return _query.isEmpty ||
                  (name != null && name.toLowerCase().contains(_query)) ||
                  (email != null && email.toLowerCase().contains(_query));
            })
            .toList(growable: false);
        final loading = state.status == EmployeeStatus.loading;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Karyawan'),
            actions: [
              IconButton(
                tooltip: 'Muat ulang',
                onPressed: loading ? null : _reload,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                _reload();
                await context.read<EmployeeBloc>().stream.firstWhere(
                  (next) => next.status != EmployeeStatus.loading,
                );
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  const ScreenIntro(
                    title: 'Kelola Karyawan',
                    description:
                        'Lihat anggota dan proses permintaan bergabung ke usahamu.',
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.inviteEmployee),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Undang Karyawan'),
                  ),
                  if (state.status == EmployeeStatus.failure)
                    _RetryMessage(
                      message: state.message ?? 'Data karyawan gagal dimuat.',
                      onRetry: _reload,
                    ),
                  if (loading && state.members.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    const SizedBox(height: 24),
                    _SectionHeading(
                      title: 'Permintaan bergabung',
                      count: state.pendingRequests.length,
                    ),
                    if (state.pendingRequests.isEmpty)
                      const _EmptyCard(
                        text: 'Tidak ada permintaan yang menunggu persetujuan.',
                      )
                    else
                      ...state.pendingRequests.map(
                        (request) => _JoinRequestCard(
                          request: request,
                          busy: state.status == EmployeeStatus.mutating,
                          onDecision: (approve) => _decide(request.id, approve),
                        ),
                      ),
                    const SizedBox(height: 24),
                    _SectionHeading(title: 'Anggota', count: employees.length),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Cari nama atau email',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    if (employees.isEmpty)
                      _EmptyCard(
                        text: state.members.isEmpty
                            ? 'Belum ada karyawan terdaftar.'
                            : 'Tidak ada hasil untuk pencarian ini.',
                      )
                    else
                      ...employees.map((member) => _MemberTile(member: member)),
                  ],
                ],
              ),
            ),
          ),
          bottomNavigationBar: MainNavigation(
            isOwner: true,
            currentPath: AppRoutes.employees,
          ),
        );
      },
    );
  }

  void _reload() {
    final id = context.read<AuthBloc>().state.organizationId;
    if (id != null) {
      context.read<EmployeeBloc>().add(EmployeeDataRequested(id));
    }
  }

  Future<void> _decide(String requestId, bool approve) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Setujui permintaan?' : 'Tolak permintaan?'),
        content: Text(
          approve
              ? 'Karyawan akan menjadi anggota aktif organisasi.'
              : 'Permintaan bergabung ini akan ditolak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(approve ? 'Setujui' : 'Tolak'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    final id = context.read<AuthBloc>().state.organizationId;
    if (id == null) return;
    context.read<EmployeeBloc>().add(
      JoinRequestDecisionRequested(
        organizationId: id,
        requestId: requestId,
        approve: approve,
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        if (count != null)
          Text(
            '$count',
            style: const TextStyle(
              color: GawenColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    ),
  );
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final MembershipEntity member;

  @override
  Widget build(BuildContext context) {
    final user = member.user;
    final name = user?.name ?? 'Karyawan';
    final email = user?.email ?? '';
    final initial = name.trim().isEmpty ? 'K' : name.trim()[0].toUpperCase();
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: GawenColors.primarySoft,
          foregroundColor: GawenColors.primaryDark,
          child: Text(initial),
        ),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(email, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRoutes.employeeDetail, extra: member.id),
      ),
    );
  }
}

class _JoinRequestCard extends StatelessWidget {
  const _JoinRequestCard({
    required this.request,
    required this.busy,
    required this.onDecision,
  });

  final JoinRequestEntity request;
  final bool busy;
  final ValueChanged<bool> onDecision;

  @override
  Widget build(BuildContext context) {
    final user = request.user;
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.name ?? 'Karyawan',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (user?.email != null)
              Text(
                user!.email,
                style: const TextStyle(color: GawenColors.muted, fontSize: 12),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : () => onDecision(false),
                    child: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: busy ? null : () => onDecision(true),
                    child: const Text('Setujui'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GawenColors.border),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(text, style: const TextStyle(color: GawenColors.muted)),
  );
}

class _RetryMessage extends StatelessWidget {
  const _RetryMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      RequestError(message: message),
      TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
    ],
  );
}

class _EmployeeAccessDenied extends StatelessWidget {
  const _EmployeeAccessDenied();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Text(
        'Daftar karyawan hanya dapat diakses oleh pemilik usaha.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class InviteEmployeePage extends StatefulWidget {
  const InviteEmployeePage({super.key});

  @override
  State<InviteEmployeePage> createState() => _InviteEmployeePageState();
}

class _InviteEmployeePageState extends State<InviteEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _shownInvitation = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (!auth.isOwner) return const _EmployeeAccessDenied();
    return BlocConsumer<EmployeeBloc, EmployeeState>(
      listenWhen: (previous, current) =>
          previous.status == EmployeeStatus.mutating &&
          (current.status == EmployeeStatus.failure ||
              current.status == EmployeeStatus.ready),
      listener: (context, state) {
        if (state.status == EmployeeStatus.failure && state.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        } else if (state.invitation != null && !_shownInvitation) {
          _shownInvitation = true;
          _showInvitationToken(state.invitation!);
        } else if (state.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) {
        final loading = state.status == EmployeeStatus.mutating;
        return Scaffold(
          appBar: AppBar(title: const Text('Undang Karyawan')),
          body: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              const ScreenIntro(
                title: 'Kirim undangan',
                description:
                    'Undangan dikaitkan dengan email penerima. Setelah menerima token, karyawan harus masuk menggunakan email tersebut.',
              ),
              if (state.status == EmployeeStatus.failure &&
                  state.message != null)
                RequestError(message: state.message!),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    GawenTextField(
                      controller: _emailController,
                      label: 'Email karyawan',
                      hint: 'nama@email.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty ||
                            email.length > 254 ||
                            !RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(email)) {
                          return 'Masukkan alamat email yang valid.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: loading
                            ? null
                            : () {
                                if (!_formKey.currentState!.validate()) return;
                                final id = auth.organizationId;
                                if (id == null) return;
                                _shownInvitation = false;
                                context.read<EmployeeBloc>().add(
                                  EmployeeInvitationRequested(
                                    organizationId: id,
                                    email: _emailController.text.trim(),
                                  ),
                                );
                              },
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Buat Undangan'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showInvitationToken(CreatedInvitation created) async {
    final token = created.token;
    if (token.isEmpty) return;
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
            SelectableText(token),
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
              await Clipboard.setData(ClipboardData(text: token));
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Salin token'),
          ),
          TextButton(
            onPressed: () async {
              final invitationId = created.invitation.id;
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
              final organizationId = context
                  .read<AuthBloc>()
                  .state
                  .organizationId;
              if (organizationId == null) return;
              context.read<EmployeeBloc>().add(
                EmployeeInvitationRevocationRequested(
                  organizationId: organizationId,
                  invitationId: invitationId,
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

class EmployeeDetailPage extends StatefulWidget {
  const EmployeeDetailPage({super.key, required this.membershipId});

  final String membershipId;

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  @override
  void initState() {
    super.initState();
    final id = context.read<AuthBloc>().state.organizationId;
    if (id != null) {
      context.read<EmployeeBloc>().add(
        EmployeeDetailRequested(
          organizationId: id,
          membershipId: widget.membershipId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!context.watch<AuthBloc>().state.isOwner) {
      return const _EmployeeAccessDenied();
    }
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        final member = state.selectedMember;
        final user = member?.user;
        return Scaffold(
          appBar: AppBar(title: const Text('Detail Karyawan')),
          body: state.status == EmployeeStatus.loading && member == null
              ? const Center(child: CircularProgressIndicator())
              : state.status == EmployeeStatus.failure && member == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: RequestError(
                      message: state.message ?? 'Karyawan tidak ditemukan.',
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(22),
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: GawenColors.primarySoft,
                      child: Text(
                        (user?.name ?? 'K').characters.first.toUpperCase(),
                        style: const TextStyle(
                          color: GawenColors.primaryDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'Karyawan',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ListTile(
                      leading: const Icon(Icons.mail_outline),
                      title: const Text('Email'),
                      subtitle: Text(user?.email ?? '-'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: const Text('Telepon'),
                      subtitle: Text(user?.phone ?? 'Belum diisi'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('Role'),
                      subtitle: Text(
                        member?.role == MembershipRole.owner
                            ? 'OWNER'
                            : member?.role == MembershipRole.employee
                            ? 'EMPLOYEE'
                            : '-',
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
