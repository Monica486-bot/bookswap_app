import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: currentIndex == 0 ? AppColors.secondary.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.explore_outlined),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.explore),
            ),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: currentIndex == 1 ? AppColors.secondary.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.book_outlined),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.book),
            ),
            label: 'My Books',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: currentIndex == 2 ? AppColors.secondary.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat_bubble),
            ),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: currentIndex == 3 ? AppColors.secondary.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.settings_outlined),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.settings),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}