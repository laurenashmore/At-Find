import 'package:flutter/cupertino.dart';
import 'package:at_location_flutter/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  static final String id = 'home';
  @override
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Home> {
  @override

  Widget build(BuildContext content) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(
              bottom: 200.0),
          child: TextButton(
            onPressed: () async {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
            child: Text('Go to map!'),
            style: TextButton.styleFrom(
                backgroundColor: Colors.grey[850],
                primary: Colors.white,
                side: BorderSide(color: Colors.grey[850]!, width: 2),
                padding: EdgeInsets.all(10),
                minimumSize: Size(200, 35)),
          ),
        ),
      ),
    );
  }
}