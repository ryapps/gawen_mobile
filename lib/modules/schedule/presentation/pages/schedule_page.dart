import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/gawen_page.dart';
import 'package:frontend/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/core/widgets/main_navigation.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isOwner = context.watch<AuthBloc>().state.isOwner;
    return GawenPage(
      appBar: AppBar(title: const Text('Jadwal')),
      bottomNavigationBar: MainNavigation(
        isOwner: isOwner,
        currentPath: AppRoutes.schedule,
      ),
      child: const Center(
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
    );
  }
}
