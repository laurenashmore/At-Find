import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atfind/location/Home.dart';
import 'package:flutter/cupertino.dart';
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
            /// Background image: (),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(height: 60),
                  Container(
                    /// Logo:
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/weelogo.png'),
                      ),
                    ),
                    height: 125,
                    width: 125,
                    alignment: Alignment.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            SizedBox(height: 50),
                            Row(
                                  /// 'your friends'
                                  children: [
                                    //SizedBox(width: 40),
                                    Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage('images/smallfind.png'),
                                        ),
                                      ),
                                      height: 45,
                                      width: 150,
                                      //color: Colors.red,
                                    ),
                                    Text(
                                      'your friends',
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ]),

                            SizedBox(height: 10),
                            Row(

                                  /// 'your family'
                                  children: [
                                    //SizedBox(width: 40),
                                    Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage('images/smallfind.png'),
                                        ),
                                      ),
                                      height: 45,
                                      width: 150,
                                      //color: Colors.red,
                                    ),
                                    Text(
                                      'your family',
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ]),

                          ],
                        ),
                      ),
              ]
                  ),

                  SizedBox(height: 50),

                  /// Login Button:
                  RawMaterialButton(
                    constraints: BoxConstraints(
                      minWidth: 270,
                      minHeight: 33,
                    ),
                    fillColor: Colors.red[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    onPressed: (() async {
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
                    }),
                    child: Text('Login', style: TextStyle(color: Colors.white)),
                  ),
                  //SizedBox(height: 20),

                  /// Reset keychain button:
                  RawMaterialButton(
                    constraints: BoxConstraints(
                      minWidth: 270,
                      minHeight: 33,
                    ),
                    fillColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
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
                    child: Text('Reset Keychain',
                        style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
