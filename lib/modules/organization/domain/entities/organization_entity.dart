import 'organization_business_type.dart';
import '../../../regions/domain/entities/administrative_region.dart';

class OrganizationEntity {
  const OrganizationEntity({
    required this.id,
    required this.name,
    required this.timezone,
    this.businessType,
    this.description,
    this.logoUrl,
    this.email,
    this.phone,
    this.website,
    this.address,
    this.city,
    this.province,
    this.provinceCode,
    this.provinceName,
    this.regencyCode,
    this.regencyName,
    this.districtCode,
    this.districtName,
    this.villageCode,
    this.villageName,
    this.postalCode,
    this.currency,
    this.setupCompletedAt,
    this.setupStep = 0,
    this.memberCount,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String timezone;
  final OrganizationBusinessType? businessType;
  final String? description;
  final String? logoUrl;
  final String? email;
  final String? phone;
  final String? website;
  final String? address;
  final String? city;
  final String? province;
  final String? provinceCode;
  final String? provinceName;
  final String? regencyCode;
  final String? regencyName;
  final String? districtCode;
  final String? districtName;
  final String? villageCode;
  final String? villageName;
  final String? postalCode;
  final String? currency;
  final DateTime? setupCompletedAt;
  final int setupStep;
  final int? memberCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isSetupComplete => setupCompletedAt != null && businessType != null;

  AdministrativeRegion? get provinceRegion =>
      _region(provinceCode, provinceName);
  AdministrativeRegion? get regencyRegion => _region(regencyCode, regencyName);
  AdministrativeRegion? get districtRegion =>
      _region(districtCode, districtName);
  AdministrativeRegion? get villageRegion => _region(villageCode, villageName);
}

AdministrativeRegion? _region(String? code, String? name) =>
    code == null || name == null
    ? null
    : AdministrativeRegion(id: code, name: name);
