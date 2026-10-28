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
  static const employees = '/employees';
  static const employeeDetail = '/employees/detail';
  static const inviteEmployee = '/employees/invite';
  static const organization = '/organization';
  static const organizationSetup = '/organization/setup';
  static const editOrganization = '/organization/edit';
  static const schedule = '/schedule';
  static const more = '/more';
  static const team = '/team';
  static const permission = '/permission';
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
