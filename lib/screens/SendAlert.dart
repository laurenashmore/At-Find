
import 'package:at_common_flutter/widgets/custom_input_field.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:atfind/service.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import '../service.dart';


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
  String? currentAtSign;
  ContactService? _contactService;
  AtContact? selectedContact;
  late bool isLoading;
  String? selectedOption, textField;
  bool errorOcurred = false;
  String searchText = '';
  List<String> allContactsList = [];
  String at_signStr = '';
  List<String> at_signStrList = [];
  String selectedAtSign = '';

  @override
  void initState() {
    _contactService = ContactService();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      var _result = await _contactService!.fetchContacts();
      print('$_result = true');

      if (_result == null) {
        print('_result = true');
        if (mounted) {
          setState(() {
            errorOcurred = true;
          });
        }
      }
    });
   // _otherAtSign = at_signStrList[0];
    super.initState();
    activeAtSign =
        clientSdkService.atClientServiceInstance.getAtSign().toString();
    isLoading = false;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Send Alert', style: TextStyle(color: Colors.white)),
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
            /// Contact drop down:
            Row(
              children: [
                SizedBox(width: 30), // (so sorry lauren)
                Padding(
                    padding: EdgeInsets.only(top: 25, bottom: 25, right: 30),
                    child: Text('Contacts:')
                ),
                Padding(
                  padding: EdgeInsets.only(top: 25, bottom: 25),
                  child: StreamBuilder<List<AtContact?>>(
                      stream: _contactService!.contactStream,
                      initialData: _contactService!.contactList,
                      builder: (context, snapshot) {
                        if ((snapshot.connectionState == ConnectionState.waiting)) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          if ((snapshot.data == null || snapshot.data!.isEmpty)) {
                            return Center(
                              child: Text('No contacts added'),
                            );
                          } else {
                            var _filteredList = <AtContact?>[];
                            snapshot.data!.forEach(
                                    (c) {
                                  if (c!.atSign!
                                      .toUpperCase()
                                      .contains(searchText.toUpperCase())) {
                                    _filteredList.add(c);
                                    var c_str = c.toString();
                                    var sub_c_arr = c_str.split(",");
                                    var at_signStr_arr = sub_c_arr[0].split(": ");
                                    at_signStr = at_signStr_arr[1];
                                    print(at_signStr);
                                    if(!at_signStrList.contains(at_signStr)){
                                      at_signStrList.add(at_signStr);
                                    }

                                  }
                                }
                            );
                            print("ATSIGN LIST: $at_signStrList");
                            return DropdownButton<String>(
                              value: _otherAtSign,
                              items: at_signStrList
                                  .map((atSign) =>
                                  DropdownMenuItem(child: Text(atSign), value: atSign))
                                  .toList(),
                              onChanged: (new_atSign) => {
                                if(new_atSign != null){
                                  setState((){
                                    _otherAtSign = new_atSign!;
                                  })
                                }
                              },
                            );
                          }
                        }
                      }),

                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10.0),
              child: CustomInputField(
                width: 330,
                height: 50,
                hintText: 'Type @sign ',
                initialValue: _otherAtSign ?? '',
                value: (str) {
                  if (!str.contains('@')) {
                    str = '@' + str;
                  }
                  _otherAtSign = str;
                },
                icon: Icons.contacts_rounded,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10.0),
              child: Container(),
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
  }

  _share(BuildContext context, String sharedWith, String _alert) async {
    print('alert: $_alert');
    AtKey put = await putUpdate(_alert, sharedWith);

    var operation = OperationEnum.update;

    await ClientService.getInstance().notify(put, _alert, operation);
  }
}
