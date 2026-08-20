import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

/// Teasers cortitos para la notificación — no revelan el mensaje del día,
/// solo avisan que "llegó correo nuevo". El mensaje real se ve al abrir la app.
const List<String> _teasers = [
  '📮 Tienes correspondencia nueva de tu persona favorita.',
  '✉️ Una carta acaba de llegar para ti.',
  '💌 El cartero pasó por aquí esta mañana...',
  '📬 Correo entregado. Firma con una sonrisa.',
  '🕊️ Un mensajito voló hasta tu buzón.',
];

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    final locationName = DateTime.now().timeZoneName;
    try {
      tz.setLocalLocation(tz.getLocation(locationName));
    } catch (_) {
      // Si no reconoce el nombre exacto de la zona, usa la UTC local del dispositivo
      // (flutter_local_notifications igual programa en hora local del sistema).
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Programa la notificación diaria repetida a la hora indicada (por defecto 7:50 am).
  Future<void> scheduleDaily({int hour = 7, int minute = 50}) async {
    await init();
    await _plugin.cancel(100);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final teaser = _teasers[DateTime.now().day % _teasers.length];

    await _plugin.zonedSchedule(
      100,
      'Correo para Pao',
      teaser,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'correo_diario',
          'Correo diario',
          channelDescription: 'Recordatorio diario de tu cartita',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
