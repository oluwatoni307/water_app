import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:water/NotificationService.dart';
import 'package:water/model/userData.dart';
import 'logic.dart'; // contains AuthService & Data

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  // Validate email format with regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Validate all form inputs
  bool _validateInputs() {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your name');
      return false;
    }

    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your email');
      return false;
    }

    if (!_isValidEmail(_emailCtrl.text.trim())) {
      setState(() => _error = 'Please enter a valid email address');
      return false;
    }

    if (_pwCtrl.text.isEmpty) {
      setState(() => _error = 'Please enter a password');
      return false;
    }

    if (_pwCtrl.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return false;
    }

    return true;
  }

  Future<void> _signUp() async {
    // Reset error state and validate inputs first
    setState(() {
      _error = null;
    });

    if (!_validateInputs()) {
      return; // Validation failed
    }

    setState(() {
      _loading = true;
    });

    try {
      print("1. Starting sign-up with email: ${_emailCtrl.text.trim()}");

      // 1) Create auth user
      final cred = await AuthService().signUp(
        _emailCtrl.text.trim(),
        _pwCtrl.text.trim(),
      );

      final uid = cred.user!.uid;
      print("2. Auth user created with UID: $uid");
      DateTime today = DateTime.now();

      DateTime todayDate = DateTime(today.year, today.month, today.day);

      // 2) Create initial user document in Firestore
      final initial = UserData(
          _nameCtrl.text.trim(),
          0, // default goal
          {}, // empty metrics
          {}, // empty Day_Log
          {}, // empty lastLog
          {}, // empty nextLog
          uid,
          [],
          todayDate,
          []);

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(initial.toJson());
        print("3. Firestore document created");
      } on FirebaseException catch (e) {
        // Handle Firestore errors specifically
        _error = 'Database error: ${e.message}';
        // Clean up auth user if database setup fails
        await cred.user?.delete();
        throw e;
      }

      // 3) Initialize the Data provider with user data
      try {
        Provider.of<Data>(context, listen: false).updateFromDB(initial);
        print("4. Provider initialized with user data");
      } catch (e) {
        print("Provider update error: $e");
        _error = "Failed to initialize user data";
        // Consider how to recover from this error
      }

      // 4) Navigate to home
      print("5. Ready to navigate to home screen");

      Navigator.pushReplacementNamed(context, '/');

// Delay notification setup until after home screen is built
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await NotificationService().initialize();
        await NotificationService().scheduleHydrationNotifications();
      });
    } on FirebaseAuthException catch (e) {
      print("Auth error: ${e.code} - ${e.message}");

      // Provide user-friendly error messages based on Firebase error codes
      switch (e.code) {
        case 'email-already-in-use':
          _error = 'This email is already registered. Please log in instead.';
          break;
        case 'weak-password':
          _error = 'Please use a stronger password.';
          break;
        case 'invalid-email':
          _error = 'Please enter a valid email address.';
          break;
        default:
          _error = e.message ?? 'Sign up failed. Please try again.';
      }
    } catch (e) {
      print("Unexpected error: $e");
      _error = 'An unexpected error occurred. Please try again.';
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const SizedBox(height: 80),
              const Text('Create an account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Full Name', border: OutlineInputBorder()),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pwCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Password', border: OutlineInputBorder()),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signUp(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _loading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign Up', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Already have an account? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }
}
