import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  final notifications = NotificationService();
  await notifications.init();
  await notifications.requestPermissions();
  // Notificación diaria a las 7:50 am — se puede cambiar aquí si algún día quieres otra hora.
  await notifications.scheduleDaily(hour: 7, minute: 50);

  runApp(const PostalParaPaoApp());
}

class PostalParaPaoApp extends StatelessWidget {
  const PostalParaPaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Postal para Pao',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
