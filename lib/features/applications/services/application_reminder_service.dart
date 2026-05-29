import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../domain/application.dart';

/// Schedules / cancels local follow-up reminders for job applications.
///
/// Call [initialize] once at app startup (in main.dart) before any other
/// notification calls. Both iOS and Android permissions are requested lazily
/// the first time a reminder is set.
class ApplicationReminderService {
  ApplicationReminderService._();
  static final ApplicationReminderService instance =
      ApplicationReminderService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Init ───────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false, // ask lazily
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _plugin.initialize(initSettings);
  }

  // ── Schedule ───────────────────────────────────────────────────────────────

  /// Schedule (or reschedule) a follow-up reminder for [application].
  /// No-op if [application.followUpAt] is null or in the past.
  Future<void> scheduleFor(Application application) async {
    if (!_initialized) return;
    if (application.followUpAt == null) return;
    final when = application.followUpAt!;
    if (when.isBefore(DateTime.now())) return;

    // Request iOS permission the first time we actually need it
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    final notifId = _idFor(application.id);
    final tzWhen = tz.TZDateTime.from(when, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'follow_up_reminders',
      'Follow-up Reminders',
      channelDescription: 'Reminders to follow up on job applications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final company = application.company.isNotEmpty
        ? application.company
        : 'your application';

    await _plugin.zonedSchedule(
      notifId,
      'Follow-up Reminder',
      'Don\'t forget to follow up on your application to $company',
      tzWhen,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('[Reminders] Scheduled notif #$notifId for $company at $when');
  }

  /// Cancel any pending reminder for the given application id.
  Future<void> cancelFor(String applicationId) async {
    if (!_initialized) return;
    await _plugin.cancel(_idFor(applicationId));
    debugPrint('[Reminders] Cancelled notif for $applicationId');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Derive a stable int notification id from a UUID string.
  int _idFor(String applicationId) => applicationId.hashCode.abs() % 100000;
}

// ── Provider ─────────────────────────────────────────────────────────────────

final applicationReminderServiceProvider = Provider<ApplicationReminderService>(
  (ref) {
    return ApplicationReminderService.instance;
  },
);
