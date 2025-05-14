import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:water/model/userData.dart';

bool _isSignUp = false;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUID() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'NO_CURRENT_USER',
        message: 'No user is currently signed in.',
      );
    }
    return user.uid;
  }

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signUp(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    _isSignUp = true;
    return userCredential;
  }

  Future<void> signOut() => _auth.signOut();
}

class Data extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  late final DocumentReference<Map<String, dynamic>> _docRef;
  Timer? _dailyTimer;

  UserData _user = UserData('', 0, {}, {}, {}, {}, '', [], DateTime.now(), []);

  UserData get user => _user;

  Data();

  bool get isSignUp => _isSignUp;

  Future<void> initialize() async {
    try {
      final uid = await _authService.getCurrentUID();
      _docRef = _firestore.collection('users').doc(uid);

      final snapshot = await _docRef.get();
      if (snapshot.exists && snapshot.data() != null) {
        _user = UserData.fromJson(snapshot.data()!);

        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);

        if (_user.Log.isNotEmpty) {
          final lastLogDate = _user.currentDate;
          final lastDate =
              DateTime(lastLogDate.year, lastLogDate.month, lastLogDate.day);
          if (todayDate.isAfter(lastDate)) {
            await finishDay();
            print("updated");
          }
        } else if (_user.Day_Log.isNotEmpty) {
          // Get the first duration timestamp in Day_Log
          final firstKey = _user.Day_Log.keys.first;
          final time = DateTime(today.year, today.month, today.day)
              .add(firstKey); // Combine duration with today
          final logDate = DateTime(time.year, time.month, time.day);
          if (logDate.isBefore(todayDate)) {
            await finishDay();
          }
        }

        notifyListeners();
      }

      _scheduleDailySave();
    } catch (e) {
      if (kDebugMode) print('Initialization error: $e');
    }
  }

  void _scheduleDailySave() {
    final now = DateTime.now();
    final nextMidnight =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final initialDelay = nextMidnight.difference(now);

    _dailyTimer?.cancel();
    _dailyTimer = Timer(initialDelay, () async {
      await finishDay();
      _scheduleDailySave();
    });
  }

  Future<void> _save() async {
    try {
      await _docRef.set(_user.toJson());
    } catch (e) {
      if (kDebugMode) print('Firestore save error: $e');
    }
  }

  @override
  void dispose() {
    _dailyTimer?.cancel();
    super.dispose();
  }

  Future<void> updateFromDB(UserData userData) async {
    _user = userData;
    await _save();
    notifyListeners();
  }

  Future<void> setGoals(String goal) async {
    _user.goal = int.tryParse(goal) ?? 0;
    _user.Day_Log.clear();
    _user.lastLog.clear();
    _user.nextLog.clear();
    await _save();
    notifyListeners();
  }

  Future<void> setMetrics(Map<String, int> metrics) async {
    _user.metric = Map.from(metrics);
    await _save();
    notifyListeners();
  }

  Future<void> log(int amount) async {
    final now = DateTime.now();
    final timestamp = Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
      milliseconds: now.millisecond,
    );

    _user.Day_Log[timestamp] = amount;
    _user.lastLog = {timestamp: amount};
    await _save();
    notifyListeners();
  }

  Future<void> finishDay() async {
    final now = DateTime.now();
    final current = DateTime(
        _user.currentDate.year, _user.currentDate.month, _user.currentDate.day);
    final today = DateTime(now.year, now.month, now.day);

    final daysDifference = today.difference(current).inDays;

    // Fill in 0 for missed days (excluding today)
    for (int i = 0; i < daysDifference; i++) {
      _user.Log.add(0);
      _user.completed.add(false);
    }

    // Calculate and log today’s intake
    final totalIntake = _user.Day_Log.values.fold(0, (sum, a) => sum + a);
    _user.Log.add(totalIntake);

    // Update currentDate to today
    _user.currentDate = today;

    await _save();
    await resetDaily();
    notifyListeners();
  }

  Future<void> resetDaily() async {
    _user.Day_Log.clear();
    _user.lastLog.clear();
    _user.nextLog.clear();
    await _save();
    notifyListeners();
  }
}
