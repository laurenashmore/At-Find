// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:at_commons/at_commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:atfind/service.dart';

class Status extends StatefulWidget {
  static final String id = 'seventh';
  // String? atSign;
  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> {
  ClientService clientSdkService = ClientService.getInstance();
  String? activeAtSign, receiver;
  // String _status = '';
  // String _key = 'statusupdate';
  String update = '';

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
          title: Text(
            'Current Statuses',
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: FutureBuilder(
                    future: _getSharedStatuses(),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        //Map sharedStatus = snapshot.data;
                        print(snapshot.data);

                        return SafeArea(
                            child: ListView.builder(
                                itemCount: snapshot.data.length,
                                padding: const EdgeInsets.all(8),
                                itemBuilder: (BuildContext context, int index) {
                                  return new ListTile(
                                    // title: new Text('Title'),
                                    title: FutureBuilder(
                                      future: snapshot.data[index],
                                      builder: (BuildContext context,
                                          AsyncSnapshot<dynamic> snapshot) {
                                        if (snapshot.hasData) {
                                          return snapshot.data;
                                        }
                                        return Container();
                                      },
                                    ),
                                  );
                                }));
                      } else if (snapshot.hasError) {
                        return Text('An error has occurred: ' +
                            snapshot.error.toString());
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ));
  }

  /// Returns the list of Shared Recipes keys.
  Future<List<AtKey>> _getSharedKeys() async {
    ClientService clientSdkService = ClientService.getInstance();
    String atSign = clientSdkService.atsign;
    print(atSign);

    //await clientSdkService.t_sync();
    var data = await clientSdkService.getKeysWithRegex('cached.*atfind',
        sharedWith: atSign);
    print(data);
    return data;
    // Took regex: 'cached.*atfind' out of getatkeys
  }

  /// Returns a map of Shared key and values.
  Future<List<Future<Text>>> _getSharedStatuses() async {
    ClientService clientSdkService = ClientService.getInstance();

    List<AtKey> sharedKeysList =
        (await _getSharedKeys()).where((AtKey element) {
      print("element's key: ${element.key}");
      var result =
          (element.key?.trim().toLowerCase() ?? '') == 'statusupdate' ||
              (element.key?.trim().toLowerCase() ?? '') == 'update';
      print('result: $result');
      return result;
    }).toList();
    var widgets = sharedKeysList.map((element) async {
      var value = await clientSdkService.get(element);
      print(value);
      //  statuses[element] = value
      if (element.key!.trim().toLowerCase() == 'statusupdate') {
        return Text('Status -> ${element.sharedBy}: $value');
      }

      return Text('Alert -> ${element.sharedBy}: $value');
    }).toList();
    return widgets;
  }
}
