import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/administrative_region.dart';
import '../bloc/region_bloc.dart';

class OrganizationRegionFields extends StatelessWidget {
  const OrganizationRegionFields({
    required this.province,
    required this.regency,
    required this.district,
    required this.village,
    required this.legacyProvinceName,
    required this.legacyRegencyName,
    required this.onProvinceChanged,
    required this.onRegencyChanged,
    required this.onDistrictChanged,
    required this.onVillageChanged,
    super.key,
  });

  final AdministrativeRegion? province;
  final AdministrativeRegion? regency;
  final AdministrativeRegion? district;
  final AdministrativeRegion? village;
  final String? legacyProvinceName;
  final String? legacyRegencyName;
  final ValueChanged<AdministrativeRegion?> onProvinceChanged;
  final ValueChanged<AdministrativeRegion?> onRegencyChanged;
  final ValueChanged<AdministrativeRegion?> onDistrictChanged;
  final ValueChanged<AdministrativeRegion?> onVillageChanged;

  @override
  Widget build(BuildContext context) => BlocBuilder<RegionBloc, RegionState>(
    builder: (context, state) => Column(
      children: [
        _field(
          context: context,
          label: 'Provinsi',
          hint: _hint(legacyProvinceName),
          selected: province,
          regions: state.provinces,
          status: state.provincesStatus,
          error: state.provincesError,
          enabled: true,
          onRetry: () =>
              context.read<RegionBloc>().add(const ProvincesRequested()),
          onChanged: onProvinceChanged,
        ),
        _field(
          context: context,
          label: 'Kabupaten/Kota',
          hint: _hint(legacyRegencyName),
          selected: regency,
          regions: state.regencies,
          status: state.regenciesStatus,
          error: state.regenciesError,
          enabled: province != null,
          onRetry: province == null
              ? null
              : () => context.read<RegionBloc>().add(
                  RegenciesRequested(province!.id),
                ),
          onChanged: onRegencyChanged,
        ),
        _field(
          context: context,
          label: 'Kecamatan',
          hint: 'Pilih kecamatan',
          selected: district,
          regions: state.districts,
          status: state.districtsStatus,
          error: state.districtsError,
          enabled: regency != null,
          onRetry: regency == null
              ? null
              : () => context.read<RegionBloc>().add(
                  DistrictsRequested(regency!.id),
                ),
          onChanged: onDistrictChanged,
        ),
        _field(
          context: context,
          label: 'Desa/Kelurahan',
          hint: 'Pilih desa/kelurahan',
          selected: village,
          regions: state.villages,
          status: state.villagesStatus,
          error: state.villagesError,
          enabled: district != null,
          onRetry: district == null
              ? null
              : () => context.read<RegionBloc>().add(
                  VillagesRequested(district!.id),
                ),
          onChanged: onVillageChanged,
        ),
      ],
    ),
  );

  String _hint(String? savedName) => savedName == null
      ? 'Pilih wilayah'
      : '$savedName (pilih kembali untuk mengatur kode wilayah)';

  Widget _field({
    required BuildContext context,
    required String label,
    required String hint,
    required AdministrativeRegion? selected,
    required List<AdministrativeRegion> regions,
    required RegionLoadStatus status,
    required String? error,
    required bool enabled,
    required VoidCallback? onRetry,
    required ValueChanged<AdministrativeRegion?> onChanged,
  }) {
    final hasSelectedOption =
        selected != null && regions.any((region) => region.id == selected.id);
    final isLoading = status == RegionLoadStatus.loading;
    return Padding(
      padding: const EdgeInsets.only(top: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 7),
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          DropdownMenu<String>(
            key: ValueKey('$label:${hasSelectedOption ? selected.id : ''}'),
            initialSelection: hasSelectedOption ? selected.id : null,
            enabled: enabled && !isLoading,
            width: MediaQuery.sizeOf(context).width - 48,
            trailingIcon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.arrow_drop_down),
            inputDecorationTheme: const InputDecorationTheme(
              contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            hintText: hint,
            dropdownMenuEntries: regions
                .map(
                  (region) =>
                      DropdownMenuEntry(value: region.id, label: region.name),
                )
                .toList(),
            onSelected: enabled && !isLoading
                ? (id) => onChanged(
                    id == null
                        ? null
                        : regions.firstWhere((region) => region.id == id),
                  )
                : null,
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(
                        color: GawenColors.error,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
