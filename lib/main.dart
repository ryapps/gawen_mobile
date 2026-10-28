import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'modules/auth/data/auth_repository.dart';
import 'modules/auth/presentation/bloc/auth_bloc.dart';
import 'modules/employees/data/employee_repository.dart';
import 'modules/employees/presentation/bloc/employee_bloc.dart';
import 'modules/invitation/data/invitation_repository.dart';
import 'modules/invitation/presentation/bloc/invitation_bloc.dart';
import 'modules/organization/data/organization_repository.dart';
import 'modules/organization/presentation/bloc/organization_bloc.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthRepository())),
        BlocProvider(create: (_) => OrganizationBloc(OrganizationRepository())),
        BlocProvider(create: (_) => EmployeeBloc(EmployeeRepository())),
        BlocProvider(create: (_) => InvitationBloc(InvitationRepository())),
      ],
      child: const GawenApp(),
    ),
  );
}

class GawenApp extends StatefulWidget {
  const GawenApp({super.key});

  @override
  State<GawenApp> createState() => _GawenAppState();
}

class _GawenAppState extends State<GawenApp> {
  late final AuthRouterRefresh _routerRefresh;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authBloc = context.read<AuthBloc>();
    _routerRefresh = AuthRouterRefresh(authBloc);
    _router = createAppRouter(authBloc, _routerRefresh);
  }

  @override
  void dispose() {
    _router.dispose();
    _routerRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == AuthStatus.unauthenticated,
      listener: (context, state) {
        context.read<OrganizationBloc>().add(
          const OrganizationStateResetRequested(),
        );
        context.read<EmployeeBloc>().add(const EmployeeStateResetRequested());
      },
      child: MaterialApp.router(
        title: 'Gawen',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
