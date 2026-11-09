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
  static const employeeDetail = '/employees/:employeeId';
  static const employeeEdit = '/employees/:employeeId/edit';
  static const inviteEmployee = '/employees/invite';
  static const ownerJoinRequests = '/join-requests';
  static const ownerJoinRequestDetail = '/join-requests/:requestId';
  static const organization = '/organization';
  static const organizationSetup = '/organization/setup';
  static const editOrganization = '/organization/edit';
  static const schedule = '/schedule';
  static const more = '/more';
  static const editProfile = '/profile/edit';
  static const team = '/team';
  static const permission = '/permission';

  static String employeeDetailPath(String employeeId) =>
      '/employees/${Uri.encodeComponent(employeeId)}';
  static String employeeEditPath(String employeeId) =>
      '${employeeDetailPath(employeeId)}/edit';
  static String ownerJoinRequestDetailPath(String requestId) =>
      '/join-requests/${Uri.encodeComponent(requestId)}';
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
