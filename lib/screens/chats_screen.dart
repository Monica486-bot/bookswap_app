import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_auth_provider.dart';
import '../services/firestore_service.dart';
import 'chat_screen.dart';
import '../utils/constants.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserAuthProvider>(context);
    final firestoreService = FirestoreService();
    final currentUserId = authProvider.currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: SizedBox(),
        ),
        body: Center(
          child: Text('Please log in to view chats'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getUserChatsStream(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading chats: ${snapshot.error}'),
            );
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: 80.0,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    'No chats yet',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Start a swap to begin chatting',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];

              return ChatListItem(
                chat: chat,
                currentUserId: currentUserId,
                onTap: () {
                  final participants = List<String>.from(chat['participants']);
                  final otherUserId = participants.firstWhere(
                    (id) => id != currentUserId,
                    orElse: () => '',
                  );
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chat['id'],
                        otherUserName: 'Chat Partner',
                        swapId: chat['swapId'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final Map<String, dynamic> chat;
  final String currentUserId;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(Icons.chat_bubble, color: Colors.white),
        ),
        title: Text(
          'Swap Chat #${chat['swapId'].substring(0, 8)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.text,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            chat['lastMessage'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatTime(chat['lastMessageTime']),
                style: TextStyle(
                  fontSize: 12.0,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }
}
