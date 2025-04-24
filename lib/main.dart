import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water/analysis.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/log': (context) => Log(),
        '/analysis': (context) => StatsScreen(),
        '/goals': (context) => GoalPage(),
        '/metric': (context) => Metricpage(),
        '/': (context) => WaterTrackScreen(),
        '/login': (context) => StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen(); // or loader
                }

                if (snapshot.hasData) {
                  // Firebase restored session — safe to init
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final data = Provider.of<Data>(context, listen: false);
                    data.initialize(); // 👈 safe place to call now
                  });
                  return const WaterTrackScreen();
                } else {
                  return const LoginScreen();
                }
              },
            ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
