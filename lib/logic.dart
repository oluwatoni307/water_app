// data.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water/model/userData.dart';
import 'dart:convert';

class Data extends ChangeNotifier {
  UserData _user = UserData('', 0, {}, {}, {}, {}, ''); // Initial empty state
  static const String _key = 'userData'; // Key for SharedPreferences

  Data() {
    _loadFromPrefs(); // Load data on initialization
  }

  UserData get user => _user;

  // Load data from SharedPreferences
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      _user = UserData.fromJson(jsonDecode(jsonString));
      notifyListeners();
    }
  }

  // Save data to SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_user.toJson()));
  }

  // Initialize or update from external source
  void updateFromDB(UserData userData) {
    _user = userData;
    _saveToPrefs();
    notifyListeners();
  }

  // Set goals
  void setGoals(String goal) {
    _user.goal = int.tryParse(goal) ?? 0;
    _saveToPrefs();
    notifyListeners();
  }

  // Set metrics
  void setMetrics(Map<String, int> metric) {
    _user.metric = Map.from(metric);
    _saveToPrefs();
    notifyListeners();
  }

  // Log an amount at current time (Duration since midnight)
  void log(int amount) {
    final now = DateTime.now();
    final durationSinceMidnight = Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
      milliseconds: now.millisecond,
    );
    _user.Day_Log[durationSinceMidnight] = amount;
    _user.lastLog = {durationSinceMidnight: amount};
    _saveToPrefs();
    notifyListeners();
  }

  // Calculate next reminder time and suggested amount
  (DateTime, int) calculateNextReminder() {
    const defaultIntervalHours = 1.0;
    const defaultAmount = 250;
    const minIntervalHours = 0.5;
    const maxIntervalHours = 3.0;
    const startHour = 7;
    const endHour = 23;

    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, startHour, 0);
    final endTime = DateTime(now.year, now.month, now.day, endHour, 0);
    final timeElapsed =
        now.isAfter(startTime) ? now.difference(startTime) : Duration.zero;
    final totalActiveTime = endTime.difference(startTime);

    if (_user.Day_Log.isEmpty) {
      var nextTime = now.add(Duration(hours: defaultIntervalHours.toInt()));
      if (nextTime.isAfter(endTime)) nextTime = endTime;
      _user.nextLog = {
        nextTime.difference(DateTime(now.year, now.month, now.day)):
            defaultAmount
      };
      _saveToPrefs();
      return (nextTime, defaultAmount);
    }

    final expectedDrinked = totalActiveTime.inMinutes > 0
        ? _user.goal * (timeElapsed.inMinutes / totalActiveTime.inMinutes)
        : 0.0;
    final currentDrinked =
        _user.Day_Log.values.fold(0, (sum, amount) => sum + amount);
    final ratio = expectedDrinked > 0 ? currentDrinked / expectedDrinked : 1.0;
    final k = ratio.clamp(0.5, 2.0);

    final drinkTimes = _user.Day_Log.keys.toList()..sort();
    double avgIntervalHours = 0.0;
    if (drinkTimes.length >= 2) {
      final intervals = <double>[];
      for (int i = 1; i < drinkTimes.length; i++) {
        final diff = (drinkTimes[i] - drinkTimes[i - 1]).inMinutes / 60.0;
        intervals.add(diff);
      }
      avgIntervalHours = intervals.reduce((a, b) => a + b) / intervals.length;
    } else {
      avgIntervalHours = defaultIntervalHours;
    }

    final proposedIntervalHours = k * avgIntervalHours;
    final adjustedIntervalHours =
        proposedIntervalHours.clamp(minIntervalHours, maxIntervalHours);
    final adjustedInterval =
        Duration(minutes: (adjustedIntervalHours * 60).round());

    final lastDrinkTime = drinkTimes.last;
    final lastDrinkDateTime =
        DateTime(now.year, now.month, now.day).add(lastDrinkTime);
    var nextReminderTime = lastDrinkDateTime.add(adjustedInterval);
    if (nextReminderTime.isBefore(now)) {
      nextReminderTime = now.add(Duration(minutes: 5));
    }
    if (nextReminderTime.isAfter(endTime)) {
      nextReminderTime = endTime;
    }

    final remainingWater = _user.goal - currentDrinked;
    final remainingTime = endTime.difference(nextReminderTime);
    final remainingDrinks = remainingTime.inMinutes > 0
        ? (remainingTime.inMinutes / adjustedInterval.inMinutes).ceil()
        : 1;
    int suggestedAmount;
    if (remainingWater > 0) {
      final baseAmount = remainingDrinks > 0
          ? (remainingWater / remainingDrinks).round()
          : remainingWater;
      suggestedAmount = baseAmount;
      if (ratio < 1) {
        suggestedAmount = (suggestedAmount * 1.15).round();
      }
    } else {
      suggestedAmount = 200;
    }

    _user.nextLog = {
      nextReminderTime.difference(DateTime(now.year, now.month, now.day)):
          suggestedAmount
    };
    _saveToPrefs();

    return (nextReminderTime, suggestedAmount);
  }

  // Reset daily data
  void resetDaily() {
    _user.Day_Log.clear();
    _user.lastLog.clear();
    _user.nextLog.clear();
    _saveToPrefs();
    notifyListeners();
  }
}
