class ChatModel {
  final String id;
  final String swapId;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastSenderId;

  ChatModel({
    required this.id,
    required this.swapId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastSenderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'swapId': swapId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'lastSenderId': lastSenderId,
    };
  }

  factory ChatModel.fromMap(String id, Map<String, dynamic> map) {
    return ChatModel(
      id: id,
      swapId: map['swapId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(
        map['lastMessageTime'] ?? 0,
      ),
      lastSenderId: map['lastSenderId'] ?? '',
    );
  }
}
