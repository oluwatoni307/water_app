import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:water/model/userData.dart';

/// Service to handle Firebase Authentication
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the UID of the current user, or throws if not signed in.
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

  /// Signs in with email and password.
  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  /// Registers a new user with email and password.
  Future<UserCredential> signUp(String email, String password) =>
      _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

  /// Signs out the current user.
  Future<void> signOut() => _auth.signOut();
}

/// Data provider syncing UserData with Firestore in real time.
class Data extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  late final DocumentReference<Map<String, dynamic>> _docRef;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  UserData _user = UserData('', 0, {}, {}, {}, {}, '');
  UserData get user => _user;

  Data() {
    _initialize();
  }

  /// Initializes Firestore reference and listeners.
  Future<void> _initialize() async {
    try {
      final uid = await _authService.getCurrentUID();
      _docRef = _firestore.collection('users').doc(uid);

      // Load existing data
      final snapshot = await _docRef.get();
      if (snapshot.exists && snapshot.data() != null) {
        _user = UserData.fromJson(snapshot.data()!);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Initialization error: $e');
    }
  }

  /// Persists the current user data to Firestore.
  Future<void> _save() async {
    try {
      await _docRef.set(_user.toJson());
    } catch (e) {
      if (kDebugMode) print('Firestore save error: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Overwrites data locally and remotely.
  void updateFromDB(UserData userData) {
    _user = userData;
    _save();
    notifyListeners();
  }

  /// Updates the user's goal.
  void setGoals(String goal) {
    _user.goal = int.tryParse(goal) ?? 0;
    _save();
    notifyListeners();
  }

  /// Updates the user's metrics map.
  void setMetrics(Map<String, int> metrics) {
    _user.metric = Map.from(metrics);
    _save();
    notifyListeners();
  }

  /// Logs a water intake at the current timestamp.
  void log(int amount) {
    final now = DateTime.now();
    final timestamp = Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
      milliseconds: now.millisecond,
    );
    _user.Day_Log[timestamp] = amount;
    _user.lastLog = {timestamp: amount};
    _save();
    notifyListeners();
  }

  /// Calculates the next reminder time and suggested amount.
  (DateTime, int) calculateNextReminder() {
    const double defaultInterval = 1.0;
    const int defaultAmount = 250;
    const double minInterval = 0.5;
    const double maxInterval = 3.0;
    const int startHour = 7;
    const int endHour = 23;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, startHour);
    final end = DateTime(now.year, now.month, now.day, endHour);

    if (_user.Day_Log.isEmpty) {
      final next = now.add(Duration(hours: defaultInterval.toInt()));
      final reminder = next.isAfter(end) ? end : next;
      _user.nextLog = {
        reminder.difference(DateTime(now.year, now.month, now.day)):
            defaultAmount
      };
      _save();
      return (reminder, defaultAmount);
    }

    // Compute elapsed and expected intake
    final elapsed = now.isAfter(start) ? now.difference(start) : Duration.zero;
    final totalTime = end.difference(start).inMinutes;
    final expected =
        totalTime > 0 ? _user.goal * (elapsed.inMinutes / totalTime) : 0.0;
    final consumed = _user.Day_Log.values.fold(0, (sum, a) => sum + a);
    final ratio = expected > 0 ? consumed / expected : 1.0;
    final factor = ratio.clamp(0.5, 2.0);

    // Average interval
    final times = _user.Day_Log.keys.toList()..sort();
    final avgInterval = times.length >= 2
        ? times
                .skip(1)
                .map((t) => (t - times[times.indexOf(t) - 1]).inMinutes / 60)
                .reduce((a, b) => a + b) /
            (times.length - 1)
        : defaultInterval;

    final intervalHours =
        (factor * avgInterval).clamp(minInterval, maxInterval);
    final lastTime = DateTime(now.year, now.month, now.day).add(times.last);
    var nextReminder =
        lastTime.add(Duration(minutes: (intervalHours * 60).round()));
    if (nextReminder.isBefore(now))
      nextReminder = now.add(Duration(minutes: 5));
    if (nextReminder.isAfter(end)) nextReminder = end;

    final remaining = _user.goal - consumed;
    final remainingTime = end.difference(nextReminder).inMinutes;
    final slots =
        remainingTime > 0 ? (remainingTime / (intervalHours * 60)).ceil() : 1;
    int suggestion = slots > 0 ? (remaining / slots).round() : remaining;
    if (ratio < 1) suggestion = (suggestion * 1.15).round();

    _user.nextLog = {
      nextReminder.difference(DateTime(now.year, now.month, now.day)):
          suggestion
    };
    _save();
    return (nextReminder, suggestion);
  }

  /// Clears daily logs.
  void resetDaily() {
    _user.Day_Log.clear();
    _user.lastLog.clear();
    _user.nextLog.clear();
    _save();
    notifyListeners();
  }
}
