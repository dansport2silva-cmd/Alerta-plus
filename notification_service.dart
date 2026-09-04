import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/reminder_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(initSettings);
  }

  Future<void> scheduleNotification(ReminderModel reminder) async {
    if (!reminder.notificationEnabled) return;

    final androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Lembretes',
      channelDescription: 'Canal de notificações de lembretes',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      color: reminder.category.color,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description ?? 'Hora do seu lembrete!',
      tz.TZDateTime.from(reminder.dateTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(String reminderId) async {
    await _notifications.cancel(reminderId.hashCode);
  }

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Teste',
      channelDescription: 'Canal para testar notificações',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      '🔔 Alerta Plus',
      'Sua notificação está funcionando!',
      details,
    );
  }
}
