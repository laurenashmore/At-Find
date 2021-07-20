import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
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
  AtContact? selectedContact;
  late bool isLoading;
  String? selectedOption, textField;

  @override
  void initState() {
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
          Text('Who do you want to keep an eye on?', style: CustomTextStyles().greyLabel14),
          SizedBox(height: 10),
          ListTile( /// Drop down

            title: Center(
              child: DropdownButton<String>(
                hint: Text('Pick an @sign'),
                icon: Icon(Icons.keyboard_arrow_down),
                items: <String>['A', 'B', 'C', 'D']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
              )
            ),
          ),
          CustomInputField(
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
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => GroupList()));
            }
          ),
          Expanded(child: SizedBox()),
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
          )
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
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      CustomToast().show('some thing went wrong , try again.', context);
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