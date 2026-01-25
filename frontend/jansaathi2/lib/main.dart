import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import 'providers/auth_providers.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'home/home_screen.dart';
import 'screens/profile/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialize Firebase
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    // Run Google API connectivity test once at startup
    testGoogleConnectivity();
  }

  /// OPTIONAL TEST FUNCTION
  /// Verifies Google Maps / Places API key
  Future<void> testGoogleConnectivity() async {
    // ⚠️ Replace ONLY if you really want to test
    const String apiKey = "AIzaSyAwAtWAgagwjth7op7N9kYIlssFQfR8t5g";

    const String url =
        'https://places.googleapis.com/v1/places:searchNearby';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask': 'places.displayName',
        },
        body: '''
        {
          "includedTypes": ["police"],
          "maxResultCount": 1,
          "locationRestriction": {
            "circle": {
              "center": {"latitude": 0.0, "longitude": 0.0},
              "radius": 500.0
            }
          }
        }
        ''',
      );

      if (response.statusCode == 200) {
        debugPrint("✅ GOOGLE API VERIFIED: Key is working");
      } else {
        debugPrint("❌ GOOGLE API ERROR: ${response.statusCode}");
        debugPrint("DETAILS: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ NETWORK ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UGSSA App',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
