import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // Add this to your pubspec.yaml

import 'providers/auth_providers.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'home/home_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // TEST FUNCTION: This verifies if your restricted API Key is actually working
  Future<void> testGoogleConnectivity() async {
    // 1. Replace with the EXACT key you put in AndroidManifest.xml
    const String apiKey = "YOUR_ACTUAL_API_KEY"; 
    
    // 2. We use the New Places API endpoint for testing
    const String url = 'https://places.googleapis.com/v1/places:searchNearby';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask': 'places.displayName',
        },
        body: '{"includedTypes": ["police"], "maxResultCount": 1, "locationRestriction": {"circle": {"center": {"latitude": 0.0, "longitude": 0.0}, "radius": 500.0}}}',
      );

      if (response.statusCode == 200) {
        debugPrint("✅ GOOGLE API VERIFIED: Your key is working and authorized!");
      } else {
        debugPrint("❌ GOOGLE API ERROR: ${response.statusCode}");
        debugPrint("DETAILS: ${response.body}");
        // If you see "REQUEST_DENIED", your SHA-1 fingerprint or Package Name is wrong in the console.
      }
    } catch (e) {
      debugPrint("❌ NETWORK ERROR: Make sure your emulator has internet.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Run the connectivity test as soon as the app starts
    testGoogleConnectivity();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UGSSA App',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}