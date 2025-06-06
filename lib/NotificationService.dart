import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

// Global navigator key for payload routing
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Notification channel constants
  static const String _channelId = 'hydration_notifications';
  static const String _channelName = 'Hydration Notifications';
  static const String _channelDescription = 'Hydration reminder notifications';

  // Notification IDs
  static const int _welcomeNotificationId = 999;
  static const int _reminderBaseId = 1000;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      tz_data.initializeTimeZones();

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      await _setupNotificationChannel();
      await _requestAllPermissions();

      _initialized = true;
      _log('✅ Notification service initialized successfully');
    } catch (e) {
      _log('❌ Failed to initialize notification service: $e');
      rethrow;
    }
  }

  /// Setup notification channel
  Future<void> _setupNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.defaultImportance,
      enableVibration: true,
      showBadge: true,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);
  }

  /// Request all necessary permissions including battery optimization bypass
  Future<void> _requestAllPermissions() async {
    // Request notification permission
    await _requestNotificationPermission();

    // Request battery optimization bypass
    await _requestBatteryOptimizationBypass();

    // Request exact alarm permission for Android 12+
    await _requestExactAlarmPermission();
  }

  /// Request notification permission
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      _log(result.isGranted
          ? '✅ Notification permission granted'
          : '❌ Notification permission denied');
    }
  }

  /// Request battery optimization bypass - critical for reliable notifications
  Future<void> _requestBatteryOptimizationBypass() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;

      if (!status.isGranted) {
        // Show explanation dialog first
        final shouldRequest = await _showBatteryOptimizationDialog();

        if (shouldRequest) {
          final result = await Permission.ignoreBatteryOptimizations.request();
          _log(result.isGranted
              ? '✅ Battery optimization bypass granted'
              : '❌ Battery optimization bypass denied');

          if (!result.isGranted) {
            _showBatteryOptimizationInstructions();
          }
        }
      } else {
        _log('✅ Battery optimization already bypassed');
      }
    } catch (e) {
      _log('❌ Error requesting battery optimization bypass: $e');
    }
  }

  /// Request exact alarm permission for Android 12+
  Future<void> _requestExactAlarmPermission() async {
    try {
      final status = await Permission.scheduleExactAlarm.status;
      if (!status.isGranted) {
        final result = await Permission.scheduleExactAlarm.request();
        _log(result.isGranted
            ? '✅ Exact alarm permission granted'
            : '❌ Exact alarm permission denied');
      }
    } catch (e) {
      _log('ℹ️ Exact alarm permission not available on this device');
    }
  }

  /// Show dialog explaining why battery optimization bypass is needed
  Future<bool> _showBatteryOptimizationDialog() async {
    final context = navigatorKey.currentContext;
    if (context == null) return false;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Enable Reliable Notifications'),
            content: const Text(
              'To ensure your hydration reminders work consistently, please allow this app to bypass battery optimization.\n\n'
              'This prevents Android from stopping notifications when the device is in power-saving mode.\n\n'
              'Your hydration goals are important for your health!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Maybe Later'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Allow'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Show instructions for manual battery optimization settings
  void _showBatteryOptimizationInstructions() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Setup Required'),
        content: const Text(
          'For the most reliable hydration reminders:\n\n'
          '1. Go to Settings → Apps → Hydration Helper\n'
          '2. Select "Battery" or "Battery Optimization"\n'
          '3. Choose "Don\'t optimize" or "Allow background activity"\n'
          '4. Enable "Auto-start" if available\n\n'
          'This ensures your health reminders always work!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    _log('🔔 Notification tapped: ${response.payload}');
    if (response.payload?.isNotEmpty == true) {
      navigatorKey.currentState?.pushNamed(response.payload!);
    }
  }

  /// Schedule complete hydration notification system
  Future<void> scheduleHydrationNotifications() async {
    await _ensureInitialized();
    await cancelAllNotifications();

    final now = tz.TZDateTime.now(tz.local);

    // Schedule welcome notification
    await _scheduleWelcomeNotification(now);

    // Schedule regular hydration reminders
    await _scheduleHydrationReminders(now);

    _log('🎉 Complete hydration notification system scheduled');
  }

  /// Schedule welcome notification
  Future<void> _scheduleWelcomeNotification(tz.TZDateTime now) async {
    final welcomeTime = now.add(const Duration(minutes: 2));

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      styleInformation: BigTextStyleInformation(
        '🎉 Welcome to your hydration journey!\n'
        'We\'ll help you stay healthy and hydrated throughout the day. '
        'Your first reminder will arrive soon!',
      ),
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      _welcomeNotificationId,
      'Welcome to Hydration Helper! 🎉',
      'Your journey to better health starts now!',
      welcomeTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '/',
    );

    _log('🎉 Welcome notification scheduled for: $welcomeTime');
  }

  /// Schedule regular hydration reminders (3-minute intervals for testing)
  Future<void> _scheduleHydrationReminders(tz.TZDateTime now) async {
    const int totalReminders = 15; // 15 reminders for testing
    const int intervalMinutes = 3;

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
    ];

    int notificationId = _reminderBaseId;
    int successCount = 0;

    // Start reminders 3 minutes after welcome (5 minutes total from now)
    tz.TZDateTime startTime = now.add(const Duration(minutes: 5));

    for (int i = 0; i < totalReminders; i++) {
      final scheduledTime =
          startTime.add(Duration(minutes: intervalMinutes * i));
      final message = messages[i % messages.length];

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        styleInformation: const BigTextStyleInformation(
          '💧 Test Hydration Reminder\n'
          'Testing notification delivery - drink some water! '
          'This is a test reminder to verify notifications work.',
        ),
        icon: '@mipmap/ic_launcher',
      );

      const details = NotificationDetails(android: androidDetails);

      try {
        await _notifications.zonedSchedule(
          notificationId++,
          'Test Hydration 💧 #${i + 1}',
          message,
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: '/',
        );
        successCount++;

        // Small delay to prevent overwhelming the system
        if (i % 5 == 0 && i > 0) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      } catch (e) {
        _log('❌ Failed to schedule notification ${i + 1}: $e');
      }
    }

    final totalMinutes = intervalMinutes * (totalReminders - 1);
    final endTime = startTime.add(Duration(minutes: totalMinutes));
    _log('📅 Scheduled $successCount/$totalReminders test hydration reminders');
    _log(
        '📅 Test reminders: $startTime to $endTime (every $intervalMinutes minutes)');
    _log('🧪 Total testing duration: ${totalMinutes} minutes');
  }

  /// Schedule a test notification (10 seconds)
  Future<void> scheduleTestNotification() async {
    await _ensureInitialized();

    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = now.add(const Duration(seconds: 10));

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Test notification',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      1,
      'Test Notification 🧪',
      'This is a test - your notifications are working!',
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '/',
    );

    _log('🧪 Test notification scheduled for: $scheduledTime');
  }

  /// Show immediate test notification
  Future<void> showInstantNotification() async {
    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Instant test notification',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      100,
      'Instant Test ⚡',
      'Notifications are working perfectly!',
      details,
    );

    _log('⚡ Instant notification shown');
  }

  /// Cancel all hydration notifications
  Future<void> cancelAllNotifications() async {
    // Cancel welcome notification
    await _notifications.cancel(_welcomeNotificationId);

    // Cancel all reminder notifications
    for (int i = _reminderBaseId; i < _reminderBaseId + 50; i++) {
      await _notifications.cancel(i);
    }

    _log('🔕 All hydration notifications canceled');
  }

  /// Get notification status for debugging
  Future<void> getNotificationStatus() async {
    final pending = await _notifications.pendingNotificationRequests();
    _log('📋 Pending notifications: ${pending.length}');

    for (final notification in pending.take(5)) {
      _log('  - ID: ${notification.id}, Title: ${notification.title}');
    }

    if (pending.length > 5) {
      _log('  ... and ${pending.length - 5} more');
    }
  }

  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }

  /// Utility logging method
  void _log(String message) {
    if (kDebugMode) print(message);
  }
}
