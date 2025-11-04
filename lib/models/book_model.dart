class BookModel {
  final String id;
  final String title;
  final String author;
  final String condition; // New, Like New, Good, Used
  final String imageUrl;
  final String ownerId;
  final String ownerName;
  final String status; // Available, Pending, Swapped
  final DateTime createdAt;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.imageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'condition': condition,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory BookModel.fromMap(String id, Map<String, dynamic> map) {
    return BookModel(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      condition: map['condition'] ?? 'Good',
      imageUrl: map['imageUrl'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      status: map['status'] ?? 'Available',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  BookModel copyWith({
    String? title,
    String? author,
    String? condition,
    String? imageUrl,
    String? status,
  }) {
    return BookModel(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId,
      ownerName: ownerName,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
