import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/chat_models.dart';
import '../../data/services/chat_service.dart';
import '../../../auth/presentation/view_models/auth_cubit.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/architecture/base_state.dart' as base;

class ChatState {
  final List<Conversation> conversations;
  final List<Conversation> searchResults;
  final List<ChatMessage> activeMessages;
  final bool isLoading;
  final bool isSearching;
  final String? error;
  final String currentUserId;

  ChatState({
    required this.conversations,
    required this.searchResults,
    required this.activeMessages,
    this.isLoading = false,
    this.isSearching = false,
    this.error,
    this.currentUserId = '',
  });

  factory ChatState.initial() => ChatState(conversations: [], searchResults: [], activeMessages: []);

  ChatState copyWith({
    List<Conversation>? conversations,
    List<Conversation>? searchResults,
    List<ChatMessage>? activeMessages,
    bool? isLoading,
    bool? isSearching,
    String? error,
    String? currentUserId,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      searchResults: searchResults ?? this.searchResults,
      activeMessages: activeMessages ?? this.activeMessages,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: error,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}

class ChatCubit extends Cubit<ChatState> {
  final ChatService _service;
  final AuthCubit _authCubit;
  Timer? _pollingTimer;
  Timer? _searchDebounce;
  StreamSubscription? _authSubscription;
  String? _currentRoomPeer;

  ChatCubit(this._service, this._authCubit) : super(ChatState.initial()) {
    _syncWithAuth();
    _authSubscription = _authCubit.stream.listen((authState) {
      if (authState is base.Success<UserModel>) {
        emit(state.copyWith(currentUserId: authState.data.id));
      }
    });
  }

  void _syncWithAuth() {
    final authState = _authCubit.state;
    if (authState is base.Success<UserModel>) {
      emit(state.copyWith(currentUserId: authState.data.id));
    }
  }

  // Load all active conversations (Home Chat Page)
  void loadConversations() async {
    emit(state.copyWith(isLoading: state.conversations.isEmpty));
    try {
      final conversations = await _service.getConversations();
      emit(state.copyWith(conversations: conversations, isLoading: false));
      _startListPolling();
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  // Global user search
  void search(String query) async {
    _searchDebounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _startListPolling();
      emit(state.copyWith(searchResults: [], isSearching: false));
      return;
    }

    if (trimmed.length < 2) {
      emit(state.copyWith(searchResults: [], isSearching: false));
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        _pollingTimer?.cancel();
        emit(state.copyWith(isSearching: true));
        final results = await _service.searchUsers(trimmed);
        emit(state.copyWith(searchResults: results, isSearching: false));
      } catch (_) {
        emit(state.copyWith(isSearching: false));
      }
    });
  }

  // Open chat room with a specific peer
  void openChat(String peerId) async {
    _currentRoomPeer = peerId;
    emit(state.copyWith(isLoading: state.activeMessages.isEmpty));
    try {
      final messages = await _service.getMessages(peerId);
      emit(state.copyWith(activeMessages: messages, isLoading: false));
      _startRoomPolling(peerId);
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  // Send message
  Future<void> send(String text) async {
    final peerId = _currentRoomPeer;
    if (text.trim().isEmpty || peerId == null) return;
    
    // Optimistic Update: instantly show message in UI
    final optimisticMsg = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: state.currentUserId,
      receiverId: peerId,
      content: text.trim(),
      isRead: false,
      sentAt: DateTime.now(),
    );
    
    emit(state.copyWith(activeMessages: [...state.activeMessages, optimisticMsg]));

    try {
      await _service.sendMessage(peerId, text.trim());
      // Refresh room from backend to get permanent IDs and dates
      final messages = await _service.getMessages(peerId);
      emit(state.copyWith(activeMessages: messages));
    } catch (_) {
      // Revert if sending failed by just pulling the backend history again
      final messages = await _service.getMessages(peerId);
      emit(state.copyWith(activeMessages: messages));
    }
  }

  void _startListPolling() {
     _pollingTimer?.cancel();
     _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        if (_currentRoomPeer != null) return; // Don't poll list if in a room
        try {
          final conversations = await _service.getConversations();
          emit(state.copyWith(conversations: conversations));
        } catch (_) {}
     });
  }

  void _startRoomPolling(String peerId) {
     _pollingTimer?.cancel();
     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (_currentRoomPeer != peerId) {
          timer.cancel();
          return;
        }
        try {
          final messages = await _service.getMessages(peerId);
          if (messages.length != state.activeMessages.length) {
            emit(state.copyWith(activeMessages: messages));
          }
        } catch (_) {}
     });
  }

  void closeRoom() {
    _currentRoomPeer = null;
    loadConversations();
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _searchDebounce?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
