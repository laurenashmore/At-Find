import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/common_components/pop_button.dart';
import 'package:at_location_flutter/service/request_location_service.dart';
import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:at_location_flutter/utils/constants/text_styles.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:flutter/material.dart';
import '../service.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';

class RequestLocationSheet extends StatefulWidget {
  final Function? onTap;
  RequestLocationSheet({this.onTap});
  @override
  _RequestLocationSheetState createState() => _RequestLocationSheetState();
}

class _RequestLocationSheetState extends State<RequestLocationSheet> {
  ClientService clientSdkService = ClientService.getInstance();
  String? activeAtSign, receiver, selectedAtSign;
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
 // String selectedAtSign = '';

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

          // Contact drop down:
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 25, bottom: 25, right: 30),
                  child: Text('Contacts:', style: CustomTextStyles().greyLabel14)
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
                                        var c_str = c.toString();
                                        var sub_c_arr = c_str.split(",");
                                        var at_signStr_arr = sub_c_arr[0].split(": ");
                                        at_signStr = at_signStr_arr[1];
                                        print(at_signStr);
                                        if(!at_signStrList.contains(at_signStr)){
                                          at_signStrList.add(at_signStr);
                                        }
                                        //selectedAtSign = at_signStrList[0];
                                      }
                                    }
                                  );//selectedAtSign = at_signStrList[0];
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
                ],
              ),



          Padding(
            padding: EdgeInsets.only(bottom: 25),
            child: CustomInputField(
                width: 330.toWidth,
                height: 50,
                hintText: 'Type @sign ',
                initialValue: selectedAtSign ?? '',
                value: (str) {
                  if (!str.contains('@')) {
                    str = '@' + str;
                  }
                  selectedAtSign = str;
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

  // When you press 'Request':
  void onRequestTap() async {
    setState(() {
      isLoading = true;
    });
    var validAtSign = await checkAtsign(selectedAtSign);

    if (!validAtSign) {
      setState(() {
        isLoading = false;
      });
      CustomToast().show('Atsign not valid', context);
      return;
    }

    var result =
        await RequestLocationService().sendRequestLocationEvent(selectedAtSign);

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