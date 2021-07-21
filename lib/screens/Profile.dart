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
  String _namekey = 'nameupdate';
  String update = '';
  String nameupdate = '';
  String _name = '';

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
          'Profile of $activeAtSign',
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            IconButton(
              icon: Icon(Icons.face),
              iconSize: 50,
              color: Colors.black,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 250,
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(),
                                    hintText: 'John',
                                    labelText: 'Your name:',
                                  ),
                                  onChanged: (nameValue) {
                                    _name = nameValue;
                                  },
                                ),
                              ),
                              FloatingActionButton(
                                onPressed: () async {
                                  getName(_name, _namekey);
                                  print('name saved');
                                  },
                                child: Icon(Icons.add),
                                backgroundColor: Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              ),
            FutureBuilder(
                future: _nameScan(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    List<String> attrs = snapshot.data;
                    for (String attr in attrs) {
                      if (attr.contains("nameupdate")) {
                        List<String> temp = attr.split(":");
                        nameupdate = temp[1];
                      }
                    }
                  }
                  return Container(
                    child: Text('$nameupdate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  );
                }
            ),
            SizedBox(height: 200),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 250,
                  height:100,
                  child: TextField(
                    style: TextStyle(
                      fontSize: 20,
                      height: 2,
                      color: Colors.black,
                    ),
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
            SizedBox(height:100),
            Text('Status:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height:10),
            Stack(
              children: [
                Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[300]
                ),
                Center(
                  child: FutureBuilder(
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
                        child: Text('$update', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.grey[900])),
                      );
                    },
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  /// Get status
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

/// Get name
  void getName(String name, String _namekey) async {
    ClientService clientSdkService = ClientService.getInstance();
    String? atSign = clientSdkService.atsign;
    setState(() {
      _name = name;
    });
    AtKey currName = AtKey()
      ..key = _namekey
      ..sharedWith = atSign;
    await clientSdkService.put(currName, _name);
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

  /// Scan for status key objects
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

  /// Scan for name key objects
  _nameScan() async {
    ClientService clientSdkService = ClientService.getInstance();
    List<AtKey> response;
    String? regex = '^(?!cached).*atfind.*';
    response = await clientSdkService.getAtKeys(regex:'^(?!cached).*atfind.*' );
    response.retainWhere((element) => !element.metadata!.isCached);
    List<String> responseList = [];
    for (AtKey atKey in response) {
      String nameValue = await _lookup(atKey);
      nameValue = (atKey.key! +":"+ nameValue);

      responseList.add(nameValue);
    }
    return responseList;
  }

/// Go back to home screen
  createStatusAlertDialog(BuildContext context){
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        content: Text("Activity Status Updated!"),
      );
    });
  }
}