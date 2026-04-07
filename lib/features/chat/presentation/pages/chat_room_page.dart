import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../view_models/chat_cubit.dart';
import '../../data/models/chat_models.dart';
import '../widgets/chat_bubble.dart';

class ChatRoomPage extends StatefulWidget {
  final Conversation conversation;
  const ChatRoomPage({super.key, required this.conversation});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().openChat(widget.conversation.userId);
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSend() {
    if (_msgController.text.trim().isEmpty) return;
    context.read<ChatCubit>().send(_msgController.text);
    _msgController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) context.read<ChatCubit>().closeRoom();
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state.isLoading) return const Center(child: CircularProgressIndicator());
                  final grouped = _groupMessages(state.activeMessages);
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final item = grouped[index];
                      if (item is String) return _buildDateHeader(item);
                      return ChatBubble(
                        message: item as ChatMessage,
                        isMe: item.isMe(state.currentUserId),
                      );
                    },
                  );
                },
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.surfaceWhite,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textMain, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.borderSoft.withValues(alpha: 0.5),
            child: Text(
              widget.conversation.userName.substring(0, 1),
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.conversation.userName,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMain,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'En ligne',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      color: AppTheme.textDim,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_rounded, color: AppTheme.primaryBlue),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call_rounded, color: AppTheme.primaryBlue),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDateHeader(String date) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderSoft),
        ),
        child: Text(
          date,
          style: GoogleFonts.lexend(
            fontSize: 10,
            color: AppTheme.textDim,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surfaceWhite,
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              color: AppTheme.borderSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_rounded, color: AppTheme.textDim),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.borderSoft.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderSoft),
              ),
              child: TextField(
                controller: _msgController,
                decoration: InputDecoration(
                  hintText: 'Écrire un message...',
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDim),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => _onSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _onSend,
            child: Container(
              height: 48,
              width: 48,
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: AppTheme.surfaceWhite, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _groupMessages(List<ChatMessage> messages) {
    if (messages.isEmpty) return [];
    List<dynamic> grouped = [];
    String? lastDate;

    for (var msg in messages) {
      final dateStr = _getDateLabel(msg.sentAt);
      if (dateStr != lastDate) {
        grouped.add(dateStr);
        lastDate = dateStr;
      }
      grouped.add(msg);
    }
    return grouped;
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return "AUJOURD'HUI";
    }
    return DateFormat('dd MMMM yyyy', 'fr_FR').format(date).toUpperCase();
  }
}
