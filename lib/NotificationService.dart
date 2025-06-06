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

    // Create a single notification channel for all hydration notifications
    const hydrationChannel = AndroidNotificationChannel(
      'hydration_notifications',
      'Hydration Notifications',
      description: 'All hydration related notifications',
      importance: Importance.defaultImportance,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(hydrationChannel);

    final now = tz.TZDateTime.now(tz.local);

    // 1. Schedule welcome notification after 5 minutes
    await _scheduleWelcomeNotification(now);

    // 2. Schedule limited bi-hourly reminders (reduced from 1000 to 50)
    await _scheduleBiHourlyReminders(now);

    if (kDebugMode) {
      print('🎉 All hydration notifications scheduled successfully');
    }
  }

  /// Schedules the welcome notification
  Future<void> _scheduleWelcomeNotification(tz.TZDateTime now) async {
    final welcomeTime = now.add(const Duration(minutes: 5));

    const welcomeAndroidDetails = AndroidNotificationDetails(
      'hydration_notifications',
      'Hydration Notifications',
      channelDescription: 'All hydration related notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
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
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // Changed from alarmClock
      payload: '/',
    );

    if (kDebugMode) {
      print('🎉 Welcome notification scheduled for: $welcomeTime');
    }
  }

  /// Schedules bi-hourly reminders (reduced count for better reliability)
  Future<void> _scheduleBiHourlyReminders(tz.TZDateTime now) async {
    // Testing with 10 notifications at 3-minute intervals
    const int maxNotifications = 10;

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

    // Start notifications 3 minutes after the welcome message
    for (int i = 1; i <= maxNotifications; i++) {
      final scheduledTime =
          now.add(Duration(minutes: 3 * i)); // Changed from hours to minutes
      final message = messages[i % messages.length];

      const androidDetails = AndroidNotificationDetails(
        'hydration_notifications',
        'Hydration Notifications',
        channelDescription: 'All hydration related notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        styleInformation: BigTextStyleInformation(
          '💧 3-Minute Hydration Reminder\nStay energized and drink some water to keep yourself healthy!',
        ),
      );

      const details = NotificationDetails(android: androidDetails);

      try {
        await _notifications.zonedSchedule(
          notificationId++,
          'Hydration Time 💧',
          message,
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode
              .exactAllowWhileIdle, // Changed from alarmClock
          payload: '/',
        );
      } catch (e) {
        if (kDebugMode) print('❌ Failed to schedule notification $i: $e');
        break; // Stop scheduling if we hit an error
      }

      // Add a small delay every 10 notifications to prevent overwhelming the system
      if (i % 10 == 0) {
        await Future.delayed(const Duration(milliseconds: 50));
        if (kDebugMode)
          print('📅 Scheduled $i bi-hourly notifications so far...');
      }
    }

    // Calculate end time for testing
    final totalMinutes = maxNotifications * 3;
    final endTime = now.add(Duration(minutes: totalMinutes));

    if (kDebugMode) {
      print(
          '🕒 Scheduled $maxNotifications hydration reminders at 3-minute intervals');
      print('📅 Reminders start: ${now.add(const Duration(minutes: 3))}');
      print(
          '📅 Notifications end at: $endTime (${totalMinutes} minutes total)');
    }
  }

  /// Schedules a hydration notification in 10 seconds (for testing)
  Future<void> scheduleHydrationReminder() async {
    if (!_initialized) await initialize();

    await _notifications.cancel(1);

    const channel = AndroidNotificationChannel(
      'hydration_test',
      'Hydration Test',
      description: 'Test hydration notifications',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = now.add(const Duration(seconds: 10));

    const androidDetails = AndroidNotificationDetails(
      'hydration_test',
      'Hydration Test',
      channelDescription: 'Test hydration notifications',
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
      'hydration_test',
      'Hydration Test',
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

    // Cancel hydration notifications (reduced to 10 for testing)
    for (int i = 1000; i < 1010; i++) {
      await _notifications.cancel(i);

      // Add small delay every 25 cancellations
      if ((i - 1000) % 25 == 0 && (i - 1000) > 0) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }

    if (kDebugMode)
      print(
          '🔕 All hydration notifications canceled (welcome + 10 test reminders)');
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
      for (final notification in pendingNotifications.take(10)) {
        print('  - ID: ${notification.id}, Title: ${notification.title}');
      }
      if (pendingNotifications.length > 10) {
        print('  ... and ${pendingNotifications.length - 10} more');
      }
    }
  }

  /// Schedule notifications in smaller batches for better reliability
  Future<void> scheduleHydrationNotificationsBatch() async {
    if (!_initialized) await initialize();

    await cancelHydrationNotifications();

    // Create notification channel
    const hydrationChannel = AndroidNotificationChannel(
      'hydration_notifications',
      'Hydration Notifications',
      description: 'All hydration related notifications',
      importance: Importance.high,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(hydrationChannel);

    final now = tz.TZDateTime.now(tz.local);

    // Schedule welcome notification
    await _scheduleWelcomeNotification(now);

    // Schedule notifications in batches of 10 over time
    await _scheduleBatchedNotifications(now);

    if (kDebugMode) {
      print('🎉 Batch hydration notifications scheduled successfully');
    }
  }

  /// Schedule notifications in smaller batches
  Future<void> _scheduleBatchedNotifications(tz.TZDateTime now) async {
    const int batchSize = 10;
    const int totalBatches = 5; // Total of 50 notifications

    final List<String> messages = [
      'Time to hydrate! 💧',
      'Stay refreshed - drink some water! 🌊',
      'Your body needs water! 💙',
      'Hydration break time! 🥤',
      'Keep yourself energized with water! ⚡',
    ];

    int notificationId = 1000;

    for (int batch = 0; batch < totalBatches; batch++) {
      for (int i = 0; i < batchSize; i++) {
        final notificationIndex = batch * batchSize + i + 1;
        final scheduledTime = now.add(Duration(hours: 2 * notificationIndex));
        final message = messages[i % messages.length];

        const androidDetails = AndroidNotificationDetails(
          'hydration_notifications',
          'Hydration Notifications',
          channelDescription: 'All hydration related notifications',
          importance: Importance.high,
          priority: Priority.high,
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
      }

      // Delay between batches
      await Future.delayed(const Duration(milliseconds: 100));

      if (kDebugMode) {
        print('📅 Scheduled batch ${batch + 1}/$totalBatches');
      }
    }
  }
}
