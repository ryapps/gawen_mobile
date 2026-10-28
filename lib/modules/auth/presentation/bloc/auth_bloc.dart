import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_failure.dart';
import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

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
          memberships: session.memberships,
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
            memberships: state.memberships,
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
          memberships: session.memberships,
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
