enum OrganizationBusinessType {
  foodAndBeverage('FOOD_AND_BEVERAGE', 'Makanan & Minuman'),
  retail('RETAIL', 'Retail / Perdagangan'),
  services('SERVICES', 'Jasa'),
  beautyAndWellness('BEAUTY_AND_WELLNESS', 'Kecantikan & Kebugaran'),
  automotive('AUTOMOTIVE', 'Otomotif'),
  manufacturing('MANUFACTURING', 'Manufaktur'),
  hospitality('HOSPITALITY', 'Perhotelan & Akomodasi'),
  other('OTHER', 'Lainnya');

  const OrganizationBusinessType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static OrganizationBusinessType fromApiValue(Object? value) {
    for (final businessType in values) {
      if (businessType.apiValue == value) return businessType;
    }
    throw const FormatException('Jenis usaha tidak valid.');
  }
}
