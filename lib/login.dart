import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final _pwCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  /// Initialize notifications asynchronously without blocking user flow
  void _initializeNotificationsAsync() async {
    try {
      await NotificationService().initialize();
      await NotificationService().scheduleHydrationNotifications();
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
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Text('Hi, Welcome!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Log in', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    child: const Text("Don't have an account? Sign up",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage()),
                      );
                    },
                    child: Text("Forgot Password?",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
