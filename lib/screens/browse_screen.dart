import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/swap_provider.dart';
import '../providers/user_auth_provider.dart';
import '../widgets/book_card.dart';
import '../models/swap_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Browse Books'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search books...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          
          // Books List
          Expanded(
            child: StreamBuilder(
              stream: Provider.of<BookProvider>(context).allBooksStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final allBooks = snapshot.data ?? [];
                final filteredBooks = _searchQuery.isEmpty
                    ? allBooks
                    : allBooks.where((book) =>
                        book.title.toLowerCase().contains(_searchQuery) ||
                        book.author.toLowerCase().contains(_searchQuery) ||
                        book.condition.toLowerCase().contains(_searchQuery)).toList();

                if (allBooks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.library_books_outlined, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 24),
                        Text(
                          'No books available',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to add a book!',
                          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredBooks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No books found',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try different search terms',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBooks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    return BookCard(
                      book: book,
                      showSwapButton: true,
                      onSwap: () => _initiateSwap(context, book),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Initiate Swap'),
        content: Text('Send a swap request for "${book.title}" to ${book.ownerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              navigator.pop();

              final swapId = DateTime.now().millisecondsSinceEpoch.toString();
              final swap = SwapModel(
                id: swapId,
                bookId: book.id,
                bookTitle: book.title,
                fromUserId: currentUser.uid,
                fromUserName: currentUser.displayName.isNotEmpty ? currentUser.displayName : 'Unknown User',
                toUserId: book.ownerId,
                toUserName: book.ownerName,
                status: 'Pending',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              final success = await swapProvider.initiateSwap(swap);

              if (success) {
                final firestoreService = FirestoreService();
                await firestoreService.getOrCreateChat(
                  [currentUser.uid, book.ownerId],
                  swapId,
                );

                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Swap request sent for "${book.title}"'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to send swap request: ${swapProvider.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}