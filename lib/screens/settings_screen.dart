import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green[800],
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
                  ListTile(
                    leading: const Icon(Icons.verified),
                    title: const Text('Email Verified'),
                    subtitle: Text(
                      authProvider.currentUser?.emailVerified == true
                          ? 'Yes'
                          : 'No',
                    ),
                    trailing: authProvider.currentUser?.emailVerified == false
                        ? TextButton(
                            onPressed: () {
                              authProvider.resendVerification();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Verification email sent!'),
                                ),
                              );
                            },
                            child: const Text('Resend'),
                          )
                        : null,
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
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.red),
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
                              child: const Text(
                                'Sign Out',
                                style: TextStyle(color: Colors.red),
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
