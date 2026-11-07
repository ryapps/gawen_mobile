import '../../domain/entities/membership_access.dart';
import '../../domain/entities/user_entity.dart';
import '../../../employees/domain/entities/join_request_entity.dart';
import '../../../employees/domain/entities/membership_entity.dart';

export '../../domain/entities/membership_access.dart';

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
    this.memberships = const [],
    this.message,
    this.membershipAccess = MembershipAccess.none,
    this.pendingRequest,
  });

  final AuthStatus status;
  final UserEntity? user;
  final List<MembershipEntity> memberships;
  final String? message;
  final MembershipAccess membershipAccess;
  final JoinRequestEntity? pendingRequest;

  bool get hasVerifiedSession =>
      status == AuthStatus.authenticated ||
      ((status == AuthStatus.loading || status == AuthStatus.failure) &&
          user != null);

  MembershipEntity? get activeMembership {
    if (membershipAccess != MembershipAccess.active) return null;
    for (final membership in memberships) {
      if (membership.organization != null) return membership;
    }
    return null;
  }

  bool get isOwner {
    final membership = activeMembership;
    return membership?.role == MembershipRole.owner;
  }

  bool get requiresOrganizationSetup =>
      isOwner && activeMembership?.organization?.isSetupComplete != true;

  String? get organizationId {
    final membership = activeMembership;
    return membership?.organization?.id ?? membership?.organizationId;
  }

  String get userName => user?.name ?? 'Pengguna';
  String get userEmail => user?.email ?? '';

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    List<MembershipEntity>? memberships,
    String? message,
    MembershipAccess? membershipAccess,
    JoinRequestEntity? pendingRequest,
    bool clearMessage = false,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    memberships: memberships ?? this.memberships,
    message: clearMessage ? null : message ?? this.message,
    membershipAccess: membershipAccess ?? this.membershipAccess,
    pendingRequest: pendingRequest ?? this.pendingRequest,
  );
}
