import 'package:flutter/material.dart';
import '../models/book_model.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final bool showSwapButton;
  final VoidCallback? onSwap;

  const BookCard({
    super.key,
    required this.book,
    this.showSwapButton = false,
    this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Image
            Container(
              width: 80.0,
              height: 100.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[200],
                image: book.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(book.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: book.imageUrl.isEmpty
                  ? const Icon(Icons.book, size: 40.0, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16.0),

            // Book Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'by ${book.author}',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: _getConditionColor(book.condition),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          book.condition,
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        '• ${book.ownerName}',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Swap Button
            if (showSwapButton)
              IconButton(
                onPressed: onSwap,
                icon: const Icon(Icons.swap_horiz),
                color: Colors.green[800],
                tooltip: 'Swap this book',
              ),
          ],
        ),
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'New':
        return Colors.green;
      case 'Like New':
        return Colors.lightGreen;
      case 'Good':
        return Colors.orange;
      case 'Used':
        return Colors.orange[800]!;
      default:
        return Colors.grey;
    }
  }
}
