import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gawen_widgets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 350,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 350,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [GawenColors.primarySoft, GawenColors.background],
                    ),
                  ),
                ),

                // Logo tetap memperhatikan status bar
                Positioned(
                  left: 24,
                  top: MediaQuery.of(context).padding.top + 20,
                  child: const GawenLogo(),
                ),

                const Positioned(
                  top: 100,
                  child: TeamIllustration(compact: true),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TEMAN KERJA UMKM',
                  style: TextStyle(
                    color: GawenColors.primary,
                    fontSize: 10,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Selamat datang di Gawen',
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.25,
                    letterSpacing: -.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kelola tim kerja lebih mudah, mulai dari sini.',
                  style: TextStyle(color: GawenColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.push(AppRoutes.login),
                    child: const Text('Masuk'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.push(AppRoutes.ownerRegistration),
                    child: const Text('Daftar Pemilik Usaha'),
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: GawenColors.primarySoft,
                    foregroundColor: GawenColors.primary,
                    child: Icon(Icons.groups_outlined),
                  ),
                  title: const Text(
                    'Gabung sebagai Karyawan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Buat akun dan hubungkan tempat kerjamu',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.employeeRegistration),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
