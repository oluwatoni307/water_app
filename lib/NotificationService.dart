import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

// WorkManager task names - must be top-level constants
const String hydrationTaskName = 'hydration_reminder_task';
const String welcomeTaskName = 'welcome_notification_task';

// Global navigator key to handle payload routing
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // WorkManager task names
  static const String _hydrationTaskName = hydrationTaskName;
  static const String _welcomeTaskName = welcomeTaskName;

  /// Initializes the notification service and WorkManager
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestNotificationPermission();

    // Initialize WorkManager
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    _initialized = true;

    if (kDebugMode)
      print('✅ Notification service with WorkManager initialized');
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

  /// Starts hydration reminder workflow using WorkManager
  Future<void> startHydrationReminders() async {
    if (!_initialized) await initialize();

    // Cancel any existing work
    await stopHydrationReminders();

    // Store start time for tracking
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'hydration_start_time', DateTime.now().millisecondsSinceEpoch);
    await prefs.setInt('notification_count', 0);

    // Schedule welcome notification (one-time, 5 minutes delay)
    await Workmanager().registerOneOffTask(
      _welcomeTaskName,
      _welcomeTaskName,
      initialDelay: const Duration(minutes: 5),
      inputData: {
        'type': 'welcome',
        'message': 'Welcome to your hydration journey! 🎉',
        'body': 'Your journey to better health starts now!',
      },
    );

    // Schedule periodic hydration reminders (every 3 minutes for testing)
    await Workmanager().registerPeriodicTask(
      _hydrationTaskName,
      _hydrationTaskName,
      frequency: const Duration(minutes: 3),
      initialDelay: const Duration(minutes: 1), // Start after 1 minute
      inputData: {
        'type': 'hydration',
        'max_notifications': 5, // Limit to 5 notifications for testing
      },
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    if (kDebugMode) {
      print('🎉 Hydration reminders started with WorkManager');
    }
  }

  /// Stops all hydration reminders
  Future<void> stopHydrationReminders() async {
    await Workmanager().cancelByUniqueName(_hydrationTaskName);
    await Workmanager().cancelByUniqueName(_welcomeTaskName);

    // Clear stored data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hydration_start_time');
    await prefs.remove('notification_count');

    if (kDebugMode) print('🔕 Hydration reminders stopped');
  }

  /// Schedules a test notification (one-time, 10 seconds delay)
  Future<void> scheduleTestNotification() async {
    if (!_initialized) await initialize();

    await Workmanager().registerOneOffTask(
      'test_notification',
      'test_notification',
      initialDelay: const Duration(seconds: 10),
      inputData: {
        'type': 'test',
        'message': 'Test Notification ✅',
        'body': 'This is a test notification from WorkManager',
      },
    );

    if (kDebugMode) {
      print('🕒 Test notification scheduled for 10 seconds');
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
      'This is an instant test notification',
      details,
    );
  }

  /// Cancels all notifications and work
  Future<void> cancelAll() async {
    await Workmanager().cancelAll();
    await _notifications.cancelAll();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (kDebugMode) print('🔕 All notifications and work canceled');
  }

  /// Get WorkManager status (for debugging)
  Future<void> getWorkManagerStatus() async {
    // Note: WorkManager doesn't provide direct status checking in Flutter
    // You can check SharedPreferences for tracking data
    final prefs = await SharedPreferences.getInstance();
    final startTime = prefs.getInt('hydration_start_time');
    final notificationCount = prefs.getInt('notification_count') ?? 0;

    if (kDebugMode) {
      if (startTime != null) {
        final start = DateTime.fromMillisecondsSinceEpoch(startTime);
        print('📋 Hydration reminders started at: $start');
        print('📋 Notifications sent: $notificationCount');
      } else {
        print('📋 No active hydration reminders');
      }
    }
  }
}

/// WorkManager callback dispatcher - must be a top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (kDebugMode) print('🔄 WorkManager task: $task');

      // Initialize notifications in background
      final notifications = FlutterLocalNotificationsPlugin();
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);

      await notifications.initialize(initSettings);

      // Create notification channel
      const channel = AndroidNotificationChannel(
        'hydration_notifications',
        'Hydration Notifications',
        description: 'All hydration related notifications',
        importance: Importance.high,
      );

      await notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      final type = inputData?['type'] as String?;

      switch (type) {
        case 'welcome':
          await _showWelcomeNotification(notifications, inputData);
          break;
        case 'hydration':
          await _showHydrationNotification(notifications, inputData);
          break;
        case 'test':
          await _showTestNotification(notifications, inputData);
          break;
        default:
          if (kDebugMode) print('❌ Unknown notification type: $type');
      }

      return Future.value(true);
    } catch (e) {
      if (kDebugMode) print('❌ WorkManager task failed: $e');
      return Future.value(false);
    }
  });
}

/// Shows welcome notification
Future<void> _showWelcomeNotification(
  FlutterLocalNotificationsPlugin notifications,
  Map<String, dynamic>? inputData,
) async {
  const androidDetails = AndroidNotificationDetails(
    'hydration_notifications',
    'Hydration Notifications',
    channelDescription: 'All hydration related notifications',
    importance: Importance.high,
    priority: Priority.high,
    styleInformation: BigTextStyleInformation(
      '🎉 Welcome to your hydration journey!\nWe\'ll help you stay healthy and hydrated throughout the day. Let\'s begin!',
    ),
  );

  const details = NotificationDetails(android: androidDetails);

  await notifications.show(
    999,
    inputData?['message'] ?? 'Welcome! 🎉',
    inputData?['body'] ?? 'Your hydration journey begins now!',
    details,
    payload: '/',
  );

  if (kDebugMode) print('🎉 Welcome notification shown');
}

/// Shows hydration reminder notification
Future<void> _showHydrationNotification(
  FlutterLocalNotificationsPlugin notifications,
  Map<String, dynamic>? inputData,
) async {
  final prefs = await SharedPreferences.getInstance();
  final notificationCount = prefs.getInt('notification_count') ?? 0;
  final maxNotifications = inputData?['max_notifications'] as int? ?? 5;

  // Check if we've reached the limit
  if (notificationCount >= maxNotifications) {
    if (kDebugMode) print('🔕 Reached notification limit ($maxNotifications)');
    // Cancel the periodic task when limit is reached
    await Workmanager().cancelByUniqueName(hydrationTaskName);
    return;
  }

  // List of hydration messages
  final messages = [
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
  ];

  final message = messages[notificationCount % messages.length];

  const androidDetails = AndroidNotificationDetails(
    'hydration_notifications',
    'Hydration Notifications',
    channelDescription: 'All hydration related notifications',
    importance: Importance.high,
    priority: Priority.high,
    styleInformation: BigTextStyleInformation(
      '💧 Hydration Reminder\nStay energized and drink some water to keep yourself healthy!',
    ),
  );

  const details = NotificationDetails(android: androidDetails);

  await notifications.show(
    1000 + notificationCount,
    'Hydration Time 💧',
    message,
    details,
    payload: '/',
  );

  // Update counter
  await prefs.setInt('notification_count', notificationCount + 1);

  if (kDebugMode) {
    print(
        '💧 Hydration notification shown (${notificationCount + 1}/$maxNotifications)');
    if (notificationCount + 1 >= maxNotifications) {
      print('🏁 Testing complete! All 5 notifications have been sent.');
    }
  }
}

/// Shows test notification
Future<void> _showTestNotification(
  FlutterLocalNotificationsPlugin notifications,
  Map<String, dynamic>? inputData,
) async {
  const androidDetails = AndroidNotificationDetails(
    'hydration_test',
    'Hydration Test',
    channelDescription: 'Test notifications',
    importance: Importance.high,
    priority: Priority.high,
  );

  const details = NotificationDetails(android: androidDetails);

  await notifications.show(
    100,
    inputData?['message'] ?? 'Test Notification ✅',
    inputData?['body'] ?? 'This is a test notification',
    details,
  );

  if (kDebugMode) print('✅ Test notification shown');
}
