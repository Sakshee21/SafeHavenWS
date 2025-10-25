import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_setup/step1_profile_info.dart';
import 'screens/profile_setup/step2_choose_role.dart';
import 'screens/home/user_home.dart';
import 'screens/home/volunteer_home.dart';
import 'screens/home/combined_home.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // requires flutterfire configure
  );
  runApp(const SafeHavenApp());
}

class SafeHavenApp extends StatelessWidget {
  const SafeHavenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData(
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.white,
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'SafeHaven',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF6A1B9A),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginScreen(),
        '/signup': (_) => SignUpScreen(),
        '/profile-step1': (_) => const Step1ProfileInfo(),
        // Step2 route is normally invoked with constructor arg in navigation after step1;
        '/profile-step2': (_) => const Step2ChooseRole(gender: 'Female'),

        '/user_home': (_) => const UserHome(),
        '/volunteer_home': (_) => const VolunteerHome(),
        '/combined_home': (_) => const CombinedHome(),

      },
    );
  }
}
