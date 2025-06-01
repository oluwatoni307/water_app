import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  late final Box _localBox;
  Timer? _dailyTimer;

  UserData _user = UserData('', 0, {}, {}, {}, {}, '', [], DateTime.now(), []);

  UserData get user => _user;

  Data();

  bool get isSignUp => _isSignUp;

  Future<void> initialize() async {
    try {
      // Initialize Hive box for local storage
      await Hive.initFlutter();
      _localBox = await Hive.openBox('userData');

      final uid = await _authService.getCurrentUID();
      _docRef = _firestore.collection('users').doc(uid);

      // Try to load from local database first
      final localData = _localBox.get(uid);
      bool loadedFromLocal = false;

      if (localData != null) {
        try {
          _user = UserData.fromJson(Map<String, dynamic>.from(localData));
          loadedFromLocal = true;
          if (kDebugMode) print('Loaded user data from local database');
        } catch (e) {
          if (kDebugMode) print('Error loading from local DB: $e');
        }
      }

      // Check date logic for day rollover
      if (loadedFromLocal) {
        await _checkAndUpdateDayRollover();
        notifyListeners();
      }

      // Try to fetch from Firebase (either as primary or backup)
      try {
        final snapshot = await _docRef.get();
        if (snapshot.exists && snapshot.data() != null) {
          final firebaseUser = UserData.fromJson(snapshot.data()!);

          // If we didn't have local data, use Firebase data
          if (!loadedFromLocal) {
            _user = firebaseUser;
            await _checkAndUpdateDayRollover();
            // Save to local for next time
            await _saveToLocal();
            if (kDebugMode) print('Loaded user data from Firebase');
          } else {
            // Optional: Could implement simple comparison/merge logic here
            // For now, we trust local data and update Firebase silently
            await _saveToFirebase();
          }

          notifyListeners();
        }
      } catch (e) {
        if (kDebugMode) print('Firebase fetch error (offline?): $e');
        // If we have local data, continue with that
        if (!loadedFromLocal) {
          // No local data and no Firebase - this is a problem
          throw Exception(
              'No data available offline and cannot reach Firebase');
        }
      }

      _scheduleDailySave();
    } catch (e) {
      if (kDebugMode) print('Initialization error: $e');
      rethrow;
    }
  }

  Future<void> _checkAndUpdateDayRollover() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (_user.Log.isNotEmpty || _user.Day_Log.isNotEmpty) {
      final lastLogDate = _user.currentDate;
      final lastDate =
          DateTime(lastLogDate.year, lastLogDate.month, lastLogDate.day);

      if (todayDate.isAfter(lastDate)) {
        await finishDay();
        if (kDebugMode) print("Day rollover updated");
      }
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
    // Save to local first (fast and reliable)
    await _saveToLocal();

    // Attempt to save to Firebase (may fail silently if offline)
    await _saveToFirebase();
  }

  Future<void> _saveToLocal() async {
    try {
      final uid = await _authService.getCurrentUID();
      await _localBox.put(uid, _user.toJson());
    } catch (e) {
      if (kDebugMode) print('Local save error: $e');
    }
  }

  Future<void> _saveToFirebase() async {
    try {
      await _docRef.set(_user.toJson());
    } catch (e) {
      if (kDebugMode) print('Firebase save error (offline?): $e');
      // Don't rethrow - app should continue working with local data
    }
  }

  @override
  void dispose() {
    _dailyTimer?.cancel();
    _localBox.close();
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

    // Calculate and log today's intake
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
