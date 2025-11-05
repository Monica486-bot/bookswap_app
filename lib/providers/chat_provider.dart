import 'package:flutter/foundation.dart';
import '../services/chat_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  final List<ChatModel> _userChats = [];
  List<MessageModel> _currentChatMessages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatModel> get userChats => _userChats;
  List<MessageModel> get currentChatMessages => _currentChatMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Stream for real-time updates on user chats
  Stream<List<ChatModel>> userChatsStream(String userId) =>
      _chatService.getUserChatsStream(userId);

  // Stream for real-time messages in a chat
  Stream<List<MessageModel>> messagesStream(String chatId) =>
      _chatService.getMessagesStream(chatId);

  // Get or create chat
  Future<String?> getOrCreateChat(
    String swapId,
    List<String> participants,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String chatId = await _chatService.getOrCreateChat(swapId, participants);
      _isLoading = false;
      notifyListeners();
      return chatId;
    } catch (e) {
      _error = 'Failed to create chat: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Send message
  Future<bool> sendMessage({
    required String chatId,
    required String text,
    required String senderName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _chatService.sendMessage(
        chatId: chatId,
        text: text,
        senderName: senderName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to send message: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      await _chatService.markMessagesAsRead(chatId, userId);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Clear current chat messages
  void clearCurrentChat() {
    _currentChatMessages = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
