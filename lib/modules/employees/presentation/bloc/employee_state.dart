import '../../domain/entities/join_request_entity.dart';
import '../../domain/entities/membership_entity.dart';
import '../../../invitation/domain/entities/invitation_entity.dart';

enum EmployeeStatus { initial, loading, ready, mutating, failure }

class EmployeeState {
  const EmployeeState({
    this.status = EmployeeStatus.initial,
    this.members = const [],
    this.pendingRequests = const [],
    this.invitation,
    this.selectedMember,
    this.message,
  });

  final EmployeeStatus status;
  final List<MembershipEntity> members;
  final List<JoinRequestEntity> pendingRequests;
  final CreatedInvitation? invitation;
  final MembershipEntity? selectedMember;
  final String? message;

  EmployeeState copyWith({
    EmployeeStatus? status,
    List<MembershipEntity>? members,
    List<JoinRequestEntity>? pendingRequests,
    CreatedInvitation? invitation,
    MembershipEntity? selectedMember,
    String? message,
    bool clearInvitation = false,
  }) => EmployeeState(
    status: status ?? this.status,
    members: members ?? this.members,
    pendingRequests: pendingRequests ?? this.pendingRequests,
    invitation: clearInvitation ? null : invitation ?? this.invitation,
    selectedMember: selectedMember ?? this.selectedMember,
    message: message,
  );
}
