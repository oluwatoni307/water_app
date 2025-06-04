import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water/NotificationService.dart';
import 'package:water/analysis.dart';
import 'package:water/profile_page.dart';

import 'Homepage.dart';
import 'goals/logPage.dart';
import 'login.dart';
import 'splash_screen.dart';
import 'logic.dart';
import 'goals/goalPage.dart';
import 'goals/metricPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
            apiKey: "AIzaSyD3bk305sdAiQsrycp4_rQbOaW4y9ipnrQ",
            authDomain: "water-3db9c.firebaseapp.com",
            projectId: "water-3db9c",
            storageBucket: "water-3db9c.firebasestorage.app",
            messagingSenderId: "236007535708",
            appId: "1:236007535708:web:499a65eb84b519ddc7e299",
            measurementId: "G-JFJVJCJDFV",
          )
        : null,
  );

  runApp(ChangeNotifierProvider(
    create: (context) => Data(),
    child: const MyApp(),
  ));
}

final Color primaryColor = const Color(0xFF2196F3); // Blue primary color
final Color secondaryColor = const Color(0xFF64B5F6); // Lighter blue secondary
final Color backgroundColor = const Color(0xFFF4F8FB); // Light background
final Color errorColor = Colors.red; // Error color

ThemeData getAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      secondary: secondaryColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: '/splash',
      theme: getAppTheme(),
      routes: {
        '/splash': (context) => SplashScreen(),
        '/log': (context) => Log(),
        '/settings': (context) => ProfilePage(),
        '/analysis': (context) => StatsScreen(),
        '/goals': (context) => GoalPage(),
        '/metric': (context) => Metricpage(),
        '/login': (context) => LoginScreen(),
        '/': (context) => WaterTrackScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
