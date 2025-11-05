import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart'; // This should now work correctly
import '../utils/constants.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get or create chat for a swap
  Future<String> getOrCreateChat(
    String swapId,
    List<String> participants,
  ) async {
    try {
      // Check if chat already exists for this swap
      QuerySnapshot chatSnapshot = await _firestore
          .collection(AppConstants.chatsCollection)
          .where('swapId', isEqualTo: swapId)
          .get();

      if (chatSnapshot.docs.isNotEmpty) {
        return chatSnapshot.docs.first.id;
      }

      // Create new chat
      ChatModel newChat = ChatModel(
        id: _firestore.collection(AppConstants.chatsCollection).doc().id,
        swapId: swapId,
        participants: participants,
        lastMessage: 'Chat started',
        lastMessageTime: DateTime.now(),
        lastSenderId: _auth.currentUser!.uid,
      );

      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(newChat.id)
          .set(newChat.toMap());

      return newChat.id;
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderName,
  }) async {
    try {
      String messageId = _firestore
          .collection(AppConstants.chatsCollection)
          .doc()
          .id;

      MessageModel message = MessageModel(
        id: messageId,
        chatId: chatId,
        senderId: _auth.currentUser!.uid,
        senderName: senderName,
        text: text,
        timestamp: DateTime.now(),
        read: false,
      );

      // Add message to subcollection
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .collection(AppConstants.messagesCollection)
          .doc(messageId)
          .set(message.toMap());

      // Update chat last message
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .update({
            'lastMessage': text,
            'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
            'lastSenderId': _auth.currentUser!.uid,
          });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Stream of messages for a chat
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Stream of user's chats
  Stream<List<ChatModel>> getUserChatsStream(String userId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      QuerySnapshot unreadMessages = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .collection(AppConstants.messagesCollection)
          .where('senderId', isNotEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      for (var doc in unreadMessages.docs) {
        await doc.reference.update({'read': true});
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }
}
