import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_video_app/providers/auth_provider.dart';
import 'package:flutter_video_app/providers/video_provider.dart';
import 'package:flutter_video_app/providers/favorites_provider.dart';
import 'package:flutter_video_app/providers/watch_history_provider.dart';
import 'package:flutter_video_app/screens/home_screen.dart';
import 'package:flutter_video_app/screens/login_screen.dart';
import 'package:flutter_video_app/utils/theme.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    // Initialize Stripe
    Stripe.publishableKey =
        'pk_test_51RY4uWFJqSjpkwgibRAHFiYNTc4eNQGFOT9dJqy2SMaDXCmEqpPLREjn8tzwljV20rlbMj0CoxZZA2sO2JGAaK4X00TQgsctYR';

    try {
      await Stripe.instance.applySettings();
    } catch (e) {
      print('Stripe initialization error (expected on web): $e');
      // Continue execution as web platform may not support all Stripe features
    }
  }

  // Initialize Google Sign In based on platform
  try {
    if (!kIsWeb && Platform.isAndroid) {
      await GoogleSignIn().signOut();
      GoogleSignIn.standard();
    }
  } catch (e) {
    print('Platform check error (expected on web): $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _sessionCheckTimer;

  @override
  void dispose() {
    _sessionCheckTimer?.cancel();
    super.dispose();
  }

  void _startSessionCheck(AuthProvider authProvider) {
    _sessionCheckTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      authProvider.checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = AuthProvider();
            _startSessionCheck(provider);
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => WatchHistoryProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Video Streaming',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            if (!auth.isInitialized) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return auth.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
