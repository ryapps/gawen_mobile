sealed class RegionEvent {
  const RegionEvent();
}

final class ProvincesRequested extends RegionEvent {
  const ProvincesRequested();
}

final class RegenciesRequested extends RegionEvent {
  const RegenciesRequested(this.provinceCode);

  final String provinceCode;
}

final class DistrictsRequested extends RegionEvent {
  const DistrictsRequested(this.regencyCode);

  final String regencyCode;
}

final class VillagesRequested extends RegionEvent {
  const VillagesRequested(this.districtCode);

  final String districtCode;
}
