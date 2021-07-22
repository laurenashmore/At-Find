import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_client/at_client.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:atfind/constants.dart';

class ClientService {
  ClientService._internal();

  static final ClientService _singleton = ClientService._internal();

  factory ClientService.getInstance() => _singleton;

  Map<String?, AtClientService> _atClientServiceMap = {};
  String? path;

  /// Post onboard variables
  String? _atsign;
  AtClientService? _atClientServiceInstance;
  AtClientImpl? _atClientInstance;

  /// AtClientService Getters
  AtClientService _getAtClientServiceForAtSign({String? atsign}) =>
      _atClientServiceInstance ??=
          _atClientServiceMap[atsign] ?? AtClientService();

  AtClientImpl _getAtClientForAtsign({String? atsign}) => _atClientInstance ??=
      _getAtClientServiceForAtSign(atsign: atsign).atClient!;

  /// Onboarding process
  Future<AtClientPreference> getAtClientPreference({String? cramSecret}) async {
    path ??= (await getApplicationSupportDirectory()).path;
    return AtClientPreference()
      ..isLocalStoreRequired = true
      ..commitLogPath = path
      ..cramSecret = cramSecret
      ..namespace = MixedConstants.NAMESPACE
      ..syncStrategy = SyncStrategy.IMMEDIATE
      ..rootDomain = MixedConstants.ROOT_DOMAIN
      //..rootPort = MixedConstants.ROOT_PORT
      ..hiveStoragePath = path;
  }

  void postOnboard(Map<String?, AtClientService> value, String? atsign) {
    _atClientServiceMap = value;
    _atsign = atsign;
    print('curr_auth: $_atsign');
    _getAtClientForAtsign(atsign: _atsign);
    sync();
  }

  /// GETTERS (should only be called after onboarding)
  String get atsign => _atsign!;

  AtClientService get atClientServiceInstance => _atClientServiceInstance!;

  AtClientImpl get atClientInstance => _atClientInstance!;

  /// VERBS
  Future<void> sync() async {
    await _getAtClientForAtsign().getSyncManager()!.sync();
  }

  // FutureOr<String> get(AtKey atKey) async =>
  //     (await _getAtClientForAtsign().get(atKey)).value;
  FutureOr<String> get(AtKey atKey) async {
    var result = await _getAtClientForAtsign().get(atKey);
    return result.value;
  }

  Future<bool> put(AtKey atKey, String value) async =>
      await _getAtClientForAtsign().put(atKey, value);

  Future<bool?> delete(AtKey atKey) async =>
      await _getAtClientForAtsign().delete(atKey);

  Future<List<AtKey>> getAtKeys({String? regex, String? sharedBy}) async {
    regex ??= AppStrings.regex;
    return await _getAtClientForAtsign()
        .getAtKeys(regex: regex, sharedBy: sharedBy);
  }

  Future<List<AtKey>> getKeysWithRegex(String regex,
      {String? sharedBy, String? sharedWith}) async {
    return await _getAtClientForAtsign().getAtKeys(
        regex: MixedConstants.NAMESPACE,
        sharedBy: sharedBy,
        sharedWith: sharedWith);
  }

  Future<String> getAtSign() async {
    return _atsign!;
  }

  static final KeyChainManager _keyChainManager = KeyChainManager.getInstance();

  Future<List<String?>> getAtsignList() async {
    var atSignsList = await _keyChainManager.getAtSignListFromKeychain();
    return atSignsList!;
  }

  deleteAtSignFromKeyChain() async {
    // List<String> atSignList = await getAtsignList();
    String _atsign = atClientServiceInstance.atClient!.currentAtSign.toString();
  }

  Future<bool> notify(
      AtKey atKey, String value, OperationEnum operation) async {
    return await _getAtClientForAtsign().notify(atKey, value, operation);
  }
}
