import 'package:flutter/material.dart';
import '../models/swap_model.dart';
import '../utils/constants.dart';

class SwapCard extends StatelessWidget {
  final SwapModel swap;
  final bool showActions;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onChat;

  const SwapCard({
    super.key,
    required this.swap,
    this.showActions = false,
    this.onAccept,
    this.onReject,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Title
            Text(
              swap.bookTitle,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),

            // Swap Info
            Row(
              children: [
                Icon(Icons.swap_horiz, size: 16.0, color: Colors.grey[600]),
                const SizedBox(width: 4.0),
                Text(
                  'From: ${swap.fromUserName}',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4.0),

            // Status and Chat Button Row
            Row(
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(swap.status),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    swap.status,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Spacer(),

                // Chat button for accepted swaps
                if (swap.status == AppConstants.swapAccepted && onChat != null)
                  IconButton(
                    onPressed: onChat,
                    icon: const Icon(Icons.chat),
                    color: AppColors.primary,
                    tooltip: 'Open Chat',
                  ),
              ],
            ),

            // Actions for pending swaps
            if (showActions && swap.status == AppConstants.swapPending)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Timestamp
            const SizedBox(height: 8.0),
            Text(
              'Created: ${_formatDate(swap.createdAt)}',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
