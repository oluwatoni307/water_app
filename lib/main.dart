import 'package:flutter/material.dart';
import 'package:water/Homepage.dart';
import 'package:water/goals/logPage.dart';
import 'login.dart';
import 'sign_up.dart';
import 'splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:water/logic.dart';
import 'goals/goalPage.dart';
import 'goals/metricPage.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => Data(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/splash',
      routes: {
        '/': (context) => WaterTrackScreen(),
        '/splash': (context) => SplashScreen(),
        '/log': (context) => Log(),

        '/goals': (context) => GoalPage(),
        '/metric': (context) => Metricpage(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => CreateAccountScreen(),
        // Add more routes as needed
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
