import '../../domain/entities/invitation_entity.dart';
import '../../domain/entities/join_request_entity.dart';

enum InvitationStatus { initial, loading, ready, submitted, accepted, failure }

enum OwnerJoinRequestsStatus { initial, loading, ready, mutating, failure }

enum EmailInvitationStatus { initial, mutating, ready, failure }

class InvitationState {
  const InvitationState({
    this.status = InvitationStatus.initial,
    this.requests = const [],
    this.message,
    this.ownerRequestsStatus = OwnerJoinRequestsStatus.initial,
    this.ownerRequests = const [],
    this.ownerRequestsMessage,
    this.emailInvitationStatus = EmailInvitationStatus.initial,
    this.createdInvitation,
    this.emailInvitationMessage,
  });

  final InvitationStatus status;
  final List<JoinRequestEntity> requests;
  final String? message;
  final OwnerJoinRequestsStatus ownerRequestsStatus;
  final List<JoinRequestEntity> ownerRequests;
  final String? ownerRequestsMessage;
  final EmailInvitationStatus emailInvitationStatus;
  final CreatedInvitation? createdInvitation;
  final String? emailInvitationMessage;

  InvitationState copyWith({
    InvitationStatus? status,
    List<JoinRequestEntity>? requests,
    String? message,
    OwnerJoinRequestsStatus? ownerRequestsStatus,
    List<JoinRequestEntity>? ownerRequests,
    String? ownerRequestsMessage,
    EmailInvitationStatus? emailInvitationStatus,
    CreatedInvitation? createdInvitation,
    String? emailInvitationMessage,
    bool clearCreatedInvitation = false,
  }) => InvitationState(
    status: status ?? this.status,
    requests: requests ?? this.requests,
    message: message,
    ownerRequestsStatus: ownerRequestsStatus ?? this.ownerRequestsStatus,
    ownerRequests: ownerRequests ?? this.ownerRequests,
    ownerRequestsMessage: ownerRequestsMessage,
    emailInvitationStatus: emailInvitationStatus ?? this.emailInvitationStatus,
    createdInvitation: clearCreatedInvitation
        ? null
        : createdInvitation ?? this.createdInvitation,
    emailInvitationMessage: emailInvitationMessage,
  );
}
