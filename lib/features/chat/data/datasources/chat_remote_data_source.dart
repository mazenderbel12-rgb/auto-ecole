import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class ChatRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<List<dynamic>> getConversations() async {
    final response = await _dio.get('/messages/conversations');
    final data = response.data;
    if (data is List) {
       return data;
    } else if (data is Map && data['conversations'] is List) {
       return data['conversations'];
    }
    return [];
  }

  Future<List<dynamic>> getMessages(String userId) async {
    final response = await _dio.get('/messages/conversations/$userId');
    final data = response.data;
    if (data is List) {
       return data;
    } else if (data is Map && data['messages'] is List) {
       return data['messages'];
    }
    return [];
  }

  Future<void> sendMessage(String receiverId, String content) async {
    await _dio.post('/messages', data: {
      'Id_Destinataire': receiverId,
      'Contenu': content,
    });
  }

  Future<List<dynamic>> searchUsers(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return await _fetchAllUsers();
    }

    // Minimal requests: use the working endpoints only
    final results = <dynamic>[];
    try {
      final response = await _dio.get(
        '/messages/contacts',
        queryParameters: {'q': trimmed},
      );
      results.addAll(_extractList(response.data));
    } catch (_) {}

    if (results.isEmpty) {
      try {
        final response = await _dio.get(
          '/utilisateurs',
          queryParameters: {'search': trimmed},
        );
        results.addAll(_extractList(response.data));
      } catch (_) {}
    }

    return results.isEmpty ? await _fetchAllUsers() : results;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['users'] is List) return data['users'];
      if (data['data'] is List) return data['data'];
      if (data['items'] is List) return data['items'];
      if (data['results'] is List) return data['results'];
      if (data['contacts'] is List) return data['contacts'];
      if (data['utilisateurs'] is List) return data['utilisateurs'];
    }
    return [];
  }

  String _extractId(dynamic item) {
    if (item is Map) {
      final id = item['Id_Utilisateur'] ?? item['id_utilisateur'] ?? item['id'] ?? item['Id'];
      return id?.toString() ?? '';
    }
    return '';
  }

  Future<List<dynamic>> _fetchAllUsers() async {
    try {
      final response = await _dio.get('/utilisateurs');
      return _extractList(response.data);
    } catch (_) {
      return [];
    }
  }
}
