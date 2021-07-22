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
  String? activeAtSign, receiver;
  String _status = '';
  String _key = 'statusupdate';
  String _namekey = 'nameupdate';
  String update = '';
  String nameupdate = '';
  String _name = '';

  @override
  void initState() {
    super.initState();
    activeAtSign = clientSdkService.atsign;
  }

  /// Layout
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('$activeAtSign', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                          child: Text('$nameupdate',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 50)),
                        );
                      }),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical:40 , horizontal: 12),
                      child: Center(
                        child: FutureBuilder(
                          future: _scan(),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasData) {
                              List<String> attrs = snapshot.data;
                              for (String attr in attrs) {
                                if (attr.contains("statusupdate")) {
                                  List<String> temp = attr.split(":");
                                  update = temp[1];
                                  // update = attr.replaceRange(0, 12, "");
                                }
                              }
                            }
                            return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.directions_walk, color: Colors.red[300], size: 55,),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 5),
                                          child: Text('Current Status:',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[900])),
                                        ),
                                        Text('$update',
                                            style: TextStyle(
                                                fontSize: 23,
                                                color: Colors.grey[900])),
                                      ],
                                    ),
                                  ),
                                ]
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),



            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 250,
                  height: 100,
                  child: TextField(
                    style: TextStyle(
                      fontSize: 15,
                      height: 2,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: 'At home',
                      labelText: 'Update Activity Status',
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
                    await Future.delayed(const Duration(seconds: 3), () {});
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                  tooltip: 'Update status',
                  child: Icon(Icons.add),
                  backgroundColor: Colors.red[300],
                ),
              ],
            ),
            //SizedBox(height:100),
           /* Text(
              'Status: $_status',
              style: TextStyle(fontSize: 18),
            ),*/
            //SizedBox(height:10),


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
    response = await clientSdkService.getAtKeys(regex: '^(?!cached).*atfind.*');
    response.retainWhere((element) => !element.metadata!.isCached);
    List<String> responseList = [];
    for (AtKey atKey in response) {
      String value = await _lookup(atKey);
      value = (atKey.key! + ":" + value);

      responseList.add(value);
    }
    return responseList;
  }

  /// Scan for name key objects
  _nameScan() async {
    ClientService clientSdkService = ClientService.getInstance();
    List<AtKey> response;
    String? regex = '^(?!cached).*atfind.*';
    response = await clientSdkService.getAtKeys(regex: '^(?!cached).*atfind.*');
    response.retainWhere((element) => !element.metadata!.isCached);
    List<String> responseList = [];
    for (AtKey atKey in response) {
      String nameValue = await _lookup(atKey);
      nameValue = (atKey.key! + ":" + nameValue);

      responseList.add(nameValue);
    }
    return responseList;
  }

  /// Go back to home screen
  createStatusAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Activity Status Updated!"),
          );
        });
  }
}
