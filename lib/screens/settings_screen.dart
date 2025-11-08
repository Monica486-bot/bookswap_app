import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/user_auth_provider.dart';
import '../utils/constants.dart';
import 'my_offers_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserAuthProvider>(context); // Updated

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Name'),
                    subtitle: Text(
                      authProvider.currentUser?.displayName ?? 'Not set',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(
                      authProvider.currentUser?.email ?? 'Not set',
                    ),
                  ),
                  StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      final user = snapshot.data;
                      final isVerified = user?.emailVerified ?? false;
                      
                      return ListTile(
                        leading: const Icon(Icons.verified),
                        title: const Text('Email Verified'),
                        subtitle: Text(isVerified ? 'Yes' : 'No'),
                        trailing: !isVerified
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await authProvider.refreshAuthState();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Status refreshed!'),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Refresh'),
                              ),
                              TextButton(
                                onPressed: () {
                                  authProvider.resendVerification();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Verification email sent!'),
                                    ),
                                  );
                                },
                                child: const Text('Resend'),
                              ),
                            ],
                          )
                        : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // My Activity Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Activity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: const Text('My Offers'),
                    subtitle: const Text('View your swap requests'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyOffersScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Preferences Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferences',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive swap requests and messages'),
                    value: true,
                    onChanged: (value) {
                      // TODO: Implement notification preferences
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive email updates'),
                    value: true,
                    onChanged: (value) {
                      // TODO: Implement email preferences
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Account Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ListTile(
                    leading: Icon(Icons.logout, color: AppColors.error),
                    title: Text(
                      'Sign Out',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text(
                            'Are you sure you want to sign out?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                authProvider.signOut();
                                Navigator.pop(context);
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              },
                              child: Text(
                                'Sign Out',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
