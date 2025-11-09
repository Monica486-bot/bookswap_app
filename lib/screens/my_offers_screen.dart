import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_auth_provider.dart';
import '../providers/swap_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/swap_card.dart';
import 'chat_screen.dart';
import '../utils/constants.dart';
import '../models/swap_model.dart';
import '../models/user_model.dart';

class MyOffersScreen extends StatelessWidget {
  const MyOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserAuthProvider>(context);
    final swapProvider = Provider.of<SwapProvider>(context);
    final firestoreService = FirestoreService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Offers'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Sent'),
              Tab(text: 'Received'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Sent Swaps Tab
            StreamBuilder(
              stream: swapProvider
                  .sentSwapsStream(authProvider.currentUser?.uid ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final swaps = snapshot.data ?? [];

                if (swaps.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.swap_horiz,
                            size: 60.0,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'No swap offers sent yet',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Browse books to start swapping',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: swaps.length,
                  itemBuilder: (context, index) {
                    final swap = swaps[index];
                    return SwapCard(
                      swap: swap,
                      onChat: swap.status == AppConstants.swapAccepted
                          ? () => _openChat(
                                context,
                                swap,
                                firestoreService,
                                authProvider.currentUser!,
                              )
                          : null,
                    );
                  },
                );
              },
            ),

            // Received Swaps Tab
            StreamBuilder(
              stream: swapProvider
                  .receivedSwapsStream(authProvider.currentUser?.uid ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final swaps = snapshot.data ?? [];

                if (swaps.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.inbox_outlined,
                            size: 60.0,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'No swap offers received yet',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Others will see your books and send offers',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: swaps.length,
                  itemBuilder: (context, index) {
                    final swap = swaps[index];
                    return SwapCard(
                      swap: swap,
                      showActions: swap.status == AppConstants.swapPending,
                      onAccept: () =>
                          _acceptSwap(context, swapProvider, swap.id),
                      onReject: () =>
                          _rejectSwap(context, swapProvider, swap.id),
                      onChat: swap.status == AppConstants.swapAccepted
                          ? () => _openChat(
                                context,
                                swap,
                                firestoreService,
                                authProvider.currentUser!,
                              )
                          : null,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptSwap(
      BuildContext context, SwapProvider swapProvider, String swapId) async {
    final success = await swapProvider.acceptSwap(swapId);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Swap accepted!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept swap: ${swapProvider.error}')),
      );
    }
  }

  Future<void> _rejectSwap(
      BuildContext context, SwapProvider swapProvider, String swapId) async {
    final success = await swapProvider.rejectSwap(swapId);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Swap rejected.'),
          backgroundColor: AppColors.warning,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject swap: ${swapProvider.error}')),
      );
    }
  }

  Future<void> _openChat(
    BuildContext context,
    SwapModel swap,
    FirestoreService firestoreService,
    UserModel currentUser,
  ) async {
    try {
      // Create participants list
      final participants = [swap.fromUserId, swap.toUserId];

      // Get or create chat
      final chatId = await firestoreService.getOrCreateChat(
        participants,
        swap.id,
      );

      // Determine the other user's name for display
      final otherUserName = currentUser.uid == swap.fromUserId
          ? swap.toUserName
          : swap.fromUserName;

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              otherUserName: otherUserName,
              swapId: swap.id,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open chat: $e')),
        );
      }
    }
  }
}
