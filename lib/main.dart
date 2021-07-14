import 'package:atfind/screens/Contacts.dart';
import 'package:atfind/location/Home.dart';
import 'package:flutter/material.dart';
import 'package:atfind/screens/Onboarding.dart';
import 'package:atfind/screens/Profile.dart';
import 'package:atfind/screens/Settings.dart';
import 'package:atfind/screens/SendAlert.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIND',
      //navigatorKey: NavService.navKey,
      theme: ThemeData(
        primaryColor: Colors.grey[400],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: OnboardingScreen.id,
      routes: {
        OnboardingScreen.id: (context) => OnboardingScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        Profile.id: (context) => Profile(),
        Contacts.id: (context) => Contacts(),
        Settings.id: (context) => Settings(),
        SendAlert.id: (context) => SendAlert(),

      },
    );
  }
}
