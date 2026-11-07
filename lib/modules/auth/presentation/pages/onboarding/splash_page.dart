import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/gawen_widgets.dart';
import '../../bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const SessionRestoreRequested());
  }

  Future<void> _continue(AuthState state) async {
    if (state.status == AuthStatus.authenticated) {
      if (mounted) context.go(AppRoutes.home);
      return;
    }
    if (state.status != AuthStatus.unauthenticated) return;
    try {
      final hasCompleted = await ApiClient.hasCompletedOnboarding();
      if (!mounted) return;
      context.go(hasCompleted ? AppRoutes.welcome : AppRoutes.onboarding);
    } on PlatformException {
      if (!mounted) return;
      context.go(AppRoutes.welcome);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferensi onboarding tidak dapat dibaca.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
    listenWhen: (previous, current) =>
        previous.status != current.status &&
        (current.status == AuthStatus.authenticated ||
            current.status == AuthStatus.unauthenticated),
    listener: (context, state) => _continue(state),
    child: Scaffold(
      backgroundColor: GawenColors.primary,
      body: SafeArea(
        child: Center(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.status == AuthStatus.failure) {
                return Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const GawenLogo(light: true, large: true),
                      const SizedBox(height: 22),
                      Text(
                        state.message ?? 'Tidak dapat memeriksa status sesi.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () => context.read<AuthBloc>().add(
                          const SessionRestoreRequested(),
                        ),
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                );
              }
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GawenLogo(light: true, large: true),
                  SizedBox(height: 22),
                  Text(
                    'Kelola tim kerja lebih mudah.',
                    style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
                  ),
                  SizedBox(height: 38),
                  SizedBox(
                    width: 30,
                    height: 3,
                    child: LinearProgressIndicator(
                      backgroundColor: Color(0x66FFFFFF),
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
