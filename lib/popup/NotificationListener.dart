import 'dart:async';
import 'dart:convert';
import 'dart:js';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/screens/notification_dialog/notification_dialog.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:at_location_flutter/service/master_location_service.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:at_location_flutter/service/sync_secondary.dart';
import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:atfind/screens/SendAlert.dart';
import 'package:atfind/popup/SendAlertDialog.dart';
import 'AlertNotification.dart';


class AlertNotificationListener {
  AlertNotificationListener._();
  static final _instance = AlertNotificationListener._();
  factory AlertNotificationListener() => _instance;
  final String alertKey = 'alertnotify';
  AtClientImpl? atClientInstance;
  String? currentAtSign;
  bool _monitorStarted = false;
  late bool showDialogBox;
  late GlobalKey<NavigatorState> navKey;
  // ignore: non_constant_identifier_names
  String? ROOT_DOMAIN;

  void init(
      AtClientImpl atClientInstanceFromApp,
      String currentAtSignFromApp,
      //GlobalKey<NavigatorState> navKeyFromMainApp,
      String rootDomain,
      bool showDialogBox,
      {Function? newGetAtValueFromMainApp}) {
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
   // navKey = navKeyFromMainApp;
    this.showDialogBox = showDialogBox;
    ROOT_DOMAIN = rootDomain;

    alertMonitor();
  }
  Future<bool> alertMonitor() async {
    if (!_monitorStarted) {
      var privateKey = await (getPrivateKey(currentAtSign!));
      await atClientInstance!.startMonitor(privateKey!, fnCallBack);
      print('Monitor started in location package');
      _monitorStarted = true;
    }
    return true;
  }
  ///Fetches privatekey for [atsign] from device keychain.
  Future<String?> getPrivateKey(String atsign) async {
    return await atClientInstance!.getPrivateKey(atsign);
  }

  Future<void> showPopDialog(String? fromAtSign,
      AlertNotificationModel alertData) async {
    print('showMyDialog called');
    if (showDialogBox) {
      return showDialog<void>(
        context: navKey.currentContext!,
        builder: (BuildContext context) {
          return SendAlertDialog(
            userName: fromAtSign,
            alertData: alertData,
          );
        },
      );
    }
  }

  void fnCallBack(var response) async {
    print('fnCallBack called');
    SyncSecondary()
        .completePrioritySync(response, afterSync: _notificationCallback);
  }
  void _notificationCallback(dynamic notification) async {
    print('_notificationCallback called');
    notification = notification.replaceFirst('notification:', '');
    var responseJson = jsonDecode(notification);
    var value = responseJson['value'];
    var notificationKey = responseJson['key'];
    print(
        '_notificationCallback :$notification , notification key: $notificationKey');
    var fromAtSign = responseJson['from'];
    var atKey = notificationKey.split(':')[1];
    var operation = responseJson['operation'];

    if (operation == 'delete') {
      if (atKey.toString().toLowerCase().contains(alertKey)) {
        print('$notificationKey deleted');
        MasterLocationService().deleteReceivedData(fromAtSign);
        return;
      }
    }
    var decryptedMessage = await atClientInstance!.encryptionService!
        .decrypt(value, fromAtSign)
    // ignore: return_of_invalid_type_from_catch_error
        .catchError((e) => print('error in decrypting: $e'));

    if (atKey
        .toString()
        .contains('currUpdate')) {
      var alertData =
      AlertNotificationModel.fromJson(jsonDecode(decryptedMessage));
      await showPopDialog(fromAtSign, alertData);
      // ignore: unawaited_futures
      return;
    }

  }
}