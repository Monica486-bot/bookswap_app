import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class UserAuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  UserAuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        // Reload user to get latest verification status
        await firebaseUser.reload();
        firebaseUser = FirebaseAuth.instance.currentUser;

        if (firebaseUser!.emailVerified) {
          _currentUser = await _authService.getCurrentUserData();
        }
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing auth: $e');
      }
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Sign in the user
      await _authService.signIn(
        email: email,
        password: password,
      );

      // Get the current Firebase user and reload to get latest status
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.reload();
        firebaseUser = FirebaseAuth.instance.currentUser;

        if (!firebaseUser!.emailVerified) {
          _error = 'Please verify your email before signing in.';
          await _authService.signOut();
          _currentUser = null;
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Email is verified, get user data
        _currentUser = await _authService.getCurrentUserData();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> resendVerification() async {
    await _authService.resendEmailVerification();
  }

  // Check if user needs to verify email - with proper reload
  Future<bool> checkEmailVerification() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Reload user to get latest email verification status
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
        return user?.emailVerified ?? false;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking email verification: $e');
      }
      return false;
    }
  }

  // Force refresh the auth state
  Future<void> refreshAuthState() async {
    await _initializeAuth();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool get isLoggedIn => _currentUser != null && _currentUser!.emailVerified;
}
