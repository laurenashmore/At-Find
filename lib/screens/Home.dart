import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:at_location_flutter/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import '../service.dart';
import 'Contacts.dart';
import 'Profile.dart';
import 'SendAlert.dart';
import 'Settings.dart';

class Home extends StatefulWidget {
  static final String id = 'home';
  String activeAtSign = '';
  @override
  _HomeState createState() => _HomeState();
}
/// OK

class _HomeState extends State<Home> {
  ClientService clientSdkService = ClientService.getInstance();
  String activeAtSign = '';
  GlobalKey<ScaffoldState> ?scaffoldKey;
  /// OK

  @override
  void initState() {
  getAtSignAndInitContacts();
  scaffoldKey = GlobalKey<ScaffoldState>();
  super.initState();
}
/// OK

@override
Widget build(BuildContext content) {
    return SafeArea(
      child: Scaffold(
      body: Column(
        children: [
          TextButton(
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

        Container(
          height: 77,
          width: 356,
          margin:
          EdgeInsets.symmetric(horizontal: 10., vertical: 10.),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10.0,
                spreadRadius: 1.0,
                offset: Offset(0.0, 0.0),
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  icon: Icon(Icons.account_circle_outlined),
                  iconSize: 50,
                  color: Colors.grey[900],
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => Profile()));
                  }),
              IconButton(
                  icon: Icon(Icons.people_alt_outlined),
                  iconSize: 50,
                  color: Colors.grey[900],
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Contacts()));
                  }),
              IconButton(
                  icon: Icon(Icons.notifications_active_outlined),
                  iconSize: 50,
                  color: Colors.grey[900],
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SendAlert()));
                  }),
              IconButton(
                  icon: Icon(Icons.settings_outlined),
                  iconSize: 50,
                  color: Colors.grey[900],
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Settings()));
                  })
            ],
          ),
        );
      ),
      ),
      );
  }


getAtSignAndInitContacts() async {
  String currentAtSign = await ClientService.getInstance().getAtSign();
  setState(() {
    activeAtSign = currentAtSign;
  });
  initializeLocationService(clientSdkService.atClientServiceInstance.atClient,
      activeAtSign, NavService.navKey, apiKey: 'apiKey', mapKey: 'mapKey');
}
}

class NavService {
  static GlobalKey<NavigatorState> navKey = GlobalKey();
}

