class OnboardingScreen extends StatefulWidget {
  OnboardingScreen({Key key}) : super(key: key);
  static final id = "onboarding_screen";
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String atSign;
  ClientService clientService = ClientService.getInstance();
  var atClientPreference;
  var _logger = AtSignLogger('@birdhouse');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppColors.BLUE,
          title: Text('Home'),
        ),
        // appBar: AppBar(
        //   title: const Text('Plugin example app'),
        // ),
        body: Builder(
          builder: (context) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: TextButton(
                    onPressed: () async {
                      atClientPreference =
                      await clientService.getAtClientPreference();
                      Onboarding(
                        appAPIKey: AtConstants.APP_API_KEY,
                        context: context,
                        atClientPreference: atClientPreference,
                        domain: AtConstants.ROOT_DOMAIN,
                        appColor: AppColors.BLUE,
                        onboard: clientService.postOnboard,
                        onError: (error) {
                          _logger.severe('Onboarding throws $error error');
                        },
                        nextScreen: BasketScreen(),
                      );
                    },
                    child: Text("Let's Go!")),
              ),
              SizedBox(
                height: 10,
              ),
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
                  child: Text(
                    "Reset Keychain",
                    style: TextStyle(color: Colors.blueGrey),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}