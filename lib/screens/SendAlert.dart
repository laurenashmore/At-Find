import 'dart:collection';

import 'package:at_common_flutter/widgets/custom_input_field.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/widgets/error_screen.dart';
import 'package:at_contacts_group_flutter/screens/empty_group/empty_group.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atfind/popup/NotificationListener.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:atfind/service.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import '../service.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';

class SendAlert extends StatefulWidget {
  const SendAlert({key}) : super(key: key);
  static final String id = 'sixth';
  @override
  _SendAlertState createState() => _SendAlertState();
}

enum LocationUpdate { travelling, arrived }

class _SendAlertState extends State<SendAlert> {
  ClientService clientSdkService = ClientService.getInstance();
  String? activeAtSign, receiver, _otherAtSign, alert, chosengroup;
  List<AtContact?> selectedContactList = [];

  // String alert = '';
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
  late AtContactsImpl atContactImpl;
  String at_groupStr = '';
  List<String> at_groupStrList = [];
  List<String> groupmembers = [];
  Map<String, List<String>> groupMap = new Map();

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
    //listAllGroupNames();
    super.initState();
    activeAtSign =
        clientSdkService.atClientServiceInstance.getAtSign().toString();
    isLoading = false;
    AlertNotificationListener();
    try {
      super.initState();
      GroupService().getAllGroupsDetails();
      GroupService().atGroupStream.listen((groupList) {
        if (groupList.isNotEmpty) {
          print('$groupList');
        } else {
          print('no groups');
        }
        if (mounted) setState(() {});
      });
    } catch (e) {
      print('Error in init of Group_list $e');
      if (mounted) {
        setState(() {
          errorOcurred = true;
        });
      }
    }
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
                    child: Text('Contacts:')),
                Padding(
                  padding: EdgeInsets.only(top: 25, bottom: 25),
                  child: StreamBuilder<List<AtContact?>>(
                      stream: _contactService!.contactStream,
                      initialData: _contactService!.contactList,
                      builder: (context, snapshot) {
                        if ((snapshot.connectionState ==
                            ConnectionState.waiting)) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          if ((snapshot.data == null ||
                              snapshot.data!.isEmpty)) {
                            return Center(
                              child: Text('No contacts added'),
                            );
                          } else {
                            var _filteredList = <AtContact?>[];
                            snapshot.data!.forEach((c) {
                              if (c!.atSign!
                                  .toUpperCase()
                                  .contains(searchText.toUpperCase())) {
                                _filteredList.add(c);
                                var c_str = c.toString();
                                var sub_c_arr = c_str.split(",");
                                var at_signStr_arr = sub_c_arr[0].split(": ");
                                at_signStr = at_signStr_arr[1];
                                print(at_signStr);
                                if (!at_signStrList.contains(at_signStr)) {
                                  at_signStrList.add(at_signStr);
                                }
                              }
                            });
                            print("ATSIGN LIST: $at_signStrList");
                            return DropdownButton<String>(
                              value: _otherAtSign,
                              items: at_signStrList
                                  .map((atSign) => DropdownMenuItem(
                                      child: Text(atSign), value: atSign))
                                  .toList(),
                              onChanged: (new_atSign) => {
                                if (new_atSign != null)
                                  {
                                    setState(() {
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
            Row(children: [
              SizedBox(width: 30), // (so sorry lauren)
              Padding(
                  padding: EdgeInsets.only(top: 25, bottom: 25, right: 30),
                  child: Text('Groups:')),
              Padding(
                padding: EdgeInsets.only(top: 25, bottom: 25),
                child: StreamBuilder(
                  stream: GroupService().atGroupStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<AtGroup>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (snapshot.hasError) {
                        return ErrorScreen(onPressed: () {
                          GroupService().getAllGroupsDetails();
                        });
                      } else {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return Center(
                              child: Text('No groups added'),
                            );
                          }

                          print('test:' + snapshot.data.toString());
                          var group = snapshot.data.toString();
                          var sub_group_arr = group.split(",");
                          var at_groupStr_arr = sub_group_arr[1].split(":");
                          at_groupStr = at_groupStr_arr[1];
                          print(at_groupStr);
                          if (!at_groupStrList.contains(at_groupStr)) {
                            at_groupStrList.add(at_groupStr);
                          }

                          var wholegroup = group.split("groupId");
                          for (String str in wholegroup) {
                            var at_sign_members = [];
                            var newStr = str.split("members: {");
                            String teamName = "";

                            for (String new_str in newStr) {
                              print("TEST NEWSTR: " + new_str);
                              var new_new_str = new_str.split("AtContact{atSign: ");
                              for (String new_str_1 in new_new_str) {
                                print("TESTNEWNEW: "+ new_str_1);
                                var new_str_list1 = new_str_1.split(",");
                                if(new_str_list1[0].contains('@')){
                                  at_sign_members.add(new_str_list1[0]);
                                }
                                if(new_str.contains("groupName: ")) {
                                  var new_group_strList = new_str.split(
                                      "groupName: ");
                                  var new_group_strList_inner = new_group_strList[1]
                                      .split(',');
                                  teamName = new_group_strList_inner[0];

                                  print("TEAM NAME: " + teamName);
                                }
                              }
                            }
                            /**
                            groupMap.putIfAbsent(teamName, at_sign_members);
                                **/
                                }
                        }

                        return DropdownButton<String>(
                          value: chosengroup,
                          items: at_groupStrList
                              .map((group) => DropdownMenuItem(
                                  child: Text(group), value: group))
                              .toList(),
                          onChanged: (new_atSign) => {
                            if (new_atSign != null)
                              {
                                setState(() {
                                  chosengroup = new_atSign!;
                                })
                              }
                          },
                        );
                      }
                    }
                  },
                ),
              ),
            ]),

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

  listAllGroupNames() async {
    try {
      var groupNames = await atContactImpl.listGroupNames();
      return groupNames;
      print('$groupNames');
    } catch (e) {
      return e;
    }
  }
}
