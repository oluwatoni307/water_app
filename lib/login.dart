import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:water/NotificationService.dart';
import 'package:water/forgetPasword.dart';
import 'package:water/sign_up.dart';
import 'logic.dart'; // contains AuthService & Data
import 'Homepage.dart'; // your post‑login landing page

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  String? _error;
  bool _loading = false;
  final _pwCtrl = TextEditingController();

  void _initializeNotificationsAsync() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.scheduleNotifications();
      debugPrint('✅ WorkManager hydration reminders started successfully');
    } catch (e) {
      debugPrint('⚠️ Notification setup failed: $e');
    }
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // 1) Sign in
      // ignore: unused_local_variable
      final cred = await AuthService().signIn(
        _emailCtrl.text.trim(),
        _pwCtrl.text.trim(),
      );

      // 2) (Optional) pre‑fetch user data via your Data provider
      //    If you're using Provider/riverpod, you'd do:
      //    context.read<Data>()._initialize();
      //
      //    Otherwise, Data() constructor already starts listening.
      // Run initialize() safely after the first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final data = Provider.of<Data>(context, listen: false);
        data.initialize();
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WaterTrackScreen()),
      );
      _initializeNotificationsAsync();

// Post-frame: safe to initialize services
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Unexpected error: $e';
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 70,
              padding: EdgeInsets.fromLTRB(15, 20, 0, 5),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Row(
                children: [
                  Image.asset(
                    'images/logo.png',
                    width: 70,
                    height: 70,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Stay on track,\nStay hydrated!",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Stay hydrated, stay healthy - track your water intake daily and fuel your body\'s best performance!',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _pwCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Password', border: OutlineInputBorder()),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordPage()),
                          );
                        },
                        child: const Text("Forgot Password?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Log in', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)),
                  ),
                  const SizedBox(height: 27),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpScreen()),
                          );
                        },
                        child: const Text("Don't have an account? Sign up",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
