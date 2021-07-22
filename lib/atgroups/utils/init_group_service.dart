// ignore: import_of_legacy_library_into_null_safe
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atfind/atgroups/services/group_service.dart';

void initializeGroupService(AtClientImpl atClientInstance, String currentAtSign,
    {rootDomain = 'root.atsign.wtf', rootPort = 64}) {
  GroupService().init(atClientInstance, currentAtSign, rootDomain, rootPort);
}
