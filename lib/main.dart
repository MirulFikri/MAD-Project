import 'package:flutter/material.dart';
import 'package:petcare_app/create_account/signup_screen.dart';
import 'package:petcare_app/login/login_screen.dart';
import 'package:petcare_app/bottom_navigation/owner_navigation.dart';
import 'package:petcare_app/bottom_navigation/clinic_navigation.dart';
import 'package:petcare_app/reminders/reminder_screen.dart' as reminder;
import 'package:petcare_app/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF111111)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFEFF7FF),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/owner_home': (context) => const OwnerNavigation(),
        '/clinic_home': (context) => const ClinicNavigation(),
        '/reminders': (context) => const reminder.ReminderScreen(),
      },
    );
  }
}
