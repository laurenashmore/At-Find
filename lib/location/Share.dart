import 'package:at_common_flutter/at_common_flutter.dart';
//import 'package:at_common_flutter/utils/text_strings.dart';
import 'package:at_contact/at_contact.dart';
import 'package:atfind/atcontacts/services/contact_service.dart';
import 'package:atfind/atlocation/common_components/custom_toast.dart';
import 'package:atfind/atlocation/common_components/pop_button.dart';
import 'package:atfind/atlocation/service/sharing_location_service.dart';
import 'package:atfind/atlocation/service/at_location_notification_listener.dart';
import 'package:atfind/atlocation/utils/constants/colors.dart';
import 'package:atfind/atlocation/utils/constants/text_styles.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:flutter/material.dart';
import 'package:atfind/screens/Contacts.dart';
import 'package:atfind/atcontacts/utils/text_strings.dart';
import '../service.dart';


class ShareLocationSheet extends StatefulWidget {
  final Function? onTap;
  ShareLocationSheet({this.onTap});
  @override
  _ShareLocationSheetState createState() => _ShareLocationSheetState();
}

class _ShareLocationSheetState extends State<ShareLocationSheet> {
  AtContact? selectedContact;
  ClientService clientSdkService = ClientService.getInstance();
  String? activeAtSign, receiver;
  String? currentAtSign;
  ContactService? _contactService;
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
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig().screenHeight * 0.5,
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Share Location', style: CustomTextStyles().black18),
              PopButton(label: 'Cancel')
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Text('Who do you want to keep an eye on you?', style: CustomTextStyles().greyLabel14),
          //SizedBox(height: 10),
          /// Contact drop down:
          Row(
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 5, right: 30),
                  child: Text('Contacts:', style: CustomTextStyles().greyLabel14)
              ),
              Padding(
                padding: EdgeInsets.only(top: 15, bottom: 5),
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
            ],
          ),



          CustomInputField(
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
            icon: Icons.contacts_rounded,),
          SizedBox(height: 25),
          Text(
            'For how long?',
            style: CustomTextStyles().greyLabel14,
          ),
          SizedBox(height: 10),
          Container(
            color: AllColors().INPUT_GREY_BACKGROUND,
            width: 330.toWidth,
            padding: EdgeInsets.only(left: 10, right: 10),
            child: DropdownButton(
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down),
              underline: SizedBox(),
              elevation: 0,
              dropdownColor: AllColors().INPUT_GREY_BACKGROUND,
              value: selectedOption,
              hint: Text('Occurs on'),
              items: ['30 mins', '2 hours', '24 hours', 'Until turned off']
                  .map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (dynamic value) {
                setState(() {
                  selectedAtSign = selectedAtSign;
                  selectedOption = value;
                });
              },
            ),
          ),
          Expanded(child: SizedBox()),
          Center(
            child: isLoading
                ? CircularProgressIndicator()
                : CustomButton(
              buttonText: 'Share',
              onPressed: onShareTap,
              fontColor: AllColors().WHITE,
              width: 164,
              height: 48,
            ),
          ),
        ],
      ),
    );
  }

  /// What happens when you click 'Share':
  void onShareTap() async {
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

    if (selectedOption == null) {
      CustomToast().show('Select time', context);
      return;
    }

    var minutes = (selectedOption == '30 mins'
        ? 30
        : (selectedOption == '2 hours'
        ? (2 * 60)
        : (selectedOption == '24 hours' ? (24 * 60) : null)));

    var result = await SharingLocationService()
        .sendShareLocationEvent(selectedAtSign, false, minutes: minutes);

    if (result == null) {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      return;
    }

    if (result == true) {
      CustomToast().show('Share Location Request sent', context);
      print ('IT SENT!!!!!!!!!!!');
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      CustomToast().show('some thing went wrong , try again.', context);
      print ('SOMETHING IS WRONG!!!!!!!!!!!');
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

/// OK FROM S_L_S.dart