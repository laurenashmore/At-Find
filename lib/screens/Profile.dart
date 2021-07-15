import 'package:flutter/material.dart';
import 'package:at_commons/at_commons.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:atfind/service.dart';
import 'package:atfind/constants.dart' as constant;

class Profile extends StatefulWidget {
  static final String id = 'third';
  String? atSign;
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ClientService clientSdkService = ClientService.getInstance();
  String ?activeAtSign, receiver;

  String _status = '';
  String _key = 'statusupdate';
  String update = '';

  @override
  void initState() {
    super.initState();
    activeAtSign =
        clientSdkService.atsign;
  }

  /// Layout
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              Icons.location_pin,
              size: 140,
              color: Colors.red[300],
            ),
            Text(
              '$activeAtSign',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: 'At home',
                      labelText: 'Activity Status',
                    ),
                    onChanged: (value) {
                      _status = value;
                    },
                  ),
                ),
                FloatingActionButton(
                  onPressed: () {
                    getStatus(_status, _key);
                  },
                  tooltip: 'Update status',
                  child: Icon(Icons.add),
                  backgroundColor: Colors.red[300],
                ),
              ],
            ),
            Text('Current status: $_status',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            FutureBuilder(
              future: _scan(),
              builder:
                  (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                   List<String> attrs = snapshot.data;
                  // print("TEST1: "+snapshot.data.toString());

                  for(String attr in attrs){
                    // List<String> attrlist = attr.split(constant.splitter);
                    // int attrlen = attrlist.length;
                    // print("TEST2: "+"$attrlen");
                    if(attr.contains("statusupdate")) {
                      // print("TEST3: "+attr);

                      List<String> temp = attr.split(":");
                      update = temp[1];
                      // update = attr.replaceRange(0, 12, "");
                    }
                  }

                 // update = snapshot.data.toString();
                }
                return Container(
                  child: Text('$update', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void getStatus(String status, String _key) async {
    ClientService clientSdkService = ClientService.getInstance();
    String? atSign = clientSdkService.atsign;

    setState(() {
      _status = status;
    });

    AtKey currStatus = AtKey()
      ..key = _key
      ..sharedWith = atSign;
    // ..sharedBy = activeAtSign

    await clientSdkService.put(currStatus, _status);


    // Title of key: String _key = 'statusupdate';
    // Content of key: _status
    // String buffer;
    // buffer = await clientSdkService.get(currStatus);
    // print(buffer);
  }


/// Look up a value corresponding to an [AtKey] instance.
  Future<String> _lookup(AtKey atKey) async {
    ClientService clientSdkService = ClientService.getInstance();
    // If an AtKey object exists
    if (atKey != null) {
      // Simply get the AtKey object utilizing the serverDemoService's get method
      return await clientSdkService.get(atKey);
    }
    return '';
  }
  /// Scan for [AtKey] objects with the correct regex.
  _scan() async {
    ClientService clientSdkService = ClientService.getInstance();
    // Instantiate a list of AtKey objects to house each cached recipe from
    // the secondary server of the authenticated atsign
    List<AtKey> response;
    // This regex is defined for searching for an AtKey object that carries the
    // namespace of cookbook and that have been created by the authenticated
    // atsign (the currently logged in atsign)
    String? regex = '^(?!cached).*atfind.*';
    // Getting the recipes that are cached on the authenticated atsign's secondary
    // server utilizing the regex expression defined earlier
    response = await clientSdkService.getAtKeys(regex:'^(?!cached).*atfind.*' );
    response.retainWhere((element) => !element.metadata!.isCached);
    // Instantiating a list of strings
    List<String> responseList = [];
    // Looping through every instance of an AtKey object
    for (AtKey atKey in response) {
      // We get the current AtKey object that we are looping on
      String value = await _lookup(atKey);
      // In addition to the object we are on, we add the name of the recipe,
      // the constant splitter to segregate the fields, and again, the value of
      // the recipe which includes; description, ingredients, and image URL
      value = (atKey.key! +":"+ value);
      // Add current AtKey object to our list of strings defined earlier before
      // for loop
      responseList.add(value);
    }
    // After successfully looping through each AtKey object instance,
    // return list of strings
    //return responseList;
    return responseList;
  }
}