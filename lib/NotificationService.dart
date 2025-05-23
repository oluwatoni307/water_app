import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

// Global navigator key to handle payload routing
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

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
  }

  /// Handles notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) print('🔔 Notification tapped: ${response.payload}');
    if (response.payload != null && response.payload!.isNotEmpty) {
      navigatorKey.currentState?.pushNamed(response.payload!);
    }
  }

  /// Schedules a hydration notification in 10 seconds (for testing)
  Future<void> scheduleHydrationReminder() async {
    if (!_initialized) await initialize();

    await _notifications.cancel(1);

    const channel = AndroidNotificationChannel(
      'hydration_reminders',
      'Hydration Reminders',
      description: 'Reminders to drink water throughout the day',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = now.add(const Duration(seconds: 10));

    const androidDetails = AndroidNotificationDetails(
      'hydration_reminders',
      'Hydration Reminders',
      channelDescription: 'Reminders to drink water throughout the day',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        '💧 Time to hydrate!\nStay energized and drink some water.',
      ),
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      1,
      'Hydration Time 💧',
      'Take a refreshing sip of water!',
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Deprecated, just remove or leave null
      payload: '/',
    );

    if (kDebugMode) {
      print('🕒 Hydration reminder scheduled for $scheduledTime');
    }
  }

  /// Show an instant notification for testing
  Future<void> showTestNotification() async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'hydration_reminders',
      'Hydration Reminders',
      channelDescription: 'Hydration test notification',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      100,
      'Test Notification ✅',
      'This is a test notification',
      details,
    );
  }

  /// Cancels all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    if (kDebugMode) print('🔕 All notifications canceled');
  }
}
