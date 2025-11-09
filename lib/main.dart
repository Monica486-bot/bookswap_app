import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';

import 'providers/user_auth_provider.dart';
import 'providers/book_provider.dart';
import 'providers/swap_provider.dart';
import 'providers/chat_provider.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Disable all debug visual indicators
  debugPaintSizeEnabled = false;
  debugRepaintRainbowEnabled = false;

  // Override RenderErrorBox to suppress overflow warnings
  RenderErrorBox.backgroundColor = Colors.transparent;

  runApp(const BookSwapApp());
}

class BookSwapApp extends StatelessWidget {
  const BookSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserAuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => SwapProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'BookSwap',
        builder: (context, widget) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return Container();
          };
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: widget!,
          );
        },
        theme: ThemeData.light().copyWith(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            tertiary: AppColors.accent,
            surface: AppColors.surface,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: AppColors.text,
          ),
          scaffoldBackgroundColor: AppColors.background,
          cardColor: AppColors.card,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: AppColors.textLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: AppColors.secondary, width: 2),
            ),
            labelStyle: TextStyle(color: AppColors.textLight),
            hintStyle: TextStyle(color: AppColors.textLight),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              elevation: 2,
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            color: AppColors.card,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          textTheme: TextTheme(
            headlineMedium: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
            titleLarge: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
            bodyLarge: TextStyle(
              fontSize: 16.0,
              color: AppColors.text,
            ),
            bodyMedium: TextStyle(
              fontSize: 14.0,
              color: AppColors.textLight,
            ),
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/verify-email': (context) => const VerifyEmailScreen(),
          '/home': (context) => const HomeScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final authProvider =
          Provider.of<UserAuthProvider>(context, listen: false);
      authProvider.checkEmailVerification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserAuthProvider>(
      builder: (context, authProvider, child) {
        return StreamBuilder<User?>(
          stream: authProvider.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (!snapshot.hasData) {
              return const LoginScreen();
            }

            final user = snapshot.data!;

            if (!user.emailVerified) {
              return const VerifyEmailScreen();
            } else {
              return const HomeScreen();
            }
          },
        );
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.book,
              size: 80.0,
              color: Colors.white,
            ),
            const SizedBox(height: 20.0),
            Text(
              'BookSwap',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Swap textbooks with fellow students',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 30.0),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
