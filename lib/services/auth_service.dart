import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of user authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user!.updateDisplayName(displayName);

      // Send email verification
      await credential.user!.sendEmailVerification();

      // Create user document in Firestore
      UserModel user = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        photoUrl: null,
        emailVerified: false,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .set(user.toMap());

      return user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }

  // Resend email verification
  Future<void> resendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Reload user to get latest verification status
  Future<void> reloadUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Delete all user data from Firestore first
        await _deleteAllUserData(user.uid);
        
        // Delete Firebase Auth account
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw Exception('Please sign out and sign back in, then try deleting your account again.');
        }
        throw Exception('Failed to delete account: ${e.message}');
      } catch (e) {
        throw Exception('Failed to delete account: $e');
      }
    }
  }

  // Delete user account with re-authentication
  Future<void> deleteAccountWithReauth(String password) async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      try {
        // Re-authenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        
        // Delete all user data from Firestore
        await _deleteAllUserData(user.uid);
        
        // Delete Firebase Auth account
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          throw Exception('Incorrect password. Please try again.');
        }
        throw Exception('Failed to delete account: ${e.message}');
      } catch (e) {
        throw Exception('Failed to delete account: $e');
      }
    }
  }

  // Delete all user-related data from Firestore
  Future<void> _deleteAllUserData(String userId) async {
    final batch = _firestore.batch();

    // Delete user's books
    final booksQuery = await _firestore
        .collection(AppConstants.booksCollection)
        .where('ownerId', isEqualTo: userId)
        .get();
    for (var doc in booksQuery.docs) {
      batch.delete(doc.reference);
    }

    // Delete user's swaps (both sent and received)
    final swapsFromQuery = await _firestore
        .collection(AppConstants.swapsCollection)
        .where('fromUserId', isEqualTo: userId)
        .get();
    for (var doc in swapsFromQuery.docs) {
      batch.delete(doc.reference);
    }

    final swapsToQuery = await _firestore
        .collection(AppConstants.swapsCollection)
        .where('toUserId', isEqualTo: userId)
        .get();
    for (var doc in swapsToQuery.docs) {
      batch.delete(doc.reference);
    }

    // Delete user's chats
    final chatsQuery = await _firestore
        .collection(AppConstants.chatsCollection)
        .where('participants', arrayContains: userId)
        .get();
    for (var doc in chatsQuery.docs) {
      // Delete all messages in the chat
      final messagesQuery = await doc.reference
          .collection(AppConstants.messagesCollection)
          .get();
      for (var messageDoc in messagesQuery.docs) {
        batch.delete(messageDoc.reference);
      }
      // Delete the chat document
      batch.delete(doc.reference);
    }

    // Delete user document
    batch.delete(_firestore.collection(AppConstants.usersCollection).doc(userId));

    // Commit all deletions
    await batch.commit();
  }
}
