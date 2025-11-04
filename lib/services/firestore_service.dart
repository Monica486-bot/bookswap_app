import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../models/swap_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Books Collection Operations
  Stream<List<BookModel>> getBooksStream() {
    return _firestore
        .collection(AppConstants.booksCollection)
        .where('status', isEqualTo: AppConstants.bookAvailable)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<BookModel>> getUserBooksStream(String userId) {
    return _firestore
        .collection(AppConstants.booksCollection)
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addBook(BookModel book) async {
    await _firestore
        .collection(AppConstants.booksCollection)
        .doc(book.id)
        .set(book.toMap());
  }

  Future<void> updateBook(BookModel book) async {
    await _firestore
        .collection(AppConstants.booksCollection)
        .doc(book.id)
        .update(book.toMap());
  }

  Future<void> deleteBook(String bookId) async {
    await _firestore
        .collection(AppConstants.booksCollection)
        .doc(bookId)
        .delete();
  }

  // Swap Operations
  Future<void> initiateSwap(SwapModel swap) async {
    // Create swap document
    await _firestore
        .collection(AppConstants.swapsCollection)
        .doc(swap.id)
        .set(swap.toMap());

    // Update book status to Pending
    await _firestore
        .collection(AppConstants.booksCollection)
        .doc(swap.bookId)
        .update({'status': AppConstants.bookPending});
  }

  Stream<List<SwapModel>> getUserSwapsStream(String userId) {
    return _firestore
        .collection(AppConstants.swapsCollection)
        .where('fromUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SwapModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<SwapModel>> getReceivedSwapsStream(String userId) {
    return _firestore
        .collection(AppConstants.swapsCollection)
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: AppConstants.swapPending)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SwapModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> updateSwapStatus(String swapId, String status) async {
    await _firestore
        .collection(AppConstants.swapsCollection)
        .doc(swapId)
        .update({
          'status': status,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });

    // If swap is accepted or rejected, update book status accordingly
    if (status == AppConstants.swapAccepted) {
      // Get the swap to find the book ID
      DocumentSnapshot swapDoc = await _firestore
          .collection(AppConstants.swapsCollection)
          .doc(swapId)
          .get();
      if (swapDoc.exists) {
        String bookId = swapDoc['bookId'];
        await _firestore
            .collection(AppConstants.booksCollection)
            .doc(bookId)
            .update({'status': AppConstants.bookSwapped});
      }
    } else if (status == AppConstants.swapRejected) {
      // Get the swap to find the book ID
      DocumentSnapshot swapDoc = await _firestore
          .collection(AppConstants.swapsCollection)
          .doc(swapId)
          .get();
      if (swapDoc.exists) {
        String bookId = swapDoc['bookId'];
        await _firestore
            .collection(AppConstants.booksCollection)
            .doc(bookId)
            .update({'status': AppConstants.bookAvailable});
      }
    }
  }
}
