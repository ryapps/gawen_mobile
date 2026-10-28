import '../../domain/entities/organization_entity.dart';

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
    final businessType = _nullableString(json, 'businessType');
    final description = _nullableString(json, 'description');
    final logoUrl = _nullableString(json, 'logoUrl');
    final email = _nullableString(json, 'email');
    final phone = _nullableString(json, 'phone');
    final website = _nullableString(json, 'website');
    final address = _nullableString(json, 'address');
    final city = _nullableString(json, 'city');
    final province = _nullableString(json, 'province');
    final postalCode = _nullableString(json, 'postalCode');
    final currency = _nullableString(json, 'currency');
    final memberCount = json['memberCount'];
    final setupStep = json['setupStep'] ?? 0;
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
    'businessType': businessType,
    'description': description,
    'logoUrl': logoUrl,
    'email': email,
    'phone': phone,
    'website': website,
    'address': address,
    'city': city,
    'province': province,
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
