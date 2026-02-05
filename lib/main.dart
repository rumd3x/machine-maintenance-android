import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'services/machine_provider.dart';
import 'services/notification_provider.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Request notification permissions
  await notificationService.requestPermissions();
  
  // Request exact alarm permission (required for Android 12+)
  final canScheduleExact = await notificationService.canScheduleExactAlarms();
  if (!canScheduleExact) {
    await notificationService.requestExactAlarmPermission();
  }
  
  // Initialize background service for reliable notification delivery
  final backgroundService = BackgroundService();
  await backgroundService.initialize();
  
  // Schedule immediate check for due maintenance
  await backgroundService.triggerImmediateCheck();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MachineProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Machine Maintenance',
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
