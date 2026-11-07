import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/main_navigation.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isOwner = context.watch<AuthBloc>().state.isOwner;
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal')),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 56,
                  color: GawenColors.muted,
                ),
                SizedBox(height: 16),
                Text(
                  'Fitur jadwal belum tersedia',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'Belum ada API jadwal yang dapat digunakan. Informasi jadwal akan tampil setelah fitur tersedia.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: GawenColors.muted, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: MainNavigation(
        isOwner: isOwner,
        currentPath: AppRoutes.schedule,
      ),
    );
  }
}
