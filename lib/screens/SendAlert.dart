import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:atfind/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:atfind/service.dart';
import 'package:at_commons/at_commons.dart';

class SendAlert extends StatefulWidget {
  const SendAlert({key}) : super(key: key);
  static final String id = 'sixth';
  @override
  _SendAlertState createState() => _SendAlertState();
}

enum LocationUpdate { travelling, arrived }

class _SendAlertState extends State<SendAlert> {
  ClientService clientSdkService = ClientService.getInstance();
  String? activeAtSign, receiver, _otherAtSign, alert;
  var _update = LocationUpdate.travelling;
  String __key = 'Update';

  @override
  void initState() {
    super.initState();
    activeAtSign =
        clientSdkService.atClientServiceInstance.getAtSign().toString();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Send Alert',
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                'Where are you?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            RadioListTile<LocationUpdate>(
              title: const Text('Travelling'),
              activeColor: Colors.red[300],
              value: LocationUpdate.travelling,
              groupValue: _update,
              onChanged: (value) {
                setState(() {
                  _update = value!;
                });
              },
            ),
            RadioListTile<LocationUpdate>(
              title: const Text('Arrived'),
              activeColor: Colors.red[300],
              value: LocationUpdate.arrived,
              groupValue: _update,
              onChanged: (value) {
                setState(() {
                  _update = value!;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                'Who would you like to notify?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10.0),
              child: TextField(
                decoration: InputDecoration(hintText: 'Enter an @sign'),
                onChanged: (value) {
                  _otherAtSign = value;
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_update == LocationUpdate.arrived) {
            alert = 'Arrived';
            _share(context, _otherAtSign!, alert!);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Sent alert!'),
              duration: Duration(milliseconds: 1000),
            ));
            print('curr_alert: $alert');
          } else if (_update == LocationUpdate.travelling) {
            alert = 'Travelling';
            _share(context, _otherAtSign!, alert!);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Sent alert!'),
              duration: Duration(milliseconds: 1000),
            ));
            print('curr_alert: $alert');
          } else {
            alert = null;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Something went wrong :/'),
              duration: Duration(milliseconds: 1000),
            ));
            print('curr_alert: $alert');
          }
          // putUpdate(alert, __key);
        },
        label: Text('Send Alert'),
        backgroundColor: Colors.red[300],
      ),
    );
  }

  Future<AtKey> putUpdate(String state, String SharedWith) async {
    ClientService clientSdkService = ClientService.getInstance();
    var atSign = clientSdkService.getAtSign().toString();
    print('other: $SharedWith');
    setState(() {
      alert = state;
    });
    AtKey currUpdate = AtKey()
      ..key = __key
      ..sharedWith = SharedWith
      ..sharedBy = atSign;
    await clientSdkService.put(currUpdate, alert!);
    return currUpdate;
    /*String buffer;
    buffer = await clientSdkService.get(currUpdate);
    print(buffer);*/
  }

  _share(BuildContext context, String sharedWith, String _alert) async {
    //ClientService clientSdkService = ClientService.getInstance();
    print('alert: $_alert');
    AtKey put = await putUpdate(_alert, sharedWith);

    var operation = OperationEnum.update;

    await ClientService.getInstance().notify(put, _alert, operation);
  }
  // }
}
