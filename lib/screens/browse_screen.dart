import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/swap_provider.dart';
import '../providers/user_auth_provider.dart';
import '../widgets/book_card.dart';
import '../models/swap_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Books'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: Provider.of<BookProvider>(context).allBooksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return const Center(
              child: Text(
                'No books available yet.\nBe the first to add a book!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                book: book,
                showSwapButton: true,
                onSwap: () {
                  _initiateSwap(context, book);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _initiateSwap(BuildContext context, book) {
    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to initiate swaps')),
      );
      return;
    }

    if (book.ownerId == currentUser.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot swap your own book')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Initiate Swap',
          style: TextStyle(color: AppColors.text),
        ),
        content: Text(
          'Are you sure you want to swap "${book.title}" with ${book.ownerName}?',
          style: TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textLight),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            onPressed: () async {
              Navigator.pop(context);

              // Create swap model
              final swapId = DateTime.now().millisecondsSinceEpoch.toString();
              final swap = SwapModel(
                id: swapId,
                bookId: book.id,
                bookTitle: book.title,
                fromUserId: currentUser.uid,
                fromUserName: currentUser.displayName ?? 'Unknown User',
                toUserId: book.ownerId,
                toUserName: book.ownerName,
                status: 'Pending',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              final success = await swapProvider.initiateSwap(swap);

              if (success && context.mounted) {
                // Create chat for this swap
                final firestoreService = FirestoreService();
                await firestoreService.getOrCreateChat(
                  [currentUser.uid, book.ownerId],
                  swapId,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Swap request sent for "${book.title}"'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Failed to send swap request: ${swapProvider.error}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Swap'),
          ),
        ],
      ),
    );
  }
}
