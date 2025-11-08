import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String swapId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.swapId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestoreService.sendMessage(
        chatId: widget.chatId,
        senderId: user.uid,
        senderName: user.displayName ?? 'Unknown User',
        text: text,
      );
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getChatMessagesStream(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Start a conversation!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderId'] == currentUser?.uid;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isMe)
                            CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Text(
                                message['senderName'][0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          const SizedBox(width: 8.0),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: isMe ? AppColors.secondary : AppColors.card,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20.0),
                                  topRight: const Radius.circular(20.0),
                                  bottomLeft: Radius.circular(isMe ? 20.0 : 4.0),
                                  bottomRight: Radius.circular(isMe ? 4.0 : 20.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (!isMe)
                                    Text(
                                      message['senderName'],
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: AppColors.textLight,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  Text(
                                    message['text'],
                                    style: TextStyle(
                                      color: isMe ? Colors.white : AppColors.text,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    _formatTime(message['timestamp']),
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      color: isMe
                                          ? Colors.white70
                                          : AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isMe) const SizedBox(width: 8.0),
                          if (isMe)
                            CircleAvatar(
                              backgroundColor: AppColors.accent,
                              child: Text(
                                message['senderName'][0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 8.0,
                  color: Colors.black.withValues(alpha: 0.2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: AppColors.textLight),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12.0),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    padding: const EdgeInsets.all(12.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
