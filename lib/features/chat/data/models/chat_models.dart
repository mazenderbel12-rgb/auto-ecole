import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['Id_Message'] ?? json['id_message'] ?? '').toString(),
      senderId: (json['Id_Expediteur'] ?? json['id_expediteur'] ?? '').toString(),
      receiverId: (json['Id_Destinataire'] ?? json['id_destinataire'] ?? '').toString(),
      content: json['Contenu'] ?? json['contenu'] ?? '',
      isRead: json['EstLu'] == 1 || json['EstLu'] == true || json['estlu'] == 1 || json['estlu'] == true || json['est_lu'] == 1 || json['est_lu'] == true,
      sentAt: _parseDate(json['DateEnvoi'] ?? json['date_envoi']) ?? DateTime.now(),
    );
  }

  bool isMe(String currentUserId) => senderId.toLowerCase() == currentUserId.toLowerCase();

  @override
  List<Object?> get props => [id, senderId, receiverId, content, isRead, sentAt];
}

class Conversation extends Equatable {
  final String userId;
  final String userName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String role;

  const Conversation({
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.role,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      userId: (json['userId'] ?? '').toString(),
      userName: json['userName'] ?? 'Utilisateur',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: _parseDate(json['lastMessageTime']) ?? DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
      role: json['role'] ?? 'user',
    );
  }

  @override
  List<Object?> get props => [userId, userName, lastMessage, lastMessageTime, unreadCount, role];
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  final parsed = DateTime.tryParse(value.toString());
  if (parsed == null) return null;
  return parsed.isUtc ? parsed.toLocal() : parsed.toLocal();
}
