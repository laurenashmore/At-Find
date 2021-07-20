import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atfind/location/Home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:at_utils/at_logger.dart';
import 'dart:ui';
import 'package:atfind/constants.dart';
import 'package:atfind/service.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import '../service.dart';


/// Class created for onboarding:
class OnboardingScreen extends StatefulWidget {
  OnboardingScreen({Key? key}) : super(key: key);
  static final id = "onboardingscreen";
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

/// Bringing in things:
class _OnboardingScreenState extends State<OnboardingScreen> {
  String? atSign;
  ClientService clientService = ClientService.getInstance();
  var atClientPreference;
  var _logger = AtSignLogger('App');

  @override
  void initState() {
    super.initState();
  }

  /// Layout:
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Builder(
          builder: (context) => Container(
            /// Background image:
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/back.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  /// Logo:
                  Container(
                    margin: const EdgeInsets.all(40.0),
                    height: 100.0,
                    width: 200.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/FIsmall.jpg'),
                        //fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  /// Onboarding button:
                  TextButton(
                    onPressed: () async {
                      atClientPreference =
                          await clientService.getAtClientPreference();
                      Onboarding(
                        context: context,
                        appAPIKey: '477b-876u-bcez-c42z-6a3d',
                        atClientPreference: atClientPreference,
                        domain: MixedConstants.ROOT_DOMAIN,
                        appColor: Colors.red[300],
                        onboard: clientService.postOnboard,
                        onError: (error) {
                          _logger.severe('Onboarding throws $error error');
                        },
                        nextScreen: HomeScreen(),
                      );
                    },
                    child: Text(AppStrings.scan_qr),
                    style: OutlinedButton.styleFrom(
                        primary: Colors.black,
                        side: BorderSide(color: Colors.black, width: 2),
                        padding: EdgeInsets.all(10),
                        minimumSize: Size(200, 35)),
                  ),
                  /// Reset keychain button:
                  TextButton(
                    onPressed: () async {
                      KeyChainManager _keyChainManager = KeyChainManager.getInstance();
                      var _atSignsList =
                          await _keyChainManager.getAtSignListFromKeychain();
                      _atSignsList?.forEach((element) {
                        _keyChainManager.deleteAtSignFromKeychain(element);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                        'Keychain cleaned',
                        textAlign: TextAlign.center,
                      )));
                    },
                    child: Text(AppStrings.reset_keychain),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[850],
                        primary: Colors.white,
                        side: BorderSide(color: Colors.grey[850]!, width: 2),
                        padding: EdgeInsets.all(10),
                        minimumSize: Size(200, 35)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
