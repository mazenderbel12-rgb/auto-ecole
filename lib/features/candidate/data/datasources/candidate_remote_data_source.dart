import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class CandidateRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<List<dynamic>> getMySessions() async {
    final response = await _dio.get('/candidate/sessions');
    return response.data;
  }

  Future<Map<String, dynamic>> getMyProgress() async {
    final response = await _dio.get('/candidate/progress');
    return response.data;
  }

  Future<void> bookSession(String sessionId) async {
    await _dio.post('/candidate/sessions/book', data: {'session_id': sessionId});
  }
}
