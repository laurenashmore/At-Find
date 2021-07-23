import 'package:atfind/screens/Contacts.dart';
import 'package:atfind/location/Home.dart';
import 'package:flutter/material.dart';
import 'package:atfind/screens/Onboarding.dart';
import 'package:atfind/screens/Profile.dart';
import 'package:atfind/screens/Settings.dart';
import 'package:atfind/screens/SendAlert.dart';
import 'package:atfind/screens/Current_Statuses.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIND',
      theme: ThemeData(
        primaryColor: Colors.grey[900],
        accentColor: Colors.red[300],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: OnboardingScreen.id,
      routes: {
        OnboardingScreen.id: (context) => OnboardingScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        Profile.id: (context) => Profile(),
        GroupList.id: (context) => GroupList(),
        Settings.id: (context) => Settings(),
        SendAlert.id: (context) => SendAlert(),
        Status.id: (context) => Status(),
      },
    );
  }
}


class NavService {
  static GlobalKey<NavigatorState> navKey = GlobalKey();
}
