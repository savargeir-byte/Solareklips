import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/eclipse_event.dart';

/// Smart notification service for eclipse events
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  /// Schedule all notifications for an eclipse event
  static Future<void> scheduleEclipseNotifications(EclipseEvent event) async {
    await initialize();

    // 30 days before
    await _scheduleNotification(
      id: '${event.id}_30d'.hashCode,
      title: '🌒 Eclipse Alert: 30 Days',
      body: '${event.title} is coming! Book your flights and hotels now.',
      scheduledDate: event.startUtc.subtract(const Duration(days: 30)),
    );

    // 7 days before
    await _scheduleNotification(
      id: '${event.id}_7d'.hashCode,
      title: '🌓 Eclipse Alert: 1 Week',
      body: 'One week until ${event.title}. Check weather forecasts!',
      scheduledDate: event.startUtc.subtract(const Duration(days: 7)),
    );

    // 24 hours before
    await _scheduleNotification(
      id: '${event.id}_24h'.hashCode,
      title: '🌔 Eclipse Alert: 24 Hours',
      body: 'Tomorrow is the big day! ${event.title}',
      scheduledDate: event.startUtc.subtract(const Duration(hours: 24)),
    );

    // 6 hours before - weather update
    await _scheduleNotification(
      id: '${event.id}_6h'.hashCode,
      title: '☁️ Weather Check: 6 Hours',
      body: 'Check cloud cover forecast for ${event.title}',
      scheduledDate: event.startUtc.subtract(const Duration(hours: 6)),
    );

    // 1 hour before
    await _scheduleNotification(
      id: '${event.id}_1h'.hashCode,
      title: '🌕 Eclipse Starting Soon!',
      body: '${event.title} begins in 1 hour. Get to your viewing location!',
      scheduledDate: event.startUtc.subtract(const Duration(hours: 1)),
    );

    // 15 minutes before
    await _scheduleNotification(
      id: '${event.id}_15m'.hashCode,
      title: '⏰ 15 Minutes to First Contact',
      body: 'Put on your eclipse glasses and get ready!',
      scheduledDate: event.startUtc.subtract(const Duration(minutes: 15)),
    );

    // First contact (C1)
    await _scheduleNotification(
      id: '${event.id}_c1'.hashCode,
      title: '🌑 First Contact!',
      body: 'Eclipse has started! The Moon is touching the Sun.',
      scheduledDate: event.startUtc,
    );

    // 2 minutes before totality
    await _scheduleNotification(
      id: '${event.id}_2m'.hashCode,
      title: '⚠️ 2 Minutes to Totality',
      body: 'Watch for shadow bands and prepare for glasses-off!',
      scheduledDate: event.peakUtc.subtract(const Duration(minutes: 2)),
    );

    // Second contact (C2) - Totality begins
    await _scheduleNotification(
      id: '${event.id}_c2'.hashCode,
      title: '🌑 TOTALITY! GLASSES OFF!',
      body: 'Remove your glasses NOW! Enjoy the corona!',
      scheduledDate: event.peakUtc.subtract(Duration(seconds: event.maxDurationSeconds ?? 120 ~/ 2)),
    );

    // Peak
    await _scheduleNotification(
      id: '${event.id}_peak'.hashCode,
      title: '✨ Maximum Eclipse',
      body: 'Peak of totality - look for planets and corona!',
      scheduledDate: event.peakUtc,
    );

    // Third contact (C3) - Totality ends
    await _scheduleNotification(
      id: '${event.id}_c3'.hashCode,
      title: '⚠️ GLASSES ON!',
      body: 'Put your glasses back on NOW! Diamond ring visible!',
      scheduledDate: event.peakUtc.add(Duration(seconds: event.maxDurationSeconds ?? 120 ~/ 2)),
    );

    // Fourth contact (C4) - Eclipse ends
    await _scheduleNotification(
      id: '${event.id}_c4'.hashCode,
      title: '🌞 Eclipse Complete',
      body: 'The eclipse has ended. What an amazing experience!',
      scheduledDate: event.endUtc,
    );
  }

  /// Schedule a single notification
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Don't schedule past notifications
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'eclipse_alerts',
      'Eclipse Alerts',
      channelDescription: 'Important notifications for eclipse events',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Show immediate notification
  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'eclipse_alerts',
      'Eclipse Alerts',
      channelDescription: 'Important notifications for eclipse events',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  /// Cancel all notifications for an event
  static Future<void> cancelEventNotifications(String eventId) async {
    // Cancel all notification variants
    final ids = [
      '${eventId}_30d',
      '${eventId}_7d',
      '${eventId}_24h',
      '${eventId}_6h',
      '${eventId}_1h',
      '${eventId}_15m',
      '${eventId}_c1',
      '${eventId}_2m',
      '${eventId}_c2',
      '${eventId}_peak',
      '${eventId}_c3',
      '${eventId}_c4',
    ];

    for (final id in ids) {
      await _notifications.cancel(id.hashCode);
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
