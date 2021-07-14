import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'package:atfind/screens/Onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:atfind/service.dart';
import 'package:at_utils/at_logger.dart';
import '../constants.dart';

class Settings extends StatefulWidget {
  static final String id = 'settings';
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String ? atSign;
  var atClientPreference;
  var _logger = AtSignLogger('App'); // OK

  @override
  void initState() {
    //ClientSdkService.getInstance().onboard();
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
        title: Text(
          'Settings',
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/back.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(
                bottom: 200.0),
            child: TextButton(
              onPressed: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => OnboardingScreen(),
                  ),
                );
                KeyChainManager _keyChainManager =
                KeyChainManager.getInstance();
                var _atSignsList =
                await _keyChainManager.getAtSignListFromKeychain();
                _atSignsList?.forEach((element) {
                  _keyChainManager.deleteAtSignFromKeychain(element);
                }
                );
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Keychain cleaned',
                      textAlign: TextAlign.center,
                    ),
                ),
                );
              },
              child: Text(AppStrings.reset_keychain),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[850],
                  primary: Colors.white,
                  side: BorderSide(color: Colors.grey[850]!, width: 2),
                  padding: EdgeInsets.all(10),
                  minimumSize: Size(200, 35)),
            ),
          ),
        ),
      ),
    );
  }
}