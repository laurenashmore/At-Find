import 'dart:convert';
import 'package:at_contact/at_contact.dart';
// ignore: import_of_legacy_library_into_null_safe


/// Model containing all the information needed for location sharing.
class AlertNotificationModel {
  /// [atsignCreator] who shares their location, [receiver] who receives the location.
  String? atsignCreator, receiver, key, value;



  /// [isExited] if this notification is exited,
  /// [isAcknowledgment] if this is an acknowledgment for any notification,

  bool isExited,
      isAcknowledgment;


  /// start sharing location [from],
  /// stop sharing location [to].
  DateTime? from, to;
  AtContact? atContact;
  AlertNotificationModel({
    this.atsignCreator,
    this.receiver,
    this.from,
    this.to,
    this.isAcknowledgment = false,
    this.isExited = false,
  });

  // ignore: always_declare_return_types
  getAtContact() {
    atContact = AtContact(atSign: receiver);
  }

  AlertNotificationModel.fromJson(Map<String, dynamic> json)
      : atsignCreator = json['atsignCreator'],
        receiver = json['receiver'],
        key = json['key'] ?? '',
        value = json['value'] ?? '',
        isAcknowledgment = json['isAcknowledgment'] == 'true' ? true : false,
        isExited = json['isExited'] == 'true' ? true : false,
        from = ((json['from'] != 'null') && (json['from'] != null))
            ? DateTime.parse(json['from']).toLocal()
            : null,
        to = ((json['to'] != 'null') && (json['to'] != null))
            ? DateTime.parse(json['to']).toLocal()
            : null;

  Map<String, dynamic> toJson() => {
    'atsignCreator': atsignCreator,
    'isExited': isExited
  };
  static String convertLocationNotificationToJson(
      AlertNotificationModel locationNotificationModel) {
    var notification = json.encode({
      'atsignCreator': locationNotificationModel.atsignCreator,
      'receiver': locationNotificationModel.receiver,
      'key': locationNotificationModel.key.toString(),
      'value': locationNotificationModel.value.toString(),
      'from': locationNotificationModel.from != null
          ? locationNotificationModel.from!.toUtc().toString()
          : null.toString(),
      'to': locationNotificationModel.to != null
          ? locationNotificationModel.to!.toUtc().toString()
          : null.toString(),
      'isAcknowledgment': locationNotificationModel.isAcknowledgment.toString(),
      'isExited': locationNotificationModel.isExited.toString(),
    });
    return notification;
  }
}
