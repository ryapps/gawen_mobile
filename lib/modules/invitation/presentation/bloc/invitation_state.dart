import '../../domain/entities/invitation_entity.dart';
import '../../domain/entities/join_request_entity.dart';

enum InvitationStatus { initial, loading, ready, submitted, accepted, failure }

enum OwnerJoinRequestsStatus { initial, loading, ready, mutating, failure }

enum EmailInvitationStatus { initial, mutating, ready, failure }

enum InvitationInboxStatus {
  initial,
  loading,
  ready,
  mutating,
  accepted,
  failure,
}

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
    this.invitationInboxStatus = InvitationInboxStatus.initial,
    this.ownInvitations = const [],
    this.invitationInboxMessage,
    this.acceptingInvitationId,
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
  final InvitationInboxStatus invitationInboxStatus;
  final List<InvitationEntity> ownInvitations;
  final String? invitationInboxMessage;
  final String? acceptingInvitationId;

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
    InvitationInboxStatus? invitationInboxStatus,
    List<InvitationEntity>? ownInvitations,
    String? invitationInboxMessage,
    String? acceptingInvitationId,
    bool clearAcceptingInvitation = false,
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
    invitationInboxStatus: invitationInboxStatus ?? this.invitationInboxStatus,
    ownInvitations: ownInvitations ?? this.ownInvitations,
    invitationInboxMessage: invitationInboxMessage,
    acceptingInvitationId: clearAcceptingInvitation
        ? null
        : acceptingInvitationId ?? this.acceptingInvitationId,
  );
}
