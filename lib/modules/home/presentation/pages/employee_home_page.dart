import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gawen_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/home_action_card.dart';
import '../../../../core/widgets/main_navigation.dart';

class EmployeeHomePage extends StatelessWidget {
  const EmployeeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final organization = auth.activeMembership?.organization;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          children: [
            const GawenLogo(),
            const SizedBox(height: 28),
            const Text(
              'DASHBOARD KARYAWAN',
              style: TextStyle(
                color: GawenColors.primary,
                fontSize: 10,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Halo, ${auth.userName}',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              organization?.name ?? 'Tempat kerja terhubung',
              style: const TextStyle(color: GawenColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 22),
            _EmployeeSummary(
              organizationName: organization?.name ?? 'Tempat kerja',
            ),
            const SizedBox(height: 22),
            const Text(
              'Untukmu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            HomeActionCard(
              icon: Icons.storefront_outlined,
              title: 'Informasi tempat kerja',
              subtitle: 'Lihat informasi organisasi yang mengizinkan akses',
              onTap: () => context.go(AppRoutes.organization),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainNavigation(
        isOwner: false,
        currentPath: AppRoutes.home,
      ),
    );
  }
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
