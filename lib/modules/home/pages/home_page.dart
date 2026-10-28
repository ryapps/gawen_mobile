import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gawen_widgets.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../employees/presentation/bloc/employee_bloc.dart';
import '../../organization/presentation/bloc/organization_bloc.dart';
import '../widgets/main_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _loadedOrganizationId;
  String? _loadedEmployeeOrganizationId;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final organizationId = auth.organizationId;
    if (organizationId != null &&
        organizationId != _loadedOrganizationId &&
        auth.isOwner) {
      _loadedOrganizationId = organizationId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<OrganizationBloc>().add(
            OrganizationLoadRequested(organizationId),
          );
        }
      });
    }
    if (organizationId != null &&
        organizationId != _loadedEmployeeOrganizationId &&
        auth.isOwner) {
      _loadedEmployeeOrganizationId = organizationId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<EmployeeBloc>().add(
            EmployeeDataRequested(organizationId),
          );
        }
      });
    }

    final userName = auth.userName;
    final organizationFromProfile = auth.activeMembership?.organization;
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == AuthStatus.unauthenticated,
      listener: (context, state) {
        context.go(AppRoutes.welcome);
        if (state.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
            children: [
              const GawenLogo(),
              const SizedBox(height: 28),
              Text(
                auth.isOwner ? 'DASHBOARD PEMILIK' : 'DASHBOARD KARYAWAN',
                style: const TextStyle(
                  color: GawenColors.primary,
                  fontSize: 10,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Halo, $userName',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                organizationFromProfile?.name ?? 'Tempat kerja terhubung',
                style: const TextStyle(color: GawenColors.muted, fontSize: 14),
              ),
              const SizedBox(height: 22),
              if (auth.isOwner)
                BlocBuilder<OrganizationBloc, OrganizationState>(
                  builder: (context, state) {
                    final organization = state.organization;
                    final name =
                        organization?.name ??
                        organizationFromProfile?.name ??
                        'Usaha';
                    return _OwnerSummary(
                      organizationName: name,
                      memberCount: organization?.memberCount,
                      loading: state.status == OrganizationStatus.loading,
                      onRetry: () {
                        if (organizationId != null) {
                          context.read<OrganizationBloc>().add(
                            OrganizationLoadRequested(organizationId),
                          );
                        }
                      },
                    );
                  },
                )
              else
                _EmployeeSummary(
                  organizationName:
                      organizationFromProfile?.name ?? 'Tempat kerja',
                ),
              if (auth.isOwner) ...[
                const SizedBox(height: 12),
                BlocBuilder<EmployeeBloc, EmployeeState>(
                  builder: (context, employeeState) => _PendingSummary(
                    count: employeeState.pendingRequests.length,
                    loading: employeeState.status == EmployeeStatus.loading,
                    failed: employeeState.status == EmployeeStatus.failure,
                    onTap: () => context.go(AppRoutes.employees),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              if (auth.isOwner) ...[
                const Text(
                  'Akses cepat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.groups_outlined,
                  title: 'Karyawan',
                  subtitle: 'Kelola anggota dan permintaan bergabung',
                  onTap: () => context.go(AppRoutes.employees),
                ),
                _ActionCard(
                  icon: Icons.storefront_outlined,
                  title: 'Informasi usaha',
                  subtitle: 'Lihat atau ubah informasi organisasi',
                  onTap: () => context.go(AppRoutes.organization),
                ),
              ] else ...[
                const Text(
                  'Untukmu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.storefront_outlined,
                  title: 'Informasi tempat kerja',
                  subtitle: 'Lihat informasi organisasi yang mengizinkan akses',
                  onTap: () => context.go(AppRoutes.organization),
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: MainNavigation(
          isOwner: auth.isOwner,
          currentPath: AppRoutes.home,
        ),
      ),
    );
  }
}

class _OwnerSummary extends StatelessWidget {
  const _OwnerSummary({
    required this.organizationName,
    required this.memberCount,
    required this.loading,
    required this.onRetry,
  });

  final String organizationName;
  final int? memberCount;
  final bool loading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: GawenColors.primaryDark,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.storefront_outlined, color: Colors.white, size: 28),
        const SizedBox(height: 14),
        Text(
          organizationName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        if (memberCount != null)
          Text(
            '$memberCount anggota terdaftar',
            style: const TextStyle(color: Colors.white70),
          )
        else if (loading)
          const Text(
            'Memuat ringkasan organisasi…',
            style: TextStyle(color: Colors.white70),
          )
        else
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Muat ulang informasi usaha',
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    ),
  );
}

class _EmployeeSummary extends StatelessWidget {
  const _EmployeeSummary({required this.organizationName});

  final String organizationName;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GawenColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: GawenColors.primarySoft,
          foregroundColor: GawenColors.primary,
          child: Icon(Icons.work_outline),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tempat kerja',
                style: TextStyle(color: GawenColors.muted, fontSize: 12),
              ),
              Text(
                organizationName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PendingSummary extends StatelessWidget {
  const _PendingSummary({
    required this.count,
    required this.loading,
    required this.failed,
    required this.onTap,
  });

  final int count;
  final bool loading;
  final bool failed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFFFF5E4),
        foregroundColor: GawenColors.warning,
        child: Icon(Icons.pending_actions_outlined),
      ),
      title: const Text('Permintaan bergabung'),
      subtitle: Text(
        loading
            ? 'Memuat status…'
            : failed
            ? 'Status belum dapat dimuat'
            : '$count menunggu persetujuan',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: GawenColors.primarySoft,
        foregroundColor: GawenColors.primary,
        child: Icon(icon),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
