import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Service to handle scheduling and delivering notifications
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    try {
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      await _requestNotificationPermission();
      _initialized = true;

      if (kDebugMode) print('Notification service initialized');
    } catch (e) {
      if (kDebugMode) print('Initialization failed: $e');
    }
  }

  /// Request notification permission on Android 13+
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        if (kDebugMode) print('Notification permission granted');
      } else {
        if (kDebugMode) print('Notification permission denied');
      }
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) print('Notification tapped: ${response.payload}');
    if (response.payload != null && response.payload!.isNotEmpty) {
      navigatorKey.currentState?.pushNamed(response.payload!);
    }
  }

  /// Schedule a simple hydration reminder every 3 hours
  Future<void> scheduleHydrationReminder() async {
    if (!_initialized) await initialize();

    await _notifications.cancel(1); // Cancel previous reminder

    final now = tz.TZDateTime.now(tz.local);
    final nextReminder = now.add(const Duration(hours: 3));

    const androidDetails = AndroidNotificationDetails(
      'hydration_reminders',
      'Hydration Reminders',
      channelDescription: 'Reminders to stay hydrated throughout the day',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        'Stay refreshed and energized. ✨\nTime to drink some water!',
      ),
    );

    const details = NotificationDetails(android: androidDetails);

    try {
      await _notifications.zonedSchedule(
        1, // ID
        'Hydration Time 💧',
        'Take a refreshing sip of water!',
        nextReminder,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: '/', // Route (optional)
      );
      if (kDebugMode) {
        print('Scheduled hydration reminder for $nextReminder');
      }
    } catch (e) {
      if (kDebugMode) print('Error scheduling hydration reminder: $e');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    if (kDebugMode) print('All notifications canceled');
  }
}
