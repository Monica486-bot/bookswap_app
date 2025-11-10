import 'package:flutter/material.dart';
import 'browse_screen.dart';
import 'my_listings_screen.dart';
import 'my_offers_screen.dart';
import 'chats_screen.dart';
import 'settings_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Start on Browse screen

  final List<Widget> _screens = [
    const BrowseScreen(),
    const MyListingsScreen(),
    const MyOffersScreen(),
    const ChatsScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
