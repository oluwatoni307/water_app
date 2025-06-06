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

  /// Schedules welcome notification and bi-hourly hydration reminders
  Future<void> scheduleHydrationNotifications() async {
    if (!_initialized) await initialize();

    // Cancel any existing notifications
    await cancelHydrationNotifications();

    // Create notification channels
    const welcomeChannel = AndroidNotificationChannel(
      'welcome_hydration',
      'Welcome Messages',
      description: 'Welcome messages for hydration app',
      importance: Importance.high,
    );

    const biHourlyChannel = AndroidNotificationChannel(
      'bihourly_hydration_reminders',
      'Bi-Hourly Hydration Reminders',
      description: 'Bi-hourly reminders to drink water throughout the day',
      importance: Importance.high,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(welcomeChannel);
    await androidPlugin?.createNotificationChannel(biHourlyChannel);

    final now = tz.TZDateTime.now(tz.local);

    // 1. Schedule welcome notification after 5 minutes
    final welcomeTime = now.add(const Duration(minutes: 5));

    const welcomeAndroidDetails = AndroidNotificationDetails(
      'welcome_hydration',
      'Welcome Messages',
      channelDescription: 'Welcome messages for hydration app',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        '🎉 Welcome to your hydration journey!\nWe\'ll help you stay healthy and hydrated throughout the day. Let\'s begin!',
      ),
    );

    const welcomeDetails = NotificationDetails(android: welcomeAndroidDetails);

    await _notifications.zonedSchedule(
      999, // Welcome notification ID
      'Welcome to Hydration Helper! 🎉',
      'Your journey to better health starts now!',
      welcomeTime,
      welcomeDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      payload: '/',
    );

    // 2. Schedule bi-hourly reminders (every 2 hours, max 1000 notifications)
    const int maxNotifications = 1000;

    final List<String> messages = [
      'Time to hydrate! 💧',
      'Stay refreshed - drink some water! 🌊',
      'Your body needs water! 💙',
      'Hydration break time! 🥤',
      'Keep yourself energized with water! ⚡',
      'Water is life - take a sip! 🌿',
      'Stay healthy, stay hydrated! 🌟',
      'Refresh yourself with water! 🔄',
      'Don\'t forget to drink water! 🚰',
      'Hydration is key to wellness! 🔑',
      'Take a water break! ⏰',
      'Your cells need hydration! 🧬',
      'Pure water, pure energy! ✨',
      'Sip by sip, stay healthy! 👍',
      'Water fuels your body! 🔋',
      'Stay cool, drink water! 🧊',
    ];

    int notificationId = 1000;

    // Start bi-hourly notifications 2 hours after welcome message
    for (int i = 1; i <= maxNotifications; i++) {
      final scheduledTime = now.add(Duration(hours: 2 * i));
      final message = messages[i % messages.length];

      const androidDetails = AndroidNotificationDetails(
        'bihourly_hydration_reminders',
        'Bi-Hourly Hydration Reminders',
        channelDescription:
            'Bi-hourly reminders to drink water throughout the day',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(
          '💧 Bi-Hourly Hydration Reminder\nStay energized and drink some water to keep yourself healthy!',
        ),
      );

      const details = NotificationDetails(android: androidDetails);

      await _notifications.zonedSchedule(
        notificationId++,
        'Hydration Time 💧',
        message,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: '/',
      );

      // Add a small delay every 50 notifications to prevent overwhelming the system
      if (i % 50 == 0) {
        await Future.delayed(const Duration(milliseconds: 10));
        if (kDebugMode)
          print('📅 Scheduled ${i} bi-hourly notifications so far...');
      }
    }

    // Calculate end date (1000 notifications * 2 hours = 2000 hours ≈ 83 days)
    final totalHours = maxNotifications * 2;
    final totalDays = (totalHours / 24).round();
    final endDate = now.add(Duration(hours: totalHours));

    if (kDebugMode) {
      print('🎉 Welcome notification scheduled for: $welcomeTime');
      print('🕒 Scheduled $maxNotifications bi-hourly hydration reminders');
      print(
          '📅 Bi-hourly reminders start: ${now.add(const Duration(hours: 2))}');
      print('📅 Notifications end after ~$totalDays days: $endDate');
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
      payload: '/',
    );

    if (kDebugMode) {
      print('🕒 Test hydration reminder scheduled for $scheduledTime');
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

  /// Cancels hydration notifications (welcome + bi-hourly)
  Future<void> cancelHydrationNotifications() async {
    // Cancel welcome notification
    await _notifications.cancel(999);

    // Cancel bi-hourly notifications (max 1000)
    for (int i = 1000; i < 2000; i++) {
      await _notifications.cancel(i);

      // Add small delay every 50 cancellations to prevent overwhelming the system
      if ((i - 1000) % 50 == 0 && (i - 1000) > 0) {
        await Future.delayed(const Duration(milliseconds: 5));
      }
    }

    if (kDebugMode)
      print(
          '🔕 All hydration notifications canceled (welcome + 1000 bi-hourly)');
  }

  /// Cancels all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    if (kDebugMode) print('🔕 All notifications canceled');
  }

  /// Get the status of scheduled notifications (for debugging)
  Future<void> getScheduledNotifications() async {
    final pendingNotifications =
        await _notifications.pendingNotificationRequests();
    if (kDebugMode) {
      print('📋 Pending notifications: ${pendingNotifications.length}');
      for (final notification in pendingNotifications) {
        print('  - ID: ${notification.id}, Title: ${notification.title}');
      }
    }
  }
}
