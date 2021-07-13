import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:at_utils/at_logger.dart';
import 'dart:ui';
import 'package:atfind/constants.dart';
import 'package:atfind/service.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import '../service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:atfind/screens/Home.dart';

class OnboardingScreen extends StatefulWidget {
  //OnboardingScreen({required Key key}) : super(key: key);
  static final id = "onboardingscreen";
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? atSign;
 ClientSdkServiceClientSdkService =ClientSdkService.getInstance();
  var atClientPreference;
  var _logger = AtSignLogger('App');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Builder(
          builder: (context) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/back.png'),
                fit: BoxFit.cover,
              ),
            ),

            /// Background Image
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
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
                  TextButton(
                    onPressed: () async {
                      atClientPreference =
                          awaitClientSdkService.getAtClientPreference();
                      Onboarding(
                        appAPIKey: '477b-876u-bcez-c42z-6a3d',
                        context: context,
                        atClientPreference: atClientPreference,
                        domain: MixedConstants.ROOT_DOMAIN,
                        appColor: Color.fromARGB(255, 240, 94, 62),
                        onboard:ClientSdkService.postOnboard,
                        onError: (error) {
                          _logger.severe('Onboarding throws $error error');
                        },
                        nextScreen: Home(),
                      );
                    },
                    child: Text(AppStrings.scan_qr),
                    style: OutlinedButton.styleFrom(
                        primary: Colors.black,
                        side: BorderSide(color: Colors.black, width: 2),
                        padding: EdgeInsets.all(10),
                        minimumSize: Size(200, 35)),
                  ),

                  /// ONBOARDING BUTTON

                  TextButton(
                    onPressed: () async {
                      KeyChainManager _keyChainManager =
                          KeyChainManager.getInstance();
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
                  TextButton(
                    onPressed: () => launch('https://atsign.com/get-an-sign/'),
                    child: Text('Get an @sign!'),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.red[300],
                        primary: Colors.white,
                        side: BorderSide(color: Colors.red[300]!, width: 2),
                        padding: EdgeInsets.all(10),
                        minimumSize: Size(100, 35)),
                  ),

                  /// @SIGN BUTTON/// KEYCHAIN BUTTON
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
