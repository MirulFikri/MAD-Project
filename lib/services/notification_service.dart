import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    // Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings (if needed later)
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    // Request notification permissions
    await requestNotificationPermissions();
  }

  Future<void> requestNotificationPermissions() async {
    // Request exact alarm permission for Android 12+
    final androidImplementation = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      // Request exact alarm permission (needed for Android 12+)
      final bool? exactAlarmGranted = await androidImplementation.requestExactAlarmsPermission();
      print('Exact alarm permission granted: $exactAlarmGranted');
      
      // Request notification permission (needed for Android 13+)
      final bool? notificationGranted = await androidImplementation.requestNotificationsPermission();
      print('Notification permission granted: $notificationGranted');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      // Check if the scheduled time is in the future
      if (scheduledTime.isBefore(DateTime.now())) {
        print('⚠️ Warning: Scheduled time $scheduledTime is in the past. Skipping notification.');
        return;
      }

      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
      
      print('📅 Scheduling notification:');
      print('  ID: $id');
      print('  Title: $title');
      print('  Body: $body');
      print('  Scheduled Time: $scheduledTime');
      print('  TZ Time: $tzScheduledTime');
      print('  Current Time: ${DateTime.now()}');
      print('  Time until notification: ${scheduledTime.difference(DateTime.now())}');

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'petcare_reminders',
            'Pet Reminders',
            channelDescription: 'Notifications for pet care reminders',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      print('✅ Notification scheduled successfully!');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print('Cancelled notification with ID: $id');
  }
  
  // Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'petcare_reminders',
        'Pet Reminders',
        channelDescription: 'Notifications for pet care reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
    print('Immediate notification shown!');
  }
}