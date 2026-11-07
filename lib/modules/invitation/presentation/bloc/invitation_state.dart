import '../../../employees/domain/entities/join_request_entity.dart';

enum InvitationStatus { initial, loading, ready, submitted, accepted, failure }

class InvitationState {
  const InvitationState({
    this.status = InvitationStatus.initial,
    this.requests = const [],
    this.message,
  });

  final InvitationStatus status;
  final List<JoinRequestEntity> requests;
  final String? message;

  InvitationState copyWith({
    InvitationStatus? status,
    List<JoinRequestEntity>? requests,
    String? message,
  }) => InvitationState(
    status: status ?? this.status,
    requests: requests ?? this.requests,
    message: message,
  );
}
