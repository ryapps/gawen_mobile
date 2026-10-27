import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/modules/invitation/presentation/pages/accept_invitation_page.dart';
import 'package:frontend/modules/invitation/presentation/pages/join_organization_page.dart';
import 'package:frontend/modules/invitation/presentation/pages/join_request_page.dart';
import 'package:go_router/go_router.dart';

import '../../modules/auth/presentation/bloc/auth_bloc.dart';
import '../../modules/home/pages/home_page.dart';
import '../../modules/auth/presentation/pages/login_page.dart';
import '../../modules/auth/presentation/pages/onboarding/onboarding_page.dart';
import '../../modules/auth/presentation/pages/registration_page.dart';
import '../../modules/auth/presentation/pages/onboarding/splash_page.dart';
import '../../modules/auth/presentation/pages/welcome_page.dart';
import 'route_names.dart';

class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

String _landingPath(MembershipAccess access) => switch (access) {
  MembershipAccess.active => AppRoutes.home,
  MembershipAccess.pending => AppRoutes.pending,
  MembershipAccess.none => AppRoutes.join,
};

String? resolveAuthRedirect({
  required String location,
  required AuthState auth,
  String? returnTo,
  bool preserveInvitationLogin = false,
}) {
  const publicPaths = {
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.welcome,
    AppRoutes.login,
    AppRoutes.ownerRegistration,
    AppRoutes.employeeRegistration,
    AppRoutes.invitation,
  };
  final hasVerifiedSession = auth.hasVerifiedSession;
  final isRestoring =
      auth.status == AuthStatus.initial || auth.status == AuthStatus.restoring;

  if (location == AppRoutes.splash) {
    if (hasVerifiedSession) return _landingPath(auth.membershipAccess);
    return null;
  }

  if (isRestoring) return AppRoutes.splash;

  if (!hasVerifiedSession) {
    if (publicPaths.contains(location)) return null;
    return Uri(
      path: AppRoutes.login,
      queryParameters: {'from': location},
    ).toString();
  }

  if (location == AppRoutes.login && preserveInvitationLogin) return null;

  if (location == AppRoutes.pending) {
    return switch (auth.membershipAccess) {
      MembershipAccess.pending => null,
      MembershipAccess.active => AppRoutes.home,
      MembershipAccess.none => AppRoutes.join,
    };
  }

  if (location == AppRoutes.requests &&
      auth.membershipAccess == MembershipAccess.pending) {
    return AppRoutes.pending;
  }

  if (location == AppRoutes.home) {
    return switch (auth.membershipAccess) {
      MembershipAccess.active => null,
      MembershipAccess.pending => AppRoutes.pending,
      MembershipAccess.none => AppRoutes.join,
    };
  }

  if (location == AppRoutes.join || location == AppRoutes.requests) {
    return null;
  }

  if (publicPaths.contains(location) && location != AppRoutes.invitation) {
    if (location == AppRoutes.login && returnTo != null) {
      if (returnTo == AppRoutes.join || returnTo == AppRoutes.requests) {
        return returnTo;
      }
      if (returnTo == AppRoutes.home || returnTo == AppRoutes.pending) {
        return _landingPath(auth.membershipAccess);
      }
    }
    return _landingPath(auth.membershipAccess);
  }

  return null;
}

GoRouter createAppRouter(AuthBloc authBloc, AuthRouterRefresh refresh) =>
    GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: refresh,
      redirect: (context, state) => resolveAuthRedirect(
        location: state.uri.path,
        auth: authBloc.state,
        returnTo: state.uri.queryParameters['from'],
        preserveInvitationLogin: state.extra is InvitationLoginIntent,
      ),
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          name: 'onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          name: 'welcome',
          builder: (context, state) => const WelcomePage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) {
            final extra = state.extra;
            return LoginPage(
              returnTo: state.uri.queryParameters['from'],
              invitationToken: extra is InvitationLoginIntent
                  ? extra.token
                  : extra is String
                  ? extra
                  : null,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.ownerRegistration,
          name: 'owner-registration',
          builder: (context, state) => RegistrationPage(
            isOwner: true,
            invitationToken: state.extra is InvitationLoginIntent
                ? (state.extra! as InvitationLoginIntent).token
                : null,
          ),
        ),
        GoRoute(
          path: AppRoutes.employeeRegistration,
          name: 'employee-registration',
          builder: (context, state) => RegistrationPage(
            isOwner: false,
            invitationToken: state.extra is InvitationLoginIntent
                ? (state.extra! as InvitationLoginIntent).token
                : null,
          ),
        ),
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.join,
          name: 'join',
          builder: (context, state) => const JoinOrganizationPage(),
        ),
        GoRoute(
          path: AppRoutes.requests,
          name: 'requests',
          builder: (context, state) => const JoinRequestsPage(),
        ),
        GoRoute(
          path: AppRoutes.pending,
          name: 'pending',
          builder: (context, state) => const PendingApprovalPage(),
        ),
        GoRoute(
          path: AppRoutes.invitation,
          name: 'invitation',
          builder: (context, state) => AcceptInvitationPage(
            initialToken: state.extra is String ? state.extra as String : null,
          ),
        ),
      ],
      errorBuilder: (context, state) => RouteNotFoundPage(
        onReturn: () => authBloc.state.hasVerifiedSession
            ? _landingPath(authBloc.state.membershipAccess)
            : AppRoutes.welcome,
      ),
    );

class RouteNotFoundPage extends StatelessWidget {
  const RouteNotFoundPage({super.key, required this.onReturn});

  final String Function() onReturn;

  @override
  Widget build(context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Halaman tidak ditemukan.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => GoRouter.of(context).go(onReturn()),
            child: const Text('Kembali'),
          ),
        ],
      ),
    ),
  );
}
