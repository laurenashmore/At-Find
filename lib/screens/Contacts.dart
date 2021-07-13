import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:at_contacts_flutter/screens/contacts_screen.dart';

class Contacts extends StatefulWidget {
  static final String id = 'contacts';
  @override
  _ContactsState createState() => _ContactsState();
}
class _ContactsState extends State<Contacts> {
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
                  MaterialPageRoute(builder: (context) => ContactsScreen(),
                  )
              );
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