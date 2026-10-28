import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/app_bar.dart';
import 'package:frontend/modules/home/widgets/more_menu.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/main_navigation.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final organizationName =
        auth.activeMembership?.organization?.name ?? 'Informasi tempat kerja';
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Lainnya',
        subtitle: 'Profil & pengaturan akun',
        action: IconButton(
          icon: const Icon(CupertinoIcons.gear_solid),
          onPressed: () => {},
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.5, 1.0],
                colors: [
                  GawenColors.primary,
                  GawenColors.primary.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Image.asset('assets/icons/avatar.png', width: 50, height: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: GawenColors.primarySoft,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        auth.userEmail,
                        style: const TextStyle(
                          fontSize: 14,
                          color: GawenColors.primarySoft,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Image.asset(
                      'assets/icons/edit-user.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: GawenColors.primarySoft,
                    foregroundColor: GawenColors.text,
                    padding: const EdgeInsets.all(10),
                    shape: CircleBorder(eccentricity: 0.5),
                  ),
                  onPressed: () => {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          MoreMenu(
            title: 'Keamanan Akun',
            icon: Icon(CupertinoIcons.shield, color: GawenColors.primary),
            subtitle: 'Lindungi akun Anda',
            onTap: () => {},
          ),

          const SizedBox(height: 20),

          MoreMenu(
            title: 'Informasi Perusahaan',
            icon: Image.asset(
              'assets/icons/building.png',
              width: 24,
              height: 24,
              color: GawenColors.primary,
            ),
            subtitle: 'Lihat detail perusahaan',
            onTap: () => context.push(AppRoutes.organization),
          ),

          const SizedBox(height: 20),

          MoreMenu(
            title: 'Notifikasi',
            icon: Icon(CupertinoIcons.bell, color: GawenColors.primary),
            subtitle: 'Kelola notifikasi aplikasi',
            onTap: () => {},
          ),

          const SizedBox(height: 20),

          MoreMenu(
            title: 'Bantuan & Dukungan',
            icon: Icon(
              CupertinoIcons.question_circle,
              color: GawenColors.primary,
            ),
            subtitle: 'Pusat bantuan dan dukungan',
            onTap: () => {},
          ),

          const SizedBox(height: 20),

          MoreMenu(
            title: 'Tentang Aplikasi',
            icon: Icon(CupertinoIcons.info, color: GawenColors.primary),
            subtitle: 'Informasi versi dan pembaruan',
            onTap: () => {},
          ),

          const SizedBox(height: 20),

          MoreMenu(
            title: 'Keluar Akun',
            icon: Icon(
              CupertinoIcons.arrow_turn_up_right,
              color: GawenColors.error,
            ),
            subtitle: 'Log out dari aplikasi',
            onTap: () => context.read<AuthBloc>().add(const LogoutRequested()),
          ),
        ],
      ),
      bottomNavigationBar: MainNavigation(
        isOwner: auth.isOwner,
        currentPath: AppRoutes.more,
      ),
    );
  }
}
