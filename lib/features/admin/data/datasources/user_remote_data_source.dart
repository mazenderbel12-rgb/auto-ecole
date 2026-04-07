import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class UserRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<PagedResponse> fetchUsers({
    required String role,
    required int page,
    String? query,
  }) async {
    final response = await _dio.get(
      '/utilisateurs',
      queryParameters: {
        if (role.isNotEmpty) 'role': role,
        'page': page,
        if (query != null && query.isNotEmpty) 'search': query,
      },
    );
    return PagedResponse.fromResponse(response.data);
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> payload) async {
    final response = await _dio.post('/utilisateurs', data: payload);
    return _extractFirstObject(response.data);
  }

  Future<Map<String, dynamic>> updateUser(String id, Map<String, dynamic> payload) async {
    // Add _method: 'PUT' for better server compatibility (Laravel convention)
    final Map<String, dynamic> data = {...payload, '_method': 'PUT'};
    final response = await _dio.post('/utilisateurs/$id', data: data);
    return _extractFirstObject(response.data);
  }

  Future<void> deleteUser(String id) async {
    await _dio.delete('/utilisateurs/$id');
  }

  Map<String, dynamic> _extractFirstObject(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) return inner;
      if (inner is List && inner.isNotEmpty && inner.first is Map<String, dynamic>) {
        return Map<String, dynamic>.from(inner.first);
      }
      return data;
    }
    return <String, dynamic>{};
  }
}

class PagedResponse {
  final List<dynamic> items;
  final int currentPage;
  final int lastPage;

  const PagedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;

  factory PagedResponse.fromResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      final list = data['data'] is List ? data['data'] as List : (data['items'] as List?) ?? const [];
      final current = _toInt(data['current_page'] ?? data['page'] ?? 1);
      final last = _toInt(data['last_page'] ?? data['total_pages'] ?? 1);
      return PagedResponse(items: list, currentPage: current, lastPage: last);
    }
    if (data is List) {
      return PagedResponse(items: data, currentPage: 1, lastPage: 1);
    }
    return const PagedResponse(items: [], currentPage: 1, lastPage: 1);
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }
}
