import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class ChatRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<List<dynamic>> getConversations() async {
    try {
      final response = await _dio.get('/messages/conversations');
      return _extractList(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getMessages(String userId) async {
    try {
      final response = await _dio.get('/messages/conversations/$userId');
      return _extractList(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<void> sendMessage(String receiverId, String content) async {
    await _dio.post('/messages', data: {
      'Id_Destinataire': receiverId,
      'Contenu': content,
      'EstLu': 0,
      'DateEnvoi': DateTime.now().format('yyyy-MM-dd HH:mm:ss'),
    });
  }

  Future<List<dynamic>> searchUsers(String query) async {
    try {
      final response = await _dio.get(
        '/messages/contacts',
        queryParameters: {'q': query.trim()},
      );
      return _extractList(response.data);
    } catch (_) {
      return [];
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in ['data', 'items', 'users', 'contacts', 'conversations', 'messages']) {
        if (data[key] is List) return data[key];
      }
    }
    return [];
  }
}

extension DateFormatExt on DateTime {
  String format(String pattern) {
    return "${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')} "
           "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}";
  }
}
