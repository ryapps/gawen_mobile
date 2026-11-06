import '../../domain/entities/administrative_region.dart';

class AdministrativeRegionModel extends AdministrativeRegion {
  const AdministrativeRegionModel({required super.id, required super.name});

  factory AdministrativeRegionModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final name = json['name'];
    final id = switch (rawId) {
      String value => value,
      int value => value.toString(),
      _ => null,
    };
    if (id == null || id.isEmpty || name is! String || name.isEmpty) {
      throw const FormatException('Data wilayah tidak valid.');
    }
    return AdministrativeRegionModel(id: id, name: name);
  }
}
