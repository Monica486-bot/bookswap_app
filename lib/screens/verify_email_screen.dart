import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/user_auth_provider.dart';
import '../utils/constants.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isChecking = false;
  bool _isVerified = false;

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
    });

    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);

    // Check verification status
    final bool isVerified = await authProvider.checkEmailVerification();

    if (isVerified) {
      // If verified, refresh the auth state and navigate to home
      await authProvider.refreshAuthState();
      setState(() {
        _isVerified = true;
        _isChecking = false;
      });

      // Navigate to home screen after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    } else {
      setState(() {
        _isChecking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not verified yet. Please check your inbox.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserAuthProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    if (_isVerified) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 80.0,
                  color: AppColors.success,
                ),
                const SizedBox(height: 32.0),
                Text(
                  'Email Verified!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Your email has been successfully verified. Taking you to the app...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 32.0),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Icon(
                Icons.mark_email_read_outlined,
                size: 80.0,
                color: AppColors.primary,
              ),
              const SizedBox(height: 32.0),

              // Title
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 16.0),

              // Description
              Text(
                'We\'ve sent a verification link to ${user?.email ?? 'your email address'}.\n\n'
                'Please check your inbox and click the link to verify your account.\n\n'
                'After clicking the link, come back here and tap the button below.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 40.0),

              // Check Verification Button
              SizedBox(
                width: double.infinity,
                height: 56.0,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'I\'ve Verified My Email',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Resend Button
              SizedBox(
                width: double.infinity,
                height: 56.0,
                child: OutlinedButton(
                  onPressed: () {
                    authProvider.resendVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Verification email sent! Check your inbox.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    side: BorderSide(color: AppColors.secondary),
                  ),
                  child: Text(
                    'Resend Verification Email',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Sign Out Button
              TextButton(
                onPressed: () {
                  authProvider.signOut();
                },
                child: Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
