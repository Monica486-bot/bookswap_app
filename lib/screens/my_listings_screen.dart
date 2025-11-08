import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_auth_provider.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';
import 'add_book_screen.dart';
import 'edit_book_screen.dart';
import '../utils/constants.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  void _editBook(BuildContext context, book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBookScreen(book: book),
      ),
    );
  }

  void _deleteBook(BuildContext context, book) {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete Book', style: TextStyle(color: AppColors.text)),
        content: Text(
          'Are you sure you want to delete "${book.title}"? This action cannot be undone.',
          style: TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textLight)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await bookProvider.deleteBook(book);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? 'Book deleted successfully!' 
                        : 'Failed to delete book: ${bookProvider.error}',
                    ),
                    backgroundColor: success ? AppColors.success : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserAuthProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Books'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddBookScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBookScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder(
        stream: bookProvider.userBooksStream(
          authProvider.currentUser?.uid ?? '',
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book,
                    size: 80.0,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'No books listed yet.\nAdd your first book to start swapping!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                ],
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
                showEditDelete: true,
                onEdit: () => _editBook(context, book),
                onDelete: () => _deleteBook(context, book),
              );
            },
          );
        },
      ),
    );
  }
}
