import 'package:flutter/material.dart';

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
  // Dark color scheme - Deep Blue/Purple theme
  static const int primaryColor = 0xFF1A237E;  // Deep Indigo
  static const int secondaryColor = 0xFF283593; // Darker Blue
  static const int accentColor = 0xFF5C6BC0;    // Medium Purple
  static const int backgroundColor = 0xFFFFFFFF; // White Background
  static const int surfaceColor = 0xFFF8F9FA;    // Light Gray Surface
  static const int cardColor = 0xFFFFFFFF;       // White Card Color
  static const int textColor = 0xFF212121;       // Dark Gray Text
  static const int textLightColor = 0xFF757575;  // Medium Gray Text
  static const int errorColor = 0xFF7986CB;      // Light Purple (Error)
  static const int successColor = 0xFF9FA8DA;    // Lighter Purple (Success)
  static const int warningColor = 0xFFB39DDB;    // Medium Purple (Warning)

  // Helper methods
  static Color get primary => const Color(primaryColor);
  static Color get secondary => const Color(secondaryColor);
  static Color get accent => const Color(accentColor);
  static Color get background => const Color(backgroundColor);
  static Color get surface => const Color(surfaceColor);
  static Color get card => const Color(cardColor);
  static Color get text => const Color(textColor);
  static Color get textLight => const Color(textLightColor);
  static Color get error => const Color(errorColor);
  static Color get success => const Color(successColor);
  static Color get warning => const Color(warningColor);
}
