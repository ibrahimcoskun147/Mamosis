import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'data/datasources/doctor_seeder.dart';
import 'core/services/logger.dart';

void main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // Load environment variables
    await dotenv.load(fileName: '.env');

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize dependencies
    await initDependencies();
    
    // Seed doctors to Firestore
    try {
      final doctorSeeder = DoctorSeeder();
      await doctorSeeder.seedDoctors();
      Logger.i('Doctors seeded successfully', 'Main');
    } catch (e) {
      Logger.e('Failed to seed doctors: $e', e, null, 'Main');
    }
    
    // Check if onboarding was completed
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    
    runApp(MamosisApp(showOnboarding: !onboardingComplete));
  }, (error, stack) {
    Logger.e('Unhandled error caught in root zone', error, stack, 'Main');
  });
}

class MamosisApp extends StatelessWidget {
  final bool showOnboarding;
  
  const MamosisApp({
    super.key,
    required this.showOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mamosis',
      theme: AppTheme.lightTheme,
      home: showOnboarding 
          ? const OnboardingScreen() 
          : const LoginScreen(),
    );
  }
}