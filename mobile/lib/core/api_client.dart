import 'package:dio/dio.dart';

import '../models/provider_data.dart';
import 'constants.dart';

class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                headers: {'Accept': 'application/json'},
              ),
            );

  final Dio _dio;
  AllProvidersResponse? _cache;
  DateTime? _cacheAt;
  static const _cacheDuration = Duration(minutes: 1);

  Future<AllProvidersResponse> fetchProviders({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cache != null &&
        _cacheAt != null &&
        now.difference(_cacheAt!) < _cacheDuration) {
      return _cache!;
    }

    final response = await _dio.get<Map<String, dynamic>>(ApiConstants.providersPath);
    final data = AllProvidersResponse.fromJson(response.data ?? {});
    _cache = data;
    _cacheAt = now;
    return data;
  }

  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiConstants.healthPath);
      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }
}
