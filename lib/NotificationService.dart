import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global navigator key to handle payload routing
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Default notification times (3 times a day) - used when user hasn't set custom times
  final List<String> _defaultTimes = ["08:00", "14:00", "20:00"];

  /// Initializes the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidInit,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestNotificationPermission();

    _initialized = true;

    if (kDebugMode) print('✅ Notification service initialized');
  }

  /// Requests notification permission for Android 13+
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (kDebugMode) {
        print(result.isGranted
            ? '✅ Notification permission granted'
            : '❌ Notification permission denied');
      }
    }

    // Request exact alarm permission for Android 12+
    final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
    if (!exactAlarmStatus.isGranted) {
      final exactAlarmResult = await Permission.scheduleExactAlarm.request();
      if (kDebugMode) {
        print(exactAlarmResult.isGranted
            ? '✅ Exact alarm permission granted'
            : '❌ Exact alarm permission denied');
      }
    }
  }

  /// Handles notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) print('🔔 Notification tapped: ${response.payload}');
    if (response.payload != null && response.payload!.isNotEmpty) {
      navigatorKey.currentState?.pushNamed(response.payload!);
    }
  }

  /// Gets notification times from user settings or returns default times
  Future<List<String>> _getNotificationTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    if (!notificationsEnabled) {
      if (kDebugMode) print('🔕 Notifications are disabled by user');
      return [];
    }

    final customTimes = prefs.getStringList('notification_times');

    if (customTimes != null && customTimes.isNotEmpty) {
      if (kDebugMode) print('📅 Using custom notification times: $customTimes');
      return customTimes;
    } else {
      if (kDebugMode)
        print('📅 Using default notification times: $_defaultTimes');
      return _defaultTimes;
    }
  }

  /// Schedules notifications based on user settings (for 30 days)
  Future<void> scheduleNotifications() async {
    if (!_initialized) await initialize();

    // Cancel any existing notifications
    await cancelAllNotifications();

    final notificationTimes = await _getNotificationTimes();

    if (notificationTimes.isEmpty) {
      if (kDebugMode) print('📵 No notifications to schedule');
      return;
    }

    // Create notification channels
    await _createNotificationChannels();

    // Store the start date for 30-day limit
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'notification_start_date', DateTime.now().toIso8601String());

    // Define notification data for different types - all water tracking focused
    final notificationData = [
      {
        'channelId': 'hydration_channel',
        'channelName': 'Hydration Reminders',
        'title': 'Hydration Time 💧',
        'body': 'Time to drink some water! Stay hydrated!',
        'bigText':
            '💧 Hydration Alert!\nYour body needs water to function properly. Take a moment to drink some refreshing water now!',
      },
      {
        'channelId': 'water_goal_channel',
        'channelName': 'Water Goal Reminders',
        'title': 'Water Goal Check 🎯',
        'body': 'How\'s your water intake today?',
        'bigText':
            '🎯 Water Goal Reminder!\nCheck your progress and see how close you are to reaching your daily water intake goal. Every sip counts!',
      },
      {
        'channelId': 'dehydration_channel',
        'channelName': 'Dehydration Prevention',
        'title': 'Don\'t Forget Water 🚰',
        'body': 'It\'s been a while since your last drink!',
        'bigText':
            '🚰 Dehydration Prevention!\nRegular water intake prevents headaches, fatigue, and keeps your body functioning optimally. Drink up!',
      },
      {
        'channelId': 'health_hydration_channel',
        'channelName': 'Hydration Health Tips',
        'title': 'Hydration Health 🌊',
        'body': 'Water is essential for your wellbeing!',
        'bigText':
            '🌊 Hydration Health Tip!\nProper hydration improves skin health, boosts energy, aids digestion, and enhances mental clarity. Keep drinking!',
      },
      {
        'channelId': 'water_motivation_channel',
        'channelName': 'Water Motivation',
        'title': 'Stay Hydrated Champion 🏆',
        'body': 'You\'re doing great with your hydration!',
        'bigText':
            '🏆 Hydration Champion!\nEvery glass of water brings you closer to optimal health. Keep up the excellent hydration habits!',
      },
    ];

    final now = tz.TZDateTime.now(tz.local);
    final endDate = now.add(const Duration(days: 30)); // 30-day limit
    int notificationId = 1;

    // Schedule notifications for each time for the next 30 days
    for (int day = 0; day < 30; day++) {
      final currentDay = now.add(Duration(days: day));

      for (int timeIndex = 0;
          timeIndex < notificationTimes.length;
          timeIndex++) {
        final timeString = notificationTimes[timeIndex];
        final timeParts = timeString.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        // Calculate scheduled time for this specific day
        var scheduledTime = tz.TZDateTime(tz.local, currentDay.year,
            currentDay.month, currentDay.day, hour, minute);

        // Skip if this time has already passed (only for today)
        if (day == 0 && scheduledTime.isBefore(now)) {
          continue;
        }

        // Ensure minimum delay of 1 minute from now for today's notifications
        if (day == 0) {
          final minimumScheduleTime = now.add(const Duration(minutes: 1));
          if (scheduledTime.isBefore(minimumScheduleTime)) {
            continue;
          }
        }

        // Use different notification types cyclically
        final dataIndex = (timeIndex + day) % notificationData.length;
        final data = notificationData[dataIndex];

        final androidDetails = AndroidNotificationDetails(
          data['channelId'] as String,
          data['channelName'] as String,
          channelDescription: 'Water tracking reminders for your health',
          importance: Importance.max,
          priority: Priority.max,
          styleInformation: BigTextStyleInformation(
            data['bigText'] as String,
          ),
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        );

        final details = NotificationDetails(android: androidDetails);

        // Schedule individual notification (not repeating)
        await _notifications.zonedSchedule(
          notificationId,
          data['title'] as String,
          data['body'] as String,
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          payload: '/',
        );

        if (kDebugMode) {
          print(
              '📅 Scheduled notification $notificationId: ${data['title']} at $scheduledTime (Day ${day + 1})');
        }

        notificationId++;
      }
    }

    if (kDebugMode) {
      print('🎉 All notifications scheduled successfully for 30 days');
      print('📱 Total notifications: ${(notificationTimes.length * 30)}');
      print('📅 Schedule period: ${now.toLocal()} to ${endDate.toLocal()}');
    }
  }

  /// Creates notification channels for different types
  Future<void> _createNotificationChannels() async {
    final channels = [
      const AndroidNotificationChannel(
        'hydration_channel',
        'Hydration Reminders',
        description: 'Regular water drinking reminders',
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        'water_goal_channel',
        'Water Goal Reminders',
        description: 'Daily water intake goal tracking',
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        'dehydration_channel',
        'Dehydration Prevention',
        description: 'Alerts to prevent dehydration',
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        'health_hydration_channel',
        'Hydration Health Tips',
        description: 'Health benefits of proper hydration',
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        'water_motivation_channel',
        'Water Motivation',
        description: 'Motivational hydration reminders',
        importance: Importance.max,
      ),
    ];

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Create all channels
    for (final channel in channels) {
      await androidPlugin?.createNotificationChannel(channel);
    }
  }

  /// Cancels all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    if (kDebugMode) print('🔕 All notifications canceled');
  }

  /// Get the status of scheduled notifications (for debugging)
  Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
    final pendingNotifications =
        await _notifications.pendingNotificationRequests();
    if (kDebugMode) {
      print('📋 Pending notifications: ${pendingNotifications.length}');
      for (final notification in pendingNotifications) {
        print('  - ID: ${notification.id}, Title: ${notification.title}');
      }
    }
    return pendingNotifications;
  }

  /// Updates notifications when user changes settings
  Future<void> updateNotificationSchedule() async {
    if (kDebugMode) print('🔄 Updating notification schedule...');
    await scheduleNotifications();
  }

  /// Check if exact alarm permission is granted (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    final status = await Permission.scheduleExactAlarm.status;
    return status.isGranted;
  }

  /// Request user to disable battery optimization for reliable notifications
  Future<void> requestBatteryOptimizationDisabled() async {
    // This would typically open device settings to disable battery optimization
    // Implementation depends on the device manufacturer
    if (kDebugMode)
      print(
          '🔋 Consider disabling battery optimization for reliable notifications');
  }

  /// Check if the 30-day notification period has expired
  Future<bool> hasNotificationPeriodExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final startDateString = prefs.getString('notification_start_date');

    if (startDateString == null) return false;

    final startDate = DateTime.parse(startDateString);
    final now = DateTime.now();
    final daysPassed = now.difference(startDate).inDays;

    if (kDebugMode)
      print('📅 Notification period: $daysPassed/30 days elapsed');

    return daysPassed >= 30;
  }

  /// Extend notification period for another 30 days
  Future<void> extendNotificationPeriod() async {
    if (kDebugMode)
      print('🔄 Extending notification period for another 30 days');
    await scheduleNotifications();
  }
}
