import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'juh_reminders';
  static const _channelName = 'تذكيرات المواعيد';
  static const _channelDesc =
      'تذكيرات مواعيد مستشفى الجامعة الأردنية — JUH Appointment Reminders';

  // Call once from main() before runApp
  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final tzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      // Fallback to UTC if timezone lookup fails
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Create the Android notification channel
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
          playSound: true,
        ),
      );
      // Request POST_NOTIFICATIONS permission (Android 13+)
      await android.requestNotificationsPermission();
    }
  }

  // ── Notification details ──────────────────────────────────────────────────

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF003B4B),
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  // ── ID scheme ─────────────────────────────────────────────────────────────
  // base = hash(appointmentId) % 300_000
  // base*3+0 → immediate confirmation
  // base*3+1 → day-before reminder
  // base*3+2 → hour-before reminder

  static int _id(String apptId, int offset) =>
      (apptId.hashCode.abs() % 300000) * 3 + offset;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Show an immediate "booking confirmed" notification.
  static Future<void> notifyBookingConfirmed({
    required String appointmentId,
    required String doctorNameAr,
    required String doctorNameEn,
    required String refCode,
  }) async {
    await _plugin.show(
      _id(appointmentId, 0),
      'تم تأكيد حجزك ✓ | Booking Confirmed',
      'مع $doctorNameAr • رقم المرجع: $refCode\nWith $doctorNameEn • Ref: $refCode',
      _details,
    );
  }

  /// Schedule a reminder 1 day before and 1 hour before the appointment.
  static Future<void> scheduleReminders({
    required String appointmentId,
    required DateTime appointmentTime,
    required String doctorNameAr,
    required String doctorNameEn,
    required String specialtyAr,
    required String specialtyEn,
  }) async {
    final now = DateTime.now();

    // 1 day before
    final dayBefore = appointmentTime.subtract(const Duration(days: 1));
    if (dayBefore.isAfter(now)) {
      await _plugin.zonedSchedule(
        _id(appointmentId, 1),
        'تذكير: موعدك غداً | Appointment Tomorrow',
        'مع $doctorNameAr — $specialtyAr\nWith $doctorNameEn — $specialtyEn',
        tz.TZDateTime.from(dayBefore, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // 1 hour before
    final hourBefore = appointmentTime.subtract(const Duration(hours: 1));
    if (hourBefore.isAfter(now)) {
      await _plugin.zonedSchedule(
        _id(appointmentId, 2),
        'موعدك بعد ساعة | Appointment in 1 Hour',
        'مع $doctorNameAr — $specialtyAr\nWith $doctorNameEn — $specialtyEn',
        tz.TZDateTime.from(hourBefore, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// Cancel all reminders for a given appointment (e.g. on cancellation).
  static Future<void> cancelReminders(String appointmentId) async {
    await _plugin.cancel(_id(appointmentId, 1));
    await _plugin.cancel(_id(appointmentId, 2));
  }
}
