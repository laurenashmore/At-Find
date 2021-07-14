import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_group_flutter/utils/init_group_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:at_contacts_flutter/screens/contacts_screen.dart';
import 'package:at_contacts_group_flutter/screens/list/group_list.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';

import '../constants.dart';
import '../service.dart';


class Contacts extends StatefulWidget {
  static final String id = 'contacts';
  @override
  _ContactsState createState() => _ContactsState();
}
class _ContactsState extends State<Contacts> {
  ClientService clientSdkService = ClientService.getInstance();
  String? activeAtSign;


  @override
  void initState() {
    getAtSignAndInitializeContacts();
    super.initState();
  }
  @override
  void dispose() {
    disposeContactsControllers();
    super.dispose();
  }


  Widget build(BuildContext content) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) => ContactsScreen(),
                  )
              );
            },
            child: Text('Contacts!'),
            style: TextButton.styleFrom(
                backgroundColor: Colors.grey[850],
                primary: Colors.white,
                side: BorderSide(color: Colors.grey[850]!, width: 2),
                padding: EdgeInsets.all(10),
                minimumSize: Size(200, 35)),
          ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => GroupList(),
                    )
                );
              },
              child: Text('Contacts Group!'),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[850],
                  primary: Colors.white,
                  side: BorderSide(color: Colors.grey[850]!, width: 2),
                  padding: EdgeInsets.all(10),
                  minimumSize: Size(200, 35)),
            ),
      ],
        ),
      ),
    );
}
  /// Initialize Contacts (stuff)
  void getAtSignAndInitializeContacts() async {
    var currentAtSign = await (clientSdkService.getAtSign());
    setState(() {
      activeAtSign = currentAtSign;
    });
    initializeContactsService(
        clientSdkService.atClientServiceInstance!.atClient!, currentAtSign!,
        rootDomain: MixedConstants.ROOT_DOMAIN);
    initializeGroupService(
        clientSdkService.atClientServiceInstance!.atClient!, currentAtSign!,
        rootDomain: MixedConstants.ROOT_DOMAIN);
  }
}