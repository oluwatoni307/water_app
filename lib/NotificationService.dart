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

  /// Schedules 5 different notifications with 1-minute intervals
  Future<void> scheduleFiveNotifications() async {
    if (!_initialized) await initialize();

    // Cancel any existing notifications
    await cancelAllNotifications();

    // Create 5 different notification channels
    final channels = [
      const AndroidNotificationChannel(
        'hydration_channel',
        'Hydration Reminders',
        description: 'Stay hydrated with water reminders',
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        'health_channel',
        'Health Tips',
        description: 'Daily health and wellness tips',
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        'energy_channel',
        'Energy Boosters',
        description: 'Energy and motivation reminders',
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        'wellness_channel',
        'Wellness Check',
        description: 'Overall wellness reminders',
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        'motivation_channel',
        'Daily Motivation',
        description: 'Motivational quotes and reminders',
        importance: Importance.max,
      ),
    ];

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Create all channels
    for (final channel in channels) {
      await androidPlugin?.createNotificationChannel(channel);
    }

    final now = tz.TZDateTime.now(tz.local);

    // Define notification data for each of the 5 notifications
    final notificationData = [
      {
        'id': 1,
        'channelId': 'hydration_channel',
        'channelName': 'Hydration Reminders',
        'title': 'Hydration Time 💧',
        'body': 'Time to drink some water! Stay hydrated!',
        'bigText':
            '💧 Hydration Alert!\nYour body needs water to function properly. Take a moment to drink some refreshing water now!',
      },
      {
        'id': 2,
        'channelId': 'health_channel',
        'channelName': 'Health Tips',
        'title': 'Health Tip 🏥',
        'body': 'Take care of your health today!',
        'bigText':
            '🏥 Health Reminder!\nTaking small steps towards better health makes a big difference. Remember to stay active and eat well!',
      },
      {
        'id': 3,
        'channelId': 'energy_channel',
        'channelName': 'Energy Boosters',
        'title': 'Energy Boost ⚡',
        'body': 'Time to recharge your energy!',
        'bigText':
            '⚡ Energy Boost!\nTake a deep breath, stretch your body, and get ready to tackle your day with renewed energy!',
      },
      {
        'id': 4,
        'channelId': 'wellness_channel',
        'channelName': 'Wellness Check',
        'title': 'Wellness Check 🌟',
        'body': 'How are you feeling today?',
        'bigText':
            '🌟 Wellness Check!\nTake a moment to check in with yourself. Your mental and physical wellness matters!',
      },
      {
        'id': 5,
        'channelId': 'motivation_channel',
        'channelName': 'Daily Motivation',
        'title': 'Stay Motivated 🚀',
        'body': 'You\'re doing great! Keep going!',
        'bigText':
            '🚀 Motivation Boost!\nEvery step forward is progress. Believe in yourself and keep pushing towards your goals!',
      },
    ];

    // Schedule each notification with 1-minute intervals using alarm clock mode
    for (int i = 0; i < notificationData.length; i++) {
      final data = notificationData[i];
      final scheduledTime =
          now.add(Duration(minutes: i + 1)); // 1, 2, 3, 4, 5 minutes

      final androidDetails = AndroidNotificationDetails(
        data['channelId'] as String,
        data['channelName'] as String,
        channelDescription: channels[i].description,
        importance: Importance.max,
        priority: Priority.max,
        styleInformation: BigTextStyleInformation(
          data['bigText'] as String,
        ),
        enableVibration: true,
        playSound: true,
      );

      final details = NotificationDetails(android: androidDetails);

      await _notifications.zonedSchedule(
        data['id'] as int,
        data['title'] as String,
        data['body'] as String,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        payload: '/',
      );

      if (kDebugMode) {
        print(
            '📅 Scheduled notification ${i + 1}: ${data['title']} at $scheduledTime');
      }
    }

    if (kDebugMode) {
      print('🎉 All 5 notifications scheduled with 1-minute intervals');
      print('📅 First notification: ${now.add(const Duration(minutes: 1))}');
      print('📅 Last notification: ${now.add(const Duration(minutes: 5))}');
    }
  }

  /// Show immediate test notifications for all 5 channels
  Future<void> showFiveTestNotifications() async {
    if (!_initialized) await initialize();

    final testNotifications = [
      {
        'id': 101,
        'channelId': 'hydration_channel',
        'title': 'Test Hydration 💧',
        'body': 'Hydration test notification',
      },
      {
        'id': 102,
        'channelId': 'health_channel',
        'title': 'Test Health 🏥',
        'body': 'Health test notification',
      },
      {
        'id': 103,
        'channelId': 'energy_channel',
        'title': 'Test Energy ⚡',
        'body': 'Energy test notification',
      },
      {
        'id': 104,
        'channelId': 'wellness_channel',
        'title': 'Test Wellness 🌟',
        'body': 'Wellness test notification',
      },
      {
        'id': 105,
        'channelId': 'motivation_channel',
        'title': 'Test Motivation 🚀',
        'body': 'Motivation test notification',
      },
    ];

    for (final notification in testNotifications) {
      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Test notifications',
        importance: Importance.max,
        priority: Priority.max,
      );

      const details = NotificationDetails(android: androidDetails);

      await _notifications.show(
        notification['id'] as int,
        notification['title'] as String,
        notification['body'] as String,
        details,
      );

      // Small delay between each test notification
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (kDebugMode) print('🧪 Showed 5 test notifications');
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
