import 'dart:typed_data';
import 'package:at_contact/at_contact.dart';
import 'package:at_location_flutter/common_components/contacts_initial.dart';
import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:at_location_flutter/service/contact_service.dart';
import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:at_location_flutter/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'AlertNotification.dart';

// ignore: must_be_immutable
class SendAlertDialog extends StatefulWidget {
  String? userName;
  final AlertNotificationModel? alertData;
  final bool showMembersCount;

  SendAlertDialog(
      {this.alertData, this.userName, this.showMembersCount = false});

  @override
  _SendAlertDialogState createState() => _SendAlertDialogState();
}

class _SendAlertDialogState extends State<SendAlertDialog> {
  AtContact? contact;
  Uint8List? image;
  String? locationUserImageToShow;

  @override
  void initState() {
    locationUserImageToShow = (widget.alertData!.atsignCreator ==
            AtLocationNotificationListener().currentAtSign
        ? widget.alertData!.receiver
        : widget.alertData!.atsignCreator);

    widget.userName = locationUserImageToShow;
    getEventCreator();

    super.initState();
  }

  void getEventCreator() async {
    var contact = await getAtSignDetails(locationUserImageToShow);
    // ignore: unnecessary_null_comparison
    if (contact != null) {
      if (contact.tags != null && contact.tags!['image'] != null) {
        List<int>? intList = contact.tags!['image'].cast<int>();
        if (mounted) {
          setState(() {
            image = Uint8List.fromList(intList!);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(10, 20, 5, 10),
        content: Container(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('pop up',
                      style: CustomTextStyles().grey16,
                      textAlign: TextAlign.center),
                  SizedBox(height: 30),
                  Stack(
                    children: [
                      image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              child: Image.memory(
                                image!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.fill,
                              ),
                            )
                          : ContactInitial(
                              initials: locationUserImageToShow,
                              size: 60,
                            ),
                      widget.showMembersCount
                          ? Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AllColors().BLUE,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                    child: Text(
                                  '+10',
                                  style: CustomTextStyles().black10,
                                )),
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                  SizedBox(height: 10.toHeight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
