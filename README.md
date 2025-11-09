# BookSwap App 📚

A Flutter-based textbook marketplace where students can list, browse, and swap textbooks with real-time chat functionality.

## Features ✨

- **Authentication**: Firebase Auth with email verification
- **Book Management**: Full CRUD operations (Create, Read, Update, Delete)
- **Swap System**: Real-time swap offers with status tracking
- **Chat**: Real-time messaging between users after swap acceptance
- **Cross-Platform**: Works on Android, iOS, and Web

## Architecture 🏗️

```
📱 Presentation Layer
├── Screens (UI Components)
├── Widgets (Reusable Components)
└── Providers (State Management)

🔄 Business Logic Layer
├── Services (Firebase Integration)
├── Models (Data Classes)
└── Utils (Helpers & Constants)

☁️ Data Layer
├── Firebase Auth (Authentication)
├── Cloud Firestore (Database)
└── Firebase Storage (Images)
```

## Tech Stack 🛠️

- **Frontend**: Flutter 3.x
- **State Management**: Provider Pattern
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Image Handling**: Cross-platform image picker
- **Real-time Updates**: Firestore Streams

## Prerequisites 📋

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Firebase CLI
- Android Studio / VS Code
- Git

## Firebase Setup 🔥

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project: "BookSwap"
3. Enable Google Analytics (optional)

### 2. Configure Authentication
1. Navigate to Authentication → Sign-in method
2. Enable "Email/Password" provider
3. Configure email verification templates

### 3. Setup Firestore Database
1. Go to Firestore Database → Create database
2. Start in test mode (we'll add security rules later)
3. Choose your preferred region

### 4. Configure Storage
1. Navigate to Storage → Get started
2. Start in test mode
3. Note the storage bucket URL

### 5. Add Flutter App
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for Flutter
flutterfire configure
```

## Installation & Setup 🚀

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/bookswap_app.git
cd bookswap_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration
```bash
# Generate Firebase options
flutterfire configure

# This creates lib/firebase_options.dart
```

### 4. Add Firebase Config Files
- **Android**: Place `google-services.json` in `android/app/`
- **iOS**: Place `GoogleService-Info.plist` in `ios/Runner/`

### 5. Update Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Books - read all, write own
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.ownerId;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.ownerId;
    }
    
    // Swaps - access only if involved
    match /swaps/{swapId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.fromUserId || 
         request.auth.uid == resource.data.toUserId);
    }
    
    // Chats - access only participants
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read, write: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
      }
    }
  }
}
```

### 6. Update Storage Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /book_images/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Running the App 📱

### Development Mode
```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Run on web
flutter run -d chrome
```

### Build for Production
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Project Structure 📁

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── user_model.dart
│   ├── book_model.dart
│   ├── swap_model.dart
│   ├── chat_model.dart
│   └── message_model.dart
├── providers/                # State management
│   ├── user_auth_provider.dart
│   ├── book_provider.dart
│   ├── swap_provider.dart
│   └── chat_provider.dart
├── screens/                  # UI screens
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── verify_email_screen.dart
│   ├── home_screen.dart
│   ├── browse_screen.dart
│   ├── my_listings_screen.dart
│   ├── add_book_screen.dart
│   ├── edit_book_screen.dart
│   ├── chats_screen.dart
│   ├── chat_screen.dart
│   ├── my_offers_screen.dart
│   └── settings_screen.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── storage_service.dart
│   └── chat_service.dart
├── utils/                    # Utilities
│   ├── constants.dart
│   ├── validators.dart
│   └── image_utils.dart
└── widgets/                  # Reusable components
    ├── book_card.dart
    ├── swap_card.dart
    ├── bottom_nav_bar.dart
    └── cross_platform_image.dart
```

## Key Features Implementation 🔧

### Authentication Flow
- Email/password registration with verification
- Secure login with session persistence
- Email verification enforcement before app access

### Book Management
- Add books with image upload
- Edit/delete own listings
- Browse all available books
- Real-time status updates

### Swap System
- Initiate swap offers on available books
- Accept/reject incoming offers
- Real-time status synchronization
- Automatic chat creation on acceptance

### Real-time Chat
- Instant messaging between swap participants
- Message persistence and history
- Read status tracking
- Clean, modern chat UI

## Testing 🧪

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart
```

### Code Analysis
```bash
# Run Dart analyzer
flutter analyze

# Format code
flutter format .
```

## Troubleshooting 🔧

### Common Issues

**Firebase not initialized:**
```bash
# Ensure Firebase is configured
flutterfire configure
```

**Build errors:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

**Permission denied errors:**
- Check Firestore security rules
- Verify user authentication status
- Ensure proper Firebase project configuration

## Contributing 🤝

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact 📧

- **Developer**: Monica Ahol
- **Email**: m.ahol@alustudent.com
- **GitHub**: [Monica486-bot](https://github.com/yourusername)

## Acknowledgments 🙏

- Flutter team for the amazing framework
- Firebase for backend services
- Provider package for state management
- Image picker package for cross-platform image handling

---

**Built with ❤️ using Flutter and Firebase**