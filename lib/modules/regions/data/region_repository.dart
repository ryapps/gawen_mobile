import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_failure.dart';
import 'models/administrative_region_model.dart';
import '../domain/entities/administrative_region.dart';

class RegionRepository {
  static const apiBaseUrl = 'https://www.emsifa.com/api-wilayah-indonesia/v2/';

  RegionRepository({Dio? client})
    : _client =
          client ??
          Dio(
            BaseOptions(
              baseUrl: apiBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );

  final Dio _client;
  final Map<String, Future<List<AdministrativeRegion>>> _cache = {};

  Future<List<AdministrativeRegion>> getProvinces() =>
      _getRegions('/provinces.json');

  Future<List<AdministrativeRegion>> getRegencies(String provinceCode) =>
      _getRegions('/regencies/$provinceCode.json');

  Future<List<AdministrativeRegion>> getDistricts(String regencyCode) =>
      _getRegions('/districts/$regencyCode.json');

  Future<List<AdministrativeRegion>> getVillages(String districtCode) =>
      _getRegions('/villages/$districtCode.json');

  Future<List<AdministrativeRegion>> _getRegions(String path) {
    return _cache
        .putIfAbsent(path, () async {
          try {
            final response = await _client.get<Object?>(path);
            final body = response.data;
            final data = body is Map<String, dynamic> ? body['data'] : body;
            if (data is! List) {
              throw const ApiFailure('Format data wilayah tidak dikenali.');
            }
            return data
                .map((item) {
                  if (item is! Map<String, dynamic>) {
                    throw const FormatException('Data wilayah tidak valid.');
                  }
                  return AdministrativeRegionModel.fromJson(item);
                })
                .toList(growable: false);
          } on DioException catch (error) {
            debugPrint(
              'Region API request failed: '
              'url=${error.requestOptions.uri}, '
              'type=${error.type}, '
              'status=${error.response?.statusCode}, '
              'message=${error.message}',
            );
            throw ApiFailure(dioErrorMessage(error));
          } on FormatException catch (error) {
            print('FormatException: ${error.message}');
            throw ApiFailure(error.message);
          }
        })
        .catchError((Object error) {
          _cache.remove(path);
          throw error;
        });
  }
}
