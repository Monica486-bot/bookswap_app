import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/book_model.dart';

class BookProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  final List<BookModel> _allBooks = [];
  final List<BookModel> _userBooks = [];
  bool _isLoading = false;
  String? _error;

  List<BookModel> get allBooks => _allBooks;
  List<BookModel> get userBooks => _userBooks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Stream for real-time updates on all books
  Stream<List<BookModel>> get allBooksStream =>
      _firestoreService.getBooksStream();

  // Stream for real-time updates on user's books
  Stream<List<BookModel>> userBooksStream(String userId) =>
      _firestoreService.getUserBooksStream(userId);

  // Add a new book
  Future<bool> addBook(BookModel book, dynamic imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Upload image if provided
      if (imageFile != null) {
        String imageUrl = await _storageService.uploadBookImage(
          imageFile,
          book.ownerId,
        );
        book = book.copyWith(imageUrl: imageUrl);
      }

      await _firestoreService.addBook(book);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add book: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update a book
  Future<bool> updateBook(BookModel book, dynamic imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Upload new image if provided
      if (imageFile != null) {
        // Delete old image if exists
        if (book.imageUrl.isNotEmpty) {
          await _storageService.deleteImage(book.imageUrl);
        }

        String imageUrl = await _storageService.uploadBookImage(
          imageFile,
          book.ownerId,
        );
        book = book.copyWith(imageUrl: imageUrl);
      }

      await _firestoreService.updateBook(book);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update book: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a book
  Future<bool> deleteBook(BookModel book) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Delete associated image
      if (book.imageUrl.isNotEmpty) {
        await _storageService.deleteImage(book.imageUrl);
      }

      await _firestoreService.deleteBook(book.id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete book: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
