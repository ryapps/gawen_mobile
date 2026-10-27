abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const welcome = '/welcome';
  static const login = '/login';
  static const ownerRegistration = '/register/owner';
  static const employeeRegistration = '/register/employee';
  static const home = '/home';
  static const join = '/join';
  static const requests = '/requests';
  static const pending = '/pending';
  static const invitation = '/invitation';
}

String? safeAuthReturnPath(String? path) => switch (path) {
  AppRoutes.home ||
  AppRoutes.join ||
  AppRoutes.requests ||
  AppRoutes.pending => path,
  _ => null,
};

class InvitationLoginIntent {
  const InvitationLoginIntent(this.token);

  final String token;
}
