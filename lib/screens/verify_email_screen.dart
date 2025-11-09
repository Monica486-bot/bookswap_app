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

class _VerifyEmailScreenState extends State<VerifyEmailScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  bool _isChecking = false;
  bool _isVerified = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check verification when user returns to app
    if (state == AppLifecycleState.resumed && mounted) {
      _checkVerification();
    }
  }

  Future<void> _checkVerification() async {
    if (!mounted) return;
    
    setState(() {
      _isChecking = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Aggressive verification checking
        for (int i = 0; i < 3; i++) {
          await user.reload();
          await user.getIdToken(true);
          await Future.delayed(const Duration(milliseconds: 200));
          
          if (!mounted) return;
          
          final updatedUser = FirebaseAuth.instance.currentUser;
          if (updatedUser != null && updatedUser.emailVerified) {
            if (mounted) {
              setState(() {
                _isVerified = true;
                _isChecking = false;
              });
            }
            
            // Navigate immediately
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            });
            return;
          }
        }
        
        if (mounted) {
          setState(() {
            _isChecking = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not verified yet. Please check your inbox and click the verification link.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserAuthProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    if (_isVerified) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.secondary,
                AppColors.secondary.withValues(alpha: 0.8),
                AppColors.primary.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    const Text(
                      'Email Verified!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Your email has been successfully verified.\nTaking you to the app...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.secondary.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: ClipRect(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Column(
                children: [
                  // Top Section with Icon
                  Expanded(
                    flex: 2,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.mark_email_read_outlined,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Verify Your Email',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Almost there! Just one more step',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Bottom Section with Content
                  Expanded(
                    flex: 3,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'Check Your Inbox',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.email_outlined, color: AppColors.secondary, size: 32),
                                    const SizedBox(height: 12),
                                    Text(
                                      user?.email ?? 'your email address',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'We\'ve sent a verification link to your email address. Please check your inbox and click the link to verify your account.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // Check Verification Button
                              _buildGradientButton(
                                onPressed: _isChecking ? null : _checkVerification,
                                child: _isChecking
                                    ? const SizedBox(
                                        height: 20.0,
                                        width: 20.0,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                              const SizedBox(height: 16),
                              
                              // Resend Button
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.secondary),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: OutlinedButton(
                                  onPressed: () {
                                    authProvider.resendVerification();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Verification email sent! Check your inbox.'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    side: BorderSide.none,
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
                              
                              // Debug: Show current status
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Debug Info:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    Text(
                                      'Email Verified: ${user?.emailVerified ?? false}',
                                      style: TextStyle(color: AppColors.textLight),
                                    ),
                                    Text(
                                      'User ID: ${user?.uid ?? 'None'}',
                                      style: TextStyle(color: AppColors.textLight, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const Spacer(),
                              
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
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return ClipRect(
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: child,
        ),
      ),
    );
  }
}
