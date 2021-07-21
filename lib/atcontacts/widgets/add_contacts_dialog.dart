/// A popup to ask the [AtSign] which is to be added

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_commons/at_commons.dart';
// ignore: library_prefixes
import 'package:atfind/atcontacts/utils/text_strings.dart' as contactStrings;
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:atfind/atcontacts/services/contact_service.dart';
import 'package:atfind/atcontacts/utils/text_styles.dart'
    // ignore: library_prefixes
    as contactTextStyles;
import 'package:flutter/material.dart';

import '../../service.dart';

/// Pop up when you hit '+'
class AddContactDialog extends StatefulWidget {
  AddContactDialog({
    Key? key,
  }) : super(key: key);

  @override
  _AddContactDialogState createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  String atsignName = ''; /// real @sign
  String realName = ''; /// your nickname
  ClientService clientSdkService = ClientService.getInstance();
  String? activeAtSign, receiver;
  String _key = '';
  String update = '';

  ///

  TextEditingController atSignController = TextEditingController();

  @override
  void dispose() {
    atSignController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ContactService().resetData();
    activeAtSign = clientSdkService.atsign;
  }

  bool isLoading = false;

  /// Layout:
  @override
  Widget build(BuildContext context) {
    var _contactService = ContactService();
    var deviceTextFactor = MediaQuery.of(context).textScaleFactor;
    return Container(
      height: 100.toHeight * deviceTextFactor,
      width: 100.toWidth,
      child: SingleChildScrollView(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.toWidth)),
          titlePadding: EdgeInsets.only(
              top: 20.toHeight, left: 25.toWidth, right: 25.toWidth),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  contactStrings.TextStrings().addContact,
                  textAlign: TextAlign.center,
                  style: contactTextStyles.CustomTextStyles.primaryBold18,
                ),
              )
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: (_contactService.getAtSignError == '')
                    ? 280.toHeight
                    : 310.toHeight * deviceTextFactor),
            child: Column(
              children: [
                SizedBox(
                  height: 5.toHeight,
                ),

                ///
                ///
                TextFormField(
                  /// Where you type in @ sign:
                  autofocus: true,
                  onChanged: (value) {
                    atsignName = value.toLowerCase().replaceAll(' ', '');
                  },
                  // validator: Validators.validateAdduser,
                  decoration: InputDecoration(
                    prefixText: '@',
                    prefixStyle:
                        TextStyle(color: Colors.grey, fontSize: 15.toFont),
                    hintText: '\tEnter @Sign',
                  ),
                  style: TextStyle(fontSize: 15.toFont),
                ),
                SizedBox(
                  height: 10.toHeight,
                ),

                ///
                ///
                TextFormField(
                  /// Where you type in nickname:
                  autofocus: true,
                  onChanged: (value) {
                    realName = value;
                  },

                  /// OK
                  // validator: Validators.validateAdduser,
                  decoration: InputDecoration(
                    prefixText: '...',
                    prefixStyle:
                        TextStyle(color: Colors.grey, fontSize: 15.toFont),
                    hintText: '\tEnter their name',
                  ),
                  style: TextStyle(fontSize: 15.toFont),
                ),

                ///
                (_contactService.getAtSignError == '')
                    ? Container()
                    : Row(
                        children: [
                          Expanded(
                            child: Text(
                              _contactService.getAtSignError,
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                        ],
                      ),
                SizedBox(
                  height: 45.toHeight,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (isLoading)

                        /// Button to add to contacts:
                        ///
                        ///
                        ? CircularProgressIndicator()
                        : CustomButton(
                            height: 50.toHeight * deviceTextFactor,
                            buttonText:
                                contactStrings.TextStrings().addtoContact,
                            onPressed: () async {
                              getrealName(realName, _key); /// real name part
                              /// then @ sign:
                              setState(() {
                                isLoading = true;
                              });
                              await _contactService.addAtSign(context,
                                  atSign: atsignName);

                              setState(() {
                                isLoading = false;
                              });
                              if (_contactService.checkAtSign != null &&
                                  _contactService.checkAtSign!) {
                                Navigator.pop(context);
                              }
                            },
                            buttonColor:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                            fontColor:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                          )
                  ],
                ),
                SizedBox(
                  height: 20.toHeight,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      height: 50.toHeight * deviceTextFactor,
                      buttonText: contactStrings.TextStrings().buttonCancel,
                      onPressed: () {
                        _contactService.getAtSignError = '';
                        Navigator.pop(context);
                      },
                      buttonColor: Colors.white,
                      fontColor: Colors.black,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getrealName(String status, String _key) async {
    ClientService clientSdkService = ClientService.getInstance();
    String? atSign = clientSdkService.atsign;
    setState(() {
      realName = status;
    });
    AtKey currStatus = AtKey()
      ..key = _key
      ..sharedWith = atSign;
    await clientSdkService.put(currStatus, realName);
    print('Real name saved?');
  }
}
