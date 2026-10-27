import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_failure.dart';
import '../../data/auth_repository.dart';

export '../../data/auth_repository.dart' show MembershipAccess;

enum AuthStatus {
  initial,
  restoring,
  loading,
  unauthenticated,
  authenticated,
  registered,
  failure,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.message,
    this.membershipAccess = MembershipAccess.none,
    this.pendingRequest,
  });

  final AuthStatus status;
  final Map<String, dynamic>? user;
  final String? message;
  final MembershipAccess membershipAccess;
  final Map<String, dynamic>? pendingRequest;

  bool get hasVerifiedSession =>
      status == AuthStatus.authenticated ||
      ((status == AuthStatus.loading || status == AuthStatus.failure) &&
          user != null);

  AuthState copyWith({
    AuthStatus? status,
    Map<String, dynamic>? user,
    String? message,
    MembershipAccess? membershipAccess,
    Map<String, dynamic>? pendingRequest,
    bool clearMessage = false,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    message: clearMessage ? null : message ?? this.message,
    membershipAccess: membershipAccess ?? this.membershipAccess,
    pendingRequest: pendingRequest ?? this.pendingRequest,
  );
}

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

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthState()) {
    on<SessionRestoreRequested>(_restore);
    on<LoginSubmitted>(_login);
    on<OwnerRegistrationSubmitted>(_registerOwner);
    on<EmployeeRegistrationSubmitted>(_registerEmployee);
    on<LogoutRequested>(_logout);
  }

  final AuthRepository _repository;

  Future<void> _restore(
    SessionRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.loading ||
        state.status == AuthStatus.restoring) {
      return;
    }
    final hasPreviousSession = state.user != null;
    emit(
      state.copyWith(
        status: hasPreviousSession ? AuthStatus.loading : AuthStatus.restoring,
        clearMessage: true,
      ),
    );
    try {
      final session = await _repository.restoreSession();
      if (session == null) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
        return;
      }
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: session.user,
          membershipAccess: session.access,
          pendingRequest: session.pendingRequest,
        ),
      );
    } on ApiFailure catch (error) {
      if (error is SessionExpiredFailure) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      } else {
        emit(
          AuthState(
            status: AuthStatus.failure,
            message: error.message,
            user: state.user,
            membershipAccess: state.membershipAccess,
            pendingRequest: state.pendingRequest,
          ),
        );
      }
    }
  }

  Future<void> _login(LoginSubmitted event, Emitter<AuthState> emit) async {
    if (state.status == AuthStatus.loading) return;
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    try {
      await _repository.login(email: event.email, password: event.password);
      final session = await _repository.restoreSession();
      if (session == null) {
        throw const ApiFailure(
          'Sesi tidak dapat dipulihkan. Silakan masuk lagi.',
        );
      }
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: session.user,
          membershipAccess: session.access,
          pendingRequest: session.pendingRequest,
        ),
      );
    } on ApiFailure catch (error) {
      emit(AuthState(status: AuthStatus.failure, message: error.message));
    }
  }

  Future<void> _registerOwner(
    OwnerRegistrationSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.loading) return;
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    try {
      await _repository.registerOwner(
        name: event.name,
        organizationName: event.organizationName,
        email: event.email,
        password: event.password,
      );
      emit(
        const AuthState(
          status: AuthStatus.registered,
          message:
              'Jika registrasi dapat diproses, akun telah dibuat. Silakan masuk.',
        ),
      );
    } on ApiFailure catch (error) {
      emit(AuthState(status: AuthStatus.failure, message: error.message));
    }
  }

  Future<void> _registerEmployee(
    EmployeeRegistrationSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.loading) return;
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    try {
      await _repository.registerEmployee(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(
        const AuthState(
          status: AuthStatus.registered,
          message:
              'Jika registrasi dapat diproses, akun telah dibuat. Silakan masuk untuk bergabung.',
        ),
      );
    } on ApiFailure catch (error) {
      emit(AuthState(status: AuthStatus.failure, message: error.message));
    }
  }

  Future<void> _logout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    try {
      await _repository.logout();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } on ApiFailure catch (error) {
      emit(
        AuthState(status: AuthStatus.unauthenticated, message: error.message),
      );
    }
  }
}
