import '../../domain/entities/organization_entity.dart';

enum OrganizationStatus { initial, loading, ready, saving, failure }

class OrganizationState {
  const OrganizationState({
    this.status = OrganizationStatus.initial,
    this.organization,
    this.message,
  });

  final OrganizationStatus status;
  final OrganizationEntity? organization;
  final String? message;

  OrganizationState copyWith({
    OrganizationStatus? status,
    OrganizationEntity? organization,
    String? message,
  }) => OrganizationState(
    status: status ?? this.status,
    organization: organization ?? this.organization,
    message: message,
  );
}
