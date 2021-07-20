import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_group_flutter/screens/list/group_list.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:atfind/atlocation/common_components/custom_toast.dart';
import 'package:atfind/atlocation/common_components/pop_button.dart';
import 'package:atfind/atlocation/service/request_location_service.dart';
import 'package:atfind/atlocation/service/at_location_notification_listener.dart';
import 'package:atfind/atlocation/utils/constants/text_styles.dart';
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
  String? activeAtSign, receiver;
  String? currentAtSign;
  ContactService? _contactService;
  AtContact? selectedContact;
  List<AtContact>? contactlist;
  late bool isLoading;
  String? selectedOption, textField;
  bool errorOcurred = false;
  String searchText = '';

  @override
  void initState() {
    _contactService = ContactService();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      // try {
      //   _contactService.fetchContacts();
      // } catch (e) {
      //   print('error in Contacts_screen init : $e');
      //   if (mounted)
      //     setState(() {
      //       errorOcurred = true;
      //     });
      // }
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
          //SizedBox(height: 10),

                 Expanded(
                   child: Padding(
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
                                   _filteredList = contactlist!;
                                   print('$contactlist');


                                 }
                               },
                             );
                             return DropdownButtonFormField( items: <String>['$contactlist']
                                 .map<DropdownMenuItem<String>>((String value) {
                               return DropdownMenuItem<String>(
                                 value: value,
                                 child: Text(value),
                               );
                             }).toList(),);
                           }
                         }

                       },

                     ),
                   ),
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
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => GroupList()));
                }),
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
      print ('IT SENT!!!!!');
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      CustomToast().show('Something went wrong , try again.', context);
      print ('SOMETHING IS WRONG!!!!!');
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
