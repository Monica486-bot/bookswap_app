class SwapModel {
  final String id;
  final String bookId;
  final String bookTitle;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final String status; // Pending, Accepted, Rejected, Completed
  final DateTime createdAt;
  final DateTime updatedAt;

  SwapModel({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory SwapModel.fromMap(String id, Map<String, dynamic> map) {
    return SwapModel(
      id: id,
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      fromUserName: map['fromUserName'] ?? '',
      toUserId: map['toUserId'] ?? '',
      toUserName: map['toUserName'] ?? '',
      status: map['status'] ?? 'Pending',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  SwapModel copyWith({String? status, DateTime? updatedAt}) {
    return SwapModel(
      id: id,
      bookId: bookId,
      bookTitle: bookTitle,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      toUserId: toUserId,
      toUserName: toUserName,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
