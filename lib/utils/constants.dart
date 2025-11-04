class AppConstants {
  static const String appName = 'BookSwap';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String booksCollection = 'books';
  static const String swapsCollection = 'swaps';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';

  // Book Conditions
  static const List<String> bookConditions = [
    'New',
    'Like New',
    'Good',
    'Used',
  ];

  // Book Status
  static const String bookAvailable = 'Available';
  static const String bookPending = 'Pending';
  static const String bookSwapped = 'Swapped';

  // Swap Status
  static const String swapPending = 'Pending';
  static const String swapAccepted = 'Accepted';
  static const String swapRejected = 'Rejected';
  static const String swapCompleted = 'Completed';
}

class AppColors {
  static const primaryColor = 0xFF2E7D32;
  static const secondaryColor = 0xFF4CAF50;
  static const accentColor = 0xFF8BC34A;
  static const backgroundColor = 0xFFF5F5F5;
  static const textColor = 0xFF333333;
  static const errorColor = 0xFFD32F2F;
}
