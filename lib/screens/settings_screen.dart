import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/user_auth_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserAuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          _buildSection(
            title: 'Profile',
            children: [
              _buildListTile(
                icon: Icons.person_outline,
                title: 'Name',
                subtitle: authProvider.currentUser?.displayName ?? 'Not set',
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: authProvider.currentUser?.email ?? 'Not set',
              ),
              _buildDivider(),
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  final isVerified = user?.emailVerified ?? false;
                  
                  return _buildListTile(
                    icon: Icons.verified_outlined,
                    title: 'Email Verified',
                    subtitle: isVerified ? 'Verified' : 'Not verified',
                    trailing: !isVerified ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () async {
                            await authProvider.refreshAuthState();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Status refreshed!')),
                              );
                            }
                          },
                          child: const Text('Refresh'),
                        ),
                        TextButton(
                          onPressed: () {
                            authProvider.resendVerification();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Verification email sent!')),
                            );
                          },
                          child: const Text('Resend'),
                        ),
                      ],
                    ) : null,
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Preferences Section
          _buildSection(
            title: 'Preferences',
            children: [
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive swap requests and messages',
                value: _pushNotifications,
                onChanged: (value) => setState(() => _pushNotifications = value),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.email_outlined,
                title: 'Email Notifications',
                subtitle: 'Receive email updates',
                value: _emailNotifications,
                onChanged: (value) => setState(() => _emailNotifications = value),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Account Section
          _buildSection(
            title: 'Account',
            children: [
              _buildListTile(
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                titleColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => _showSignOutDialog(context, authProvider),
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                titleColor: Colors.red[700],
                iconColor: Colors.red[700],
                onTap: () => _showDeleteAccountDialog(context, authProvider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor ?? AppColors.text,
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600]),
      ) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.secondary,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 56,
    );
  }

  void _showSignOutDialog(BuildContext context, UserAuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              authProvider.signOut();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, UserAuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Account', style: TextStyle(color: Colors.red[700])),
        content: const Text(
          'This action cannot be undone. All your data including books, swaps, and chats will be permanently deleted.\n\nAre you sure you want to delete your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () async {
              Navigator.pop(context);
              _showReauthDialog(context, authProvider);
            },
            child: const Text('Delete Account', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReauthDialog(BuildContext context, UserAuthProvider authProvider) {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your password to confirm account deletion:'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              bool success = await authProvider.deleteAccountWithPassword(passwordController.text);
              
              if (context.mounted) {
                Navigator.pop(context); // Close loading
                
                if (success) {
                  Navigator.pushReplacementNamed(context, '/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account deleted successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authProvider.error ?? 'Failed to delete account')),
                  );
                }
              }
            },
            child: const Text('Delete Account', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}