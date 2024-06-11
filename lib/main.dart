import 'package:flutter/material.dart';
import 'package:gaemcosign/homepage.dart';
import 'package:gaemcosign/notification_setting.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService notificationService = NotificationService();
  await notificationService.initNotification();
  await Hive.initFlutter();
  await Hive.openBox('reminder_box');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
