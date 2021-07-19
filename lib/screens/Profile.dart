import 'dart:io';

import 'package:flutter/material.dart';
import 'package:at_commons/at_commons.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:atfind/service.dart';
import 'package:atfind/constants.dart' as constant;
import 'package:atfind/location/Home.dart';

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
                  onPressed: () async {
                    getStatus(_status, _key);
                    createStatusAlertDialog(context);
                    await Future.delayed(const Duration(seconds: 3), (){});
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => HomeScreen()));
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
                  for(String attr in attrs){
                    if(attr.contains("statusupdate")) {
                      List<String> temp = attr.split(":");
                      update = temp[1];
                      // update = attr.replaceRange(0, 12, "");
                    }
                  }
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
    await clientSdkService.put(currStatus, _status);
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
    List<AtKey> response;
    String? regex = '^(?!cached).*atfind.*';
    response = await clientSdkService.getAtKeys(regex:'^(?!cached).*atfind.*' );
    response.retainWhere((element) => !element.metadata!.isCached);
    List<String> responseList = [];
    for (AtKey atKey in response) {
      String value = await _lookup(atKey);
      value = (atKey.key! +":"+ value);

      responseList.add(value);
    }
    return responseList;
  }

  createStatusAlertDialog(BuildContext context){
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        content: Text("Activity Status Updated!"),
      );
    });
  }
}