import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class MonitorRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<List<dynamic>> getMySchedule() async {
    final response = await _dio.get('/monitor/schedule');
    return response.data;
  }

  Future<void> markAttendance(String sessionId, String studentId, bool present) async {
    await _dio.post('/monitor/attendance', data: {
      'session_id': sessionId,
      'student_id': studentId,
      'is_present': present,
    });
  }

  Future<void> submitEvaluation(String sessionId, String studentId, Map<String, dynamic> evaluation) async {
    await _dio.post('/monitor/evaluations', data: {
      'session_id': sessionId,
      'student_id': studentId,
      'evaluation': evaluation,
    });
  }
}
