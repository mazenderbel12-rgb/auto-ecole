import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class SeanceRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<List<dynamic>> fetchByDate(String date) async {
    final response = await _dio.get(
      '/seances',
      queryParameters: {'date': date},
    );
    return _extractList(response.data);
  }

  Future<List<dynamic>> fetchAll() async {
    final response = await _dio.get('/seances');
    return _extractList(response.data);
  }

  Future<Map<String, dynamic>> createSeance(Map<String, dynamic> payload) async {
    final response = await _dio.post('/seances', data: payload);
    return _extractFirstObject(response.data);
  }

  Future<Map<String, dynamic>> updateSeance(String id, Map<String, dynamic> payload) async {
    final data = {...payload, '_method': 'PUT'};
    final response = await _dio.post('/seances/$id', data: data);
    return _extractFirstObject(response.data);
  }

  Future<void> deleteSeance(String id) async {
    await _dio.delete('/seances/$id');
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

  List<dynamic> _extractList(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is List) return List<dynamic>.from(data['data'] as List);
      if (data['seances'] is List) return List<dynamic>.from(data['seances'] as List);
      if (data['items'] is List) return List<dynamic>.from(data['items'] as List);
      if (data['results'] is List) return List<dynamic>.from(data['results'] as List);
      if (data['list'] is List) return List<dynamic>.from(data['list'] as List);
      return const [];
    }
    if (data is List) return data;
    return const [];
  }
}
