import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'package:atfind/location/Home.dart';
import 'package:atfind/screens/Onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:atfind/service.dart';
import 'package:at_utils/at_logger.dart';
import '../constants.dart';

/// Class created for settings:
class Settings extends StatefulWidget {
  static final String id = 'settings';
  @override
  _SettingsState createState() => _SettingsState();
}

/// Bringin in things:
class _SettingsState extends State<Settings> {
  String? atSign;
  var atClientPreference;
  var _logger = AtSignLogger('App'); // OK
  String nameupdate = '';
  String _name = '';
  String _namekey = 'nameupdate';

  @override
  void initState() {
    ClientService.getInstance()
        .getAtClientPreference()
        .then((value) => atClientPreference = value);
    super.initState();
  }

  /// Screen Layout
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
          child: Container(
            height: 120 ,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => OnboardingScreen(),
                      ),
                    );

                    /// Keychain manager deletes the @sign from the keychain..
                    KeyChainManager _keyChainManager =
                        KeyChainManager.getInstance();
                    var _atSignsList =
                        await _keyChainManager.getAtSignListFromKeychain();
                    _atSignsList?.forEach((element) {
                      _keyChainManager.deleteAtSignFromKeychain(element);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Keychain cleaned',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },

                  /// Button aesthetic:
                  child: Text(AppStrings.reset_keychain),
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.red[300],
                      primary: Colors.white,
                      side: BorderSide(color: Colors.red[300]!, width: 2),
                      padding: EdgeInsets.all(10),
                      minimumSize: Size(200, 35)),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Stack(
                            children: [
                              Column(
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom:20),
                                    child: SizedBox(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(),
                                          //hintText: 'John',
                                          labelText: 'Your name:',
                                        ),
                                        onChanged: (nameValue) {
                                          _name = nameValue;
                                        },
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      getName(_name, _namekey);
                                      print('name saved');
                                      createStatusAlertDialog(context);
                                      await Future.delayed(const Duration(seconds: 3), () {});
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) => HomeScreen()));
                                    },
                                    child: Text('Update',style: TextStyle(color: Colors.red[300], fontSize: 15, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Text('Update Name', style: TextStyle(color: Colors.grey[850])),
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      primary: Colors.white,
                      side: BorderSide(color: Colors.grey[850]!, width: 2),
                      padding: EdgeInsets.all(10),
                      minimumSize: Size(200, 35)),
                ),
              ],
            ),
          ),
        ),
      );
  }

  void getName(String name, String _namekey) async {
    ClientService clientSdkService = ClientService.getInstance();
    String? atSign = clientSdkService.atsign;
    setState(() {
      _name = name;
    });
    AtKey currName = AtKey()
      ..key = _namekey
      ..sharedWith = atSign;
    await clientSdkService.put(currName, _name);
  }
  createStatusAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Name Updated!"),
          );
        });
  }
}
