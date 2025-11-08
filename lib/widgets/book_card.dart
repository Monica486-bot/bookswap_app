import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../utils/constants.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final bool showSwapButton;
  final VoidCallback? onSwap;
  final bool showEditDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BookCard({
    super.key,
    required this.book,
    this.showSwapButton = false,
    this.onSwap,
    this.showEditDelete = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.card,
              AppColors.card.withValues(alpha: 0.8),
            ],
          ),
        ),
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
                  borderRadius: BorderRadius.circular(12.0),
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: book.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(book.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: book.imageUrl.isEmpty
                    ? Icon(Icons.book, size: 40.0, color: AppColors.textLight)
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
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'by ${book.author}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: AppColors.textLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: _getConditionColor(book.condition),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            book.condition,
                            style: const TextStyle(
                              fontSize: 10.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(book.status),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            book.status,
                            style: const TextStyle(
                              fontSize: 10.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16.0,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          book.ownerName,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              if (showEditDelete)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit),
                        color: Colors.white,
                        tooltip: 'Edit book',
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete),
                        color: Colors.white,
                        tooltip: 'Delete book',
                      ),
                    ),
                  ],
                )
              else if (showSwapButton && book.status == 'Available')
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: onSwap,
                    icon: const Icon(Icons.swap_horiz),
                    color: Colors.white,
                    tooltip: 'Swap this book',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'New':
        return AppColors.success;
      case 'Like New':
        return const Color(0xFF27AE60);
      case 'Good':
        return AppColors.warning;
      case 'Used':
        return const Color(0xFFE67E22);
      default:
        return AppColors.textLight;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return AppColors.secondary;
      case 'Pending':
        return AppColors.warning;
      case 'Swapped':
        return AppColors.success;
      default:
        return AppColors.textLight;
    }
  }
}
