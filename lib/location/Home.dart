import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_group_flutter/utils/init_group_service.dart';
import 'package:atfind/atlocation/common_components/bottom_sheet.dart';
import 'package:atfind/atlocation/common_components/display_tile.dart';
import 'package:atfind/atlocation/location_modal/key_location_model.dart';
import 'package:atfind/atlocation/map_content/flutter_map/flutter_map.dart';
import 'package:atfind/atlocation/service/at_location_notification_listener.dart';
import 'package:atfind/atlocation/service/home_screen_service.dart';
import 'package:atfind/atlocation/service/key_stream_service.dart';
import 'package:atfind/atlocation/service/my_location.dart';
import 'package:atfind/atlocation/show_location.dart';
import 'package:atfind/atlocation/utils/constants/colors.dart';
import 'package:atfind/atlocation/utils/constants/init_location_service.dart';
import 'package:atfind/atlocation/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:atfind/screens/Profile.dart';
import 'package:atfind/screens/SendAlert.dart';
import 'package:atfind/screens/Settings.dart';
import 'package:atfind/service.dart';
import 'package:atfind/constants.dart';
import 'package:atfind/screens/Contacts.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'Request.dart';
import 'Share.dart';

/// Using at_location home screen, with our own changes
///
/// Class created (with the same name from package):
class HomeScreen extends StatefulWidget {
  static final String id = 'HomeScreen';
  String? activeAtSign;
  final bool showList;
  HomeScreen({this.showList = true});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

/// Bringing in things used in the code:
class _HomeScreenState extends State<HomeScreen> {
  ClientService clientSdkService = ClientService.getInstance();
  String? activeAtSign, receiver;
  String? currentAtSign;
  Stream<List<KeyLocationModel>>? newStream;
  PanelController pc = PanelController();
  LatLng? myLatLng;
  GlobalKey<ScaffoldState>? scaffoldKey;

  /// Initializing things:
  @override
  void initState() {
    activeAtSign =
        clientSdkService.atClientServiceInstance.atClient!.currentAtSign;

    /// Initialize location:
    initializeLocationService(
        clientSdkService.atClientServiceInstance.atClient!,
        activeAtSign!,
        NavService.navKey,
        apiKey: 'Csv2sD-TZ0giW1nLuQXCgj2WUOlZEkLjxHpiOgvVQlY',
        mapKey: '5WE2iX9u1OEKDBqi057s#');

    /// Initialize contacts:
    initializeContactsService(
        clientSdkService.atClientServiceInstance!.atClient!, activeAtSign!,
        rootDomain: MixedConstants.ROOT_DOMAIN);

    /// Initialize group contacts:
    initializeGroupService(
        clientSdkService.atClientServiceInstance!.atClient!, activeAtSign!,
        rootDomain: MixedConstants.ROOT_DOMAIN);
    super.initState();
    _getMyLocation();
    KeyStreamService().init(AtLocationNotificationListener().atClientInstance);
  }

  /// Location stuff:
  void _getMyLocation() async {
    var newMyLatLng = await getMyLocation();
    if (newMyLatLng != null) {
      if (mounted) {
        setState(() {
          myLatLng = newMyLatLng;
        });
      }
    }
    var permission = await Geolocator.checkPermission();
    if (((permission == LocationPermission.always) ||
        (permission == LocationPermission.whileInUse))) {
      Geolocator.getPositionStream(distanceFilter: 2)
          .listen((locationStream) async {
        setState(() {
          myLatLng = LatLng(locationStream.latitude, locationStream.longitude);
        });
      });
    }
  }

  MapController mapController = MapController();

  /// Layout:
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            (myLatLng != null)
                ? showLocation(UniqueKey(), mapController, location: myLatLng)
                : showLocation(
                    UniqueKey(),
                    mapController,
                  ),

            /// Top container:
            Container(
              height: 50.toHeight,
              width: 356.toWidth,
              margin: EdgeInsets.symmetric(
                  horizontal: 10.toWidth, vertical: 10.toHeight),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: AllColors().DARK_GREY,
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: Offset(0.0, 0.0),
                  )
                ],
              ),

              /// Request and share buttons: (in this project)
              child: Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          child: Text(
                            'Request',
                            style: TextStyle(
                              color: Colors.grey[900],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () {
                            bottomSheet(context, RequestLocationSheet(),
                                SizeConfig().screenHeight * 0.6);
                          }),
                      Icon(
                        Icons.share_location,
                        size: 35,
                        color: Colors.grey[900],
                      ),
                      TextButton(
                          child: Text(
                            'Share',
                            style: TextStyle(
                              color: Colors.grey[900],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () {
                            bottomSheet(context, ShareLocationSheet(),
                                SizeConfig().screenHeight * 0.6);
                          }),
                    ]),
              ),
            ),

            /// Ugly button that puts your location off:
            /// Emergency pop-up button:
            Positioned(
              top: 70,
              right: 2,
              child: IconButton(
                icon: Icon(Icons.report_problem),
                iconSize: 50,
                color: Colors.red[300],
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        elevation: 100,
                        title: Text(
                          'Are you having an emergency?',
                          style: TextStyle(
                            color: Colors.red[300],
                            //fontWeight: FontWeight.bold,
                            //fontSize: 30),
                          ),
                        ),
                        content: Text(
                          'Press below to sound alarm',
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            //fontSize: 20,
                            color: Colors.grey[800],
                          ),
                        ),
                        actions: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.campaign),
                                  iconSize: 70,
                                  color: Colors.red[300],
                                  onPressed: () {
                                    FlutterRingtonePlayer.play(
                                    android: AndroidSounds.alarm,
                                    ios: IosSounds.alarm,
                                    looping: true, // Android only - API >= 28
                                    volume: 1.0, // Android only - API >= 28
                                    asAlarm: true, // Android only - all APIs
                                  );
                                  },
                              ),
                              TextButton(
                                  child: Text('Stop Alarm',
                                    style: TextStyle(
                                      //fontWeight: FontWeight.bold,
                                      //fontSize: 20,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  onPressed: () {FlutterRingtonePlayer.stop();}
                                  ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            /// Panel size:
            widget.showList
                ? Positioned(bottom: 20.toHeight, child: header())
                : SizedBox(),
            widget.showList
                ? StreamBuilder(
                    stream: KeyStreamService().atNotificationsStream,
                    builder: (context,
                        AsyncSnapshot<List<KeyLocationModel>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasError) {
                          return SlidingUpPanel(

                              /// Little slide up arrow:
                              collapsed: Icon(
                                Icons.keyboard_arrow_up_outlined,
                                color: Colors.red[300],
                                size: 22,
                              ),
                              controller: pc,
                              minHeight: 20.toHeight,
                              maxHeight: 350.toHeight,
                              panelBuilder: (scrollController) =>
                                  collapsedContent(false, scrollController,
                                      emptyWidget('Something went wrong!')));
                        } else {
                          return SlidingUpPanel(
                            /// Little slide up arrow:
                            collapsed: Icon(
                              Icons.keyboard_arrow_up_outlined,
                              color: Colors.red[300],
                              size: 22,
                            ),
                            controller: pc,
                            minHeight: 20.toHeight,
                            maxHeight: 350.toHeight,
                            panelBuilder: (scrollController) {
                              if (snapshot.data!.isNotEmpty) {
                                return collapsedContent(
                                    false,
                                    scrollController,
                                    getListView(
                                        snapshot.data!, scrollController));
                              } else {
                                return collapsedContent(false, scrollController,
                                    emptyWidget('No Data Found!'));
                              }
                            },
                          );
                        }
                      } else {
                        return SlidingUpPanel(
                          /// Little slide up arrow:
                          collapsed: Icon(
                            Icons.keyboard_arrow_up_outlined,
                            color: Colors.red[300],
                            size: 22,
                          ),
                          controller: pc,
                          minHeight: 20.toHeight,
                          maxHeight: 350.toHeight,
                          panelBuilder: (scrollController) {
                            return collapsedContent(false, scrollController,
                                emptyWidget('No Data Found!!'));
                          },
                        );
                      }
                    })
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  /// Edit bar space size:
  Widget collapsedContent(
      bool isExpanded, ScrollController slidingScrollController, dynamic T) {
    return Container(
        height: !isExpanded ? 20.toHeight : 350.toHeight,
        padding: EdgeInsets.fromLTRB(15.toWidth, 20.toHeight, 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: AllColors().DARK_GREY,
              blurRadius: 10.0,
              spreadRadius: 1.0,
              offset: Offset(0.0, 0.0),
            )
          ],
        ),
        child: T);
  }

  /// Notification info:
  Widget getListView(List<KeyLocationModel> allNotifications,
      ScrollController slidingScrollController) {
    return ListView(
      children: allNotifications.map((notification) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                HomeScreenService().onLocationModelTap(
                    notification.locationNotificationModel!,
                    notification.haveResponded!);
              },
              child: DisplayTile(
                atsignCreator:
                    notification.locationNotificationModel!.atsignCreator ==
                            AtLocationNotificationListener().currentAtSign
                        ? notification.locationNotificationModel!.receiver
                        : notification.locationNotificationModel!.atsignCreator,
                title: getTitle(notification.locationNotificationModel!),
                subTitle: getSubTitle(notification.locationNotificationModel!),
                semiTitle: getSemiTitle(notification.locationNotificationModel!,
                    notification.haveResponded!),
                showRetry: calculateShowRetry(notification),
                onRetryTapped: () {
                  HomeScreenService().onLocationModelTap(
                      notification.locationNotificationModel!, false);
                },
              ),
            ),
            Divider()
          ],
        );
      }).toList(),
    );
  }

  /// Our buttons!
  Widget header() {
    return Container(
      height: 77.toHeight,
      width: 356.toWidth,
      margin:
          EdgeInsets.symmetric(horizontal: 10.toWidth, vertical: 10.toHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: AllColors().DARK_GREY,
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: Offset(0.0, 0.0),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              icon: Icon(Icons.account_circle_outlined),
              iconSize: 50,
              color: Colors.grey[900],
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Profile()));
              }),
          IconButton(
              icon: Icon(Icons.people_alt_outlined),
              iconSize: 50,
              color: Colors.grey[900],
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => GroupList()));
                //TODO: this is to be changed to contacts groups page
              }),
          IconButton(
              icon: Icon(Icons.notifications_active_outlined),
              iconSize: 50,
              color: Colors.grey[900],
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => SendAlert()));
              }),
          IconButton(
              icon: Icon(Icons.settings_outlined),
              iconSize: 50,
              color: Colors.grey[900],
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Settings()));
              })
        ],
      ),
    );
  }

  Widget emptyWidget(String title) {
    return Column(
      children: [
        Image.asset(
          'packages/at_location_flutter/assets/images/empty_group.png',
          width: 50.toWidth,
          height: 50.toWidth,
          fit: BoxFit.cover,
        ),
        SizedBox(
          height: 15.toHeight,
        ),
        Text(title, style: CustomTextStyles().grey16),
        SizedBox(
          height: 5.toHeight,
        ),
      ],
    );
  }
}

/// Nav Service:
class NavService {
  static GlobalKey<NavigatorState> navKey = GlobalKey();
}
