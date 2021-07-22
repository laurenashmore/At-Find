import 'package:at_common_flutter/at_common_flutter.dart';
//import 'package:at_common_flutter/utils/text_strings.dart';
import 'package:at_contact/at_contact.dart';
import 'package:atfind/atcontacts/services/contact_service.dart';
import 'package:atfind/atcontacts/utils/exposed_service.dart';
import 'package:atfind/atcontacts/utils/init_contacts_service.dart';
import 'package:atfind/atgroups/screens/list/group_list.dart';
import 'package:atfind/atgroups/utils/colors.dart';
import 'package:atfind/atgroups/utils/colors.dart';
import 'package:atfind/atlocation/common_components/custom_toast.dart';
import 'package:atfind/atlocation/common_components/pop_button.dart';
import 'package:atfind/atlocation/service/request_location_service.dart';
import 'package:atfind/atlocation/service/at_location_notification_listener.dart';
import 'package:atfind/atlocation/utils/constants/text_styles.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../service.dart';
import 'package:atfind/atcontacts/utils/text_strings.dart';

class RequestLocationSheet extends StatefulWidget {
  final Function? onTap;
  RequestLocationSheet({this.onTap});
  @override
  _RequestLocationSheetState createState() => _RequestLocationSheetState();
}

class _RequestLocationSheetState extends State<RequestLocationSheet> {
  ClientService clientSdkService = ClientService.getInstance();
  String? activeAtSign, receiver;
  String? currentAtSign;
  ContactService? _contactService;
  AtContact? selectedContact;
  //List<AtContact>? contactlist;
  late bool isLoading;
  String? selectedOption, textField;
  bool errorOcurred = false;
  String searchText = '';
  List<String> allContactsList = [];
  String at_signStr = '';
  List<String> at_signStrList = [];
  //String new_atSign = '';

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
    /*  initializeContactsService(
        clientSdkService.atClientServiceInstance.atClient!, activeAtSign!,
        rootDomain: MixedConstants.ROOT_DOMAIN);*/
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig().screenHeight * 0.4,
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Request Location', style: CustomTextStyles().black18),
              PopButton(label: 'Cancel')
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Text('Who do you want to keep an eye on?',
              style: CustomTextStyles().greyLabel14),
          //SizedBox(height: 10),

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
                            child: Text(TextStrings().noContacts),
                          );
                        } else {
                          var _filteredList = <AtContact?>[];
                          snapshot.data!.forEach(
                            (c) {
                              if (c!.atSign!
                                  .toUpperCase()
                                  .contains(searchText.toUpperCase())) {
                                _filteredList.add(c);
                                //print('This is: $c');
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



                          selectedAtSign = at_signStrList[0];
                          print("ATSIGN LIST: $at_signStrList");
                          return DropdownButton<String>(
                                  value: selectedAtSign,
                                   items: at_signStrList
                                       .map((atSign) =>
                                       DropdownMenuItem(child: Text(atSign), value: atSign))
                                       .toList(),
                                  onChanged: (new_atSign) => {
                                    if(new_atSign != null){
                                      setState((){
                                        selectedAtSign = new_atSign!;
                                      })
                                    }
                                  },
                               );
                        }
                      }
                    }),

              ),


          Padding(
            padding: EdgeInsets.only(bottom: 25),
            child: CustomInputField(
                width: 330.toWidth,
                height: 50,
                hintText: 'Type @sign ',
                initialValue: textField ?? '',
                value: (str) {
                  if (!str.contains('@')) {
                    str = '@' + str;
                  }
                  textField = str;
                },
                icon: Icons.contacts_rounded,
                ),
          ),



          Center(
            child: isLoading
                ? CircularProgressIndicator()
                : CustomButton(
                    buttonText: 'Request',
                    onPressed: onRequestTap,
                    fontColor: AllColors().WHITE,
                    width: 164,
                    height: 48,
                  ),
          ),
        ],
      ),
    );
  }

  /// When you press 'Request':
  void onRequestTap() async {
    setState(() {
      isLoading = true;
    });
    var validAtSign = await checkAtsign(textField);

    if (!validAtSign) {
      setState(() {
        isLoading = false;
      });
      CustomToast().show('Atsign not valid', context);
      return;
    }

    var result =
        await RequestLocationService().sendRequestLocationEvent(textField);

    if (result == null) {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      return;
    }

    if (result == true) {
      CustomToast().show('Request Location sent', context);
      print('IT SENT!!!!!');
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      CustomToast().show('Something went wrong , try again.', context);
      print('SOMETHING IS WRONG!!!!!');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> checkAtsign(String? atSign) async {
    if (atSign == null) {
      return false;
    } else if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    var checkPresence = await AtLookupImpl.findSecondary(
        atSign, AtLocationNotificationListener().ROOT_DOMAIN, 64);
    return checkPresence != null;
  }
}

/// OK FROM R_L_S.dart
