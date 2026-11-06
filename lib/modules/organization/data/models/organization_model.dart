import '../../domain/entities/organization_entity.dart';
import '../../domain/entities/organization_business_type.dart';

class OrganizationModel extends OrganizationEntity {
  const OrganizationModel({
    required super.id,
    required super.name,
    required super.timezone,
    super.businessType,
    super.description,
    super.logoUrl,
    super.email,
    super.phone,
    super.website,
    super.address,
    super.city,
    super.province,
    super.provinceCode,
    super.provinceName,
    super.regencyCode,
    super.regencyName,
    super.districtCode,
    super.districtName,
    super.villageCode,
    super.villageName,
    super.postalCode,
    super.currency,
    super.setupCompletedAt,
    super.setupStep,
    super.memberCount,
    super.createdAt,
    super.updatedAt,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final timezone = json['timezone'];
    final rawBusinessType = json['businessType'];
    final businessType = rawBusinessType == null
        ? null
        : OrganizationBusinessType.fromApiValue(rawBusinessType);
    final description = _nullableString(json, 'description');
    final logoUrl = _nullableString(json, 'logoUrl');
    final email = _nullableString(json, 'email');
    final phone = _nullableString(json, 'phone');
    final website = _nullableString(json, 'website');
    final address = _nullableString(json, 'address');
    final city = _nullableString(json, 'city');
    final province = _nullableString(json, 'province');
    final provinceCode = _nullableString(json, 'provinceCode');
    final provinceName = _nullableString(json, 'provinceName');
    final regencyCode = _nullableString(json, 'regencyCode');
    final regencyName = _nullableString(json, 'regencyName');
    final districtCode = _nullableString(json, 'districtCode');
    final districtName = _nullableString(json, 'districtName');
    final villageCode = _nullableString(json, 'villageCode');
    final villageName = _nullableString(json, 'villageName');
    final postalCode = _nullableString(json, 'postalCode');
    final currency = _nullableString(json, 'currency');
    final memberCount = json['memberCount'];
    final setupStep = json['setupStep'] ?? 0;
    _validateRegionCode(provinceCode, provinceName, [2], 'province');
    _validateRegionCode(regencyCode, regencyName, [2, 2], 'regency');
    _validateRegionCode(districtCode, districtName, [2, 2, 2], 'district');
    _validateRegionCode(villageCode, villageName, [2, 2, 2, 4], 'village');
    if ((regencyCode != null &&
            (provinceCode == null ||
                !regencyCode.startsWith('$provinceCode.'))) ||
        (districtCode != null &&
            (regencyCode == null ||
                !districtCode.startsWith('$regencyCode.'))) ||
        (villageCode != null &&
            (districtCode == null ||
                !villageCode.startsWith('$districtCode.')))) {
      throw const FormatException('Hierarki wilayah organisasi tidak valid.');
    }
    if (id is! String || name is! String || timezone is! String) {
      throw const FormatException('Data organisasi tidak valid.');
    }
    if (memberCount != null && memberCount is! int) {
      throw const FormatException('Jumlah anggota organisasi tidak valid.');
    }
    if (setupStep is! int || setupStep < 0 || setupStep > 5) {
      throw const FormatException('Langkah setup organisasi tidak valid.');
    }
    return OrganizationModel(
      id: id,
      name: name,
      timezone: timezone,
      businessType: businessType,
      description: description,
      logoUrl: logoUrl,
      email: email,
      phone: phone,
      website: website,
      address: address,
      city: city,
      province: province,
      provinceCode: provinceCode,
      provinceName: provinceName,
      regencyCode: regencyCode,
      regencyName: regencyName,
      districtCode: districtCode,
      districtName: districtName,
      villageCode: villageCode,
      villageName: villageName,
      postalCode: postalCode,
      currency: currency,
      setupCompletedAt: _date(json['setupCompletedAt']),
      setupStep: setupStep,
      memberCount: memberCount as int?,
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'timezone': timezone,
    'businessType': businessType?.apiValue,
    'description': description,
    'logoUrl': logoUrl,
    'email': email,
    'phone': phone,
    'website': website,
    'address': address,
    'city': city,
    'province': province,
    'provinceCode': provinceCode,
    'provinceName': provinceName,
    'regencyCode': regencyCode,
    'regencyName': regencyName,
    'districtCode': districtCode,
    'districtName': districtName,
    'villageCode': villageCode,
    'villageName': villageName,
    'postalCode': postalCode,
    'currency': currency,
    if (setupCompletedAt != null)
      'setupCompletedAt': setupCompletedAt!.toIso8601String(),
    'setupStep': setupStep,
    if (memberCount != null) 'memberCount': memberCount,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };
}

void _validateRegionCode(
  String? code,
  String? name,
  List<int> segmentLengths,
  String level,
) {
  final segments = code?.split('.');
  if (code != null &&
      (segments == null ||
          segments.length != segmentLengths.length ||
          !List.generate(
            segmentLengths.length,
            (index) =>
                segments[index].length == segmentLengths[index] &&
                RegExp(r'^\d+$').hasMatch(segments[index]),
          ).every((isValid) => isValid) ||
          name == null)) {
    throw FormatException('Kode wilayah $level organisasi tidak valid.');
  }
}

String? _nullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value != null && value is! String) {
    throw FormatException('Data organisasi ($key) tidak valid.');
  }
  return value as String?;
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    throw const FormatException('Tanggal organisasi tidak valid.');
  }
  return DateTime.tryParse(value) ??
      (throw const FormatException('Tanggal organisasi tidak valid.'));
}
