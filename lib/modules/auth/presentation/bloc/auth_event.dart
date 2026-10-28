sealed class AuthEvent {
  const AuthEvent();
}

final class SessionRestoreRequested extends AuthEvent {
  const SessionRestoreRequested();
}

final class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;
}

final class OwnerRegistrationSubmitted extends AuthEvent {
  const OwnerRegistrationSubmitted({
    required this.name,
    required this.organizationName,
    required this.email,
    required this.password,
  });

  final String name;
  final String organizationName;
  final String email;
  final String password;
}

final class EmployeeRegistrationSubmitted extends AuthEvent {
  const EmployeeRegistrationSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;
}

final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
