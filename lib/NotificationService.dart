// Test file to verify NotificationService compilation
// Save this as test_notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Use the global key from your service
      title: 'Notification Test',
      home: NotificationTestScreen(),
    );
  }
}

class NotificationTestScreen extends StatefulWidget {
  @override
  _NotificationTestScreenState createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.initialize();
      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize notification service: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Service Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  await _notificationService.showTestNotification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Test notification sent!')),
                  );
                } catch (e) {
                  print('Error: $e');
                }
              },
              child: Text('Show Test Notification'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _notificationService.getScheduledNotifications();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Check console for pending notifications')),
                  );
                } catch (e) {
                  print('Error: $e');
                }
              },
              child: Text('Check Pending Notifications'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _notificationService.scheduleHydrationNotifications();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('All hydration notifications scheduled!')),
                  );
                } catch (e) {
                  print('Error: $e');
                }
              },
              child: Text('Schedule All Hydration Notifications'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _notificationService.getScheduledNotifications();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Check console for scheduled notifications')),
                  );
                } catch (e) {
                  print('Error: $e');
                }
              },
              child: Text('Check Scheduled Notifications'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _notificationService.cancelAllNotifications();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All notifications canceled!')),
                  );
                } catch (e) {
                  print('Error: $e');
                }
              },
              child: Text('Cancel All Notifications'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

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

    // FIXED: Added timezone location setup as per documentation
    tz.setLocalLocation(tz.getLocation('UTC')); // or use device timezone

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

  /// Requests notification permission for Android 13+ and exact alarms
  Future<void> _requestNotificationPermission() async {
    // Request notification permission
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (kDebugMode) {
        print(result.isGranted
            ? '✅ Notification permission granted'
            : '❌ Notification permission denied');
      }
    }

    // FIXED: Added exact alarm permission as per documentation
    if (await Permission.scheduleExactAlarm.isDenied) {
      final result = await Permission.scheduleExactAlarm.request();
      if (kDebugMode) {
        print(result.isGranted
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
      importance: Importance.high,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(hydrationChannel);

    final now = tz.TZDateTime.now(tz.local);

    // 1. Schedule welcome notification after 5 minutes
    await _scheduleWelcomeNotification(now);

    // 2. Schedule limited bi-hourly reminders
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
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // FIXED: As per doc
      payload: '/',
    );

    if (kDebugMode) {
      print('🎉 Welcome notification scheduled for: $welcomeTime');
    }
  }

  /// Schedules bi-hourly reminders
  Future<void> _scheduleBiHourlyReminders(tz.TZDateTime now) async {
    const int maxNotifications = 10;

    final List<String> messages = [
      'Time to hydrate! 💧',
      'Stay refreshed - drink some water! 🌊',
      'Your body needs water! 💙',
      'Hydration break time! 🥤',
      'Keep yourself energized with water! ⚡',
    ];

    int notificationId = 1000;

    for (int i = 1; i <= maxNotifications; i++) {
      final scheduledTime =
          now.add(Duration(minutes: 3 * i)); // Back to 3-minute intervals
      final message = messages[i % messages.length];

      const androidDetails = AndroidNotificationDetails(
        'hydration_notifications',
        'Hydration Notifications',
        channelDescription: 'All hydration related notifications',
        importance: Importance.high,
        priority: Priority.high,
      );

      const details = NotificationDetails(android: androidDetails);

      try {
        await _notifications.zonedSchedule(
          notificationId++,
          'Hydration Time 💧',
          message,
          scheduledTime,
          details,
          androidScheduleMode:
              AndroidScheduleMode.exactAllowWhileIdle, // FIXED: As per doc
          payload: '/',
        );
      } catch (e) {
        if (kDebugMode) print('❌ Failed to schedule notification $i: $e');
        break;
      }

      if (i % 10 == 0) {
        await Future.delayed(const Duration(milliseconds: 50));
        if (kDebugMode) print('📅 Scheduled $i notifications so far...');
      }
    }

    if (kDebugMode) {
      print(
          '🕒 Scheduled $maxNotifications hydration reminders at 3-minute intervals');
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
      payload: '/',
    );
  }

  /// Cancels hydration notifications
  Future<void> cancelHydrationNotifications() async {
    await _notifications.cancel(999);
    for (int i = 1000; i < 1010; i++) {
      await _notifications.cancel(i);
    }
    if (kDebugMode) print('🔕 All hydration notifications canceled');
  }

  /// Cancels all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    if (kDebugMode) print('🔕 All notifications canceled');
  }

  /// Get scheduled notifications for debugging
  Future<void> getScheduledNotifications() async {
    final pendingNotifications =
        await _notifications.pendingNotificationRequests();
    if (kDebugMode) {
      print('📋 Pending notifications: ${pendingNotifications.length}');
      for (final notification in pendingNotifications.take(5)) {
        print('  - ID: ${notification.id}, Title: ${notification.title}');
      }
    }
  }
}
