import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_theme.dart';
import '../view_models/chat_cubit.dart';
import '../../data/models/chat_models.dart';
import 'chat_room_page.dart';

class ChatListPage extends StatefulWidget {
  final bool isSubPage;
  const ChatListPage({super.key, this.isSubPage = false});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ChatCubit>()..loadConversations(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: widget.isSubPage ? null : AppBar(
          elevation: 0,
          backgroundColor: AppTheme.surfaceWhite,
          title: Text(
            'Messages',
            style: GoogleFonts.lexend(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMain,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textMain),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            Builder(
              builder: (innerContext) => _buildSearchBar(innerContext),
            ),
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state.isLoading) return const Center(child: CircularProgressIndicator());
                  if (_isSearching && state.isSearching) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final results = _isSearching ? state.searchResults : state.conversations;
                  
                  if (results.isEmpty) {
                    return _isSearching ? _buildNoResultsPlaceholder() : _buildNoChatsPlaceholder();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: results.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 88, color: AppTheme.borderSoft),
                    itemBuilder: (context, index) => _buildConversationItem(context, results[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppTheme.textDim),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() => _isSearching = val.isNotEmpty);
                  context.read<ChatCubit>().search(val);
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher un contact...',
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDim),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_isSearching)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20, color: AppTheme.textDim),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _isSearching = false);
                  context.read<ChatCubit>().search('');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationItem(BuildContext context, Conversation conv) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ChatCubit>(),
            child: ChatRoomPage(conversation: conv),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildAvatar(conv),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conv.userName,
                        style: GoogleFonts.lexend(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textMain,
                        ),
                      ),
                      if (!_isSearching)
                        Text(
                          DateFormat('HH:mm').format(conv.lastMessageTime),
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            color: AppTheme.textDim,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isSearching ? conv.role.toUpperCase() : conv.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _isSearching ? AppTheme.accentOrange : AppTheme.textDim,
                            fontWeight: _isSearching ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (!_isSearching && conv.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            conv.unreadCount.toString(),
                            style: GoogleFonts.lexend(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.surfaceWhite,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Conversation conv) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppTheme.borderSoft.withValues(alpha: 0.5),
          child: Text(
            conv.userName.substring(0, 1),
            style: GoogleFonts.lexend(
              fontSize: 18,
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.surfaceWhite, width: 2.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoChatsPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppTheme.borderSoft),
          const SizedBox(height: 16),
          Text(
            'Pas encore de conversation.',
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: AppTheme.textDim,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_search_rounded, size: 64, color: AppTheme.borderSoft),
          const SizedBox(height: 16),
          Text(
            'Aucun utilisateur trouvé.',
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: AppTheme.textDim,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
