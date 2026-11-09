import '../../domain/entities/organization_entity.dart';

enum OrganizationStatus { initial, loading, ready, saving, failure }

enum BusinessJoinCodeStatus { initial, loading, ready, rotating, failure }

class OrganizationState {
  const OrganizationState({
    this.status = OrganizationStatus.initial,
    this.organization,
    this.message,
    this.businessJoinCodeStatus = BusinessJoinCodeStatus.initial,
    this.businessJoinCode,
    this.businessJoinCodeOrganizationId,
    this.businessJoinCodeMessage,
  });

  final OrganizationStatus status;
  final OrganizationEntity? organization;
  final String? message;
  final BusinessJoinCodeStatus businessJoinCodeStatus;
  final String? businessJoinCode;
  final String? businessJoinCodeOrganizationId;
  final String? businessJoinCodeMessage;

  OrganizationState copyWith({
    OrganizationStatus? status,
    OrganizationEntity? organization,
    String? message,
    BusinessJoinCodeStatus? businessJoinCodeStatus,
    String? businessJoinCode,
    String? businessJoinCodeOrganizationId,
    String? businessJoinCodeMessage,
    bool clearBusinessJoinCode = false,
  }) => OrganizationState(
    status: status ?? this.status,
    organization: organization ?? this.organization,
    message: message,
    businessJoinCodeStatus:
        businessJoinCodeStatus ?? this.businessJoinCodeStatus,
    businessJoinCode: clearBusinessJoinCode
        ? null
        : businessJoinCode ?? this.businessJoinCode,
    businessJoinCodeOrganizationId:
        businessJoinCodeOrganizationId ?? this.businessJoinCodeOrganizationId,
    businessJoinCodeMessage: businessJoinCodeMessage,
  );
}
