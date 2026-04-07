import '../datasources/chat_remote_data_source.dart';
import '../models/chat_models.dart';

class ChatService {
  final ChatRemoteDataSource _remote;

  ChatService(this._remote);

  Future<List<Conversation>> getConversations() async {
    final data = await _remote.getConversations();
    return data.map((item) {
      // Handle the backend nested structure: { "other_user": {...}, "last_message": {...} }
      if (item is Map && item.containsKey('other_user') && item.containsKey('last_message')) {
        final otherUser = item['other_user'] ?? {};
        final lastMsg = item['last_message'] ?? {};
        final firstName = otherUser['Prenom'] ?? otherUser['first_name'] ?? '';
        final lastName = otherUser['Nom'] ?? otherUser['last_name'] ?? '';

        return Conversation(
          userId: (otherUser['Id_Utilisateur'] ?? '').toString(),
          userName: "$firstName $lastName".trim().isNotEmpty ? "$firstName $lastName" : "Utilisateur",
          lastMessage: lastMsg['Contenu'] ?? '',
          lastMessageTime: _parseDate(lastMsg['DateEnvoi']) ?? DateTime.now(),
          unreadCount: 0,
          role: (otherUser['Role'] ?? '').toString(),
        );
      }
      return Conversation.fromJson(item);
    }).toList();
  }

  Future<List<ChatMessage>> getMessages(String userId) async {
    final data = await _remote.getMessages(userId);
    return data.map((item) => ChatMessage.fromJson(item)).toList();
  }

  Future<void> sendMessage(String receiverId, String content) async {
    await _remote.sendMessage(receiverId, content);
  }

  Future<List<Conversation>> searchUsers(String query) async {
    final data = await _remote.searchUsers(query);
    final conversations = data.map((u) {
      final firstName = u['Prenom'] ?? u['prenom'] ?? u['first_name'] ?? '';
      final lastName = u['Nom'] ?? u['nom'] ?? u['last_name'] ?? '';
      final roleObj = u['role'] ?? u['Role'];
      final roleName = roleObj != null ? (roleObj['NomRole'] ?? roleObj['nomrole'] ?? 'Utilisateur') : (u['role_name'] ?? 'Utilisateur');

      return Conversation(
        userId: (u['Id_Utilisateur'] ?? u['id_utilisateur'] ?? u['id'] ?? '').toString(),
        userName: "$firstName $lastName".trim().isNotEmpty ? "$firstName $lastName" : "Utilisateur",
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        role: roleName.toString(),
      );
    }).toList();

    final q = query.trim().toLowerCase();
    if (q.isEmpty) return conversations;

    return conversations.where((conv) {
      return conv.userName.toLowerCase().contains(q) ||
          conv.role.toLowerCase().contains(q);
    }).toList();
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  final parsed = DateTime.tryParse(value.toString());
  if (parsed == null) return null;
  return parsed.isUtc ? parsed.toLocal() : parsed.toLocal();
}
