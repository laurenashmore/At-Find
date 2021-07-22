import 'dart:typed_data';
import 'package:atfind/atcontacts/screens/blocked_screen.dart';
import 'package:atfind/atcontacts/screens/contacts_screen.dart';
import 'package:atfind/atgroups/at_contacts_group_flutter.dart';
import 'package:atfind/atgroups/screens/group_view/group_view.dart';
import 'package:atfind/atgroups/screens/new_group/new_group.dart';
import 'package:atfind/atgroups/services/group_service.dart';
import 'package:atfind/atgroups/utils/colors.dart';
import 'package:atfind/atgroups/utils/text_constants.dart';
import 'package:atfind/atgroups/widgets/custom_toast.dart';
import 'package:atfind/atgroups/widgets/error_screen.dart';
import 'package:atfind/atgroups/widgets/person_horizontal_tile.dart';
import 'package:atfind/atgroups/widgets/confirmation-dialog.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:at_common_flutter/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class GroupList extends StatefulWidget {
  static final String id = 'Contacts';
  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  List<AtContact?> selectedContactList = [];
  bool showAddGroupIcon = false, errorOcurred = false;

  @override
  void initState() {
    try {
      super.initState();
      GroupService().getAllGroupsDetails();
      GroupService().atGroupStream.listen((groupList) {
        if (groupList.isNotEmpty) {
          showAddGroupIcon = true;
        } else {
          showAddGroupIcon = false;
        }
        if (mounted) setState(() {});
      });
    } catch (e) {
      print('Error in init of Group_list $e');
      if (mounted) {
        setState(() {
          errorOcurred = true;
        });
      }
    }
  }

  @override
  SpeedDial buildSpeedDial() {
    return SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 28.0),
        backgroundColor: Colors.red[300],
        visible: true,
        curve: Curves.bounceInOut,
        spacing: 20,
        //direction: SpeedDialDirection.Left,
        children: [
          SpeedDialChild(
            child: Icon(Icons.add, color: Colors.white),
            backgroundColor: Colors.grey[600],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ContactsScreen(
                      context: context,
                      asSelectionScreen: true,
                      selectedList: (selectedList) {
                        selectedContactList = selectedList;
                        if (selectedContactList.isNotEmpty) {
                          GroupService()
                              .setSelectedContacts(selectedContactList);
                        }
                      },
                      saveGroup: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewGroup(),
                          ),
                        );
                      })),
            ),
            label: 'Add Group',
            labelStyle:
                TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
            labelBackgroundColor: Colors.red[200],
          ),
          SpeedDialChild(
            child: Icon(Icons.contacts_outlined, color: Colors.white),
            backgroundColor: Colors.grey[600],
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ContactsScreen())),
            label: 'My Contacts',
            labelStyle:
                TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
            labelBackgroundColor: Colors.red[200],
          ),
          SpeedDialChild(
            child: Icon(Icons.block, color: Colors.white),
            backgroundColor: Colors.grey[600],
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => BlockedScreen())),
            label: 'Blocked Contacts',
            labelStyle:
                TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
            labelBackgroundColor: Colors.red[200],
          ),
        ]);
  }

  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AllColors().WHITE
            : AllColors().Black,
        appBar: CustomAppBar(
          showBackButton: true,
          showLeadingIcon: true,
          showTitle: true,
          titleText: 'Groups',
        ),
        body: errorOcurred
            ? ErrorScreen()
            : StreamBuilder(
                stream: GroupService().atGroupStream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<AtGroup>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.hasError) {
                      return ErrorScreen(onPressed: () {
                        GroupService().getAllGroupsDetails();
                      });
                    } else {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          showAddGroupIcon = false;

                          return EmptyGroup();
                        } else {
                          return GridView.count(
                            childAspectRatio: 150 / 60, // width/height
                            primary: false,
                            padding: EdgeInsets.all(20.0),
                            crossAxisSpacing: 1,
                            mainAxisSpacing: 20,
                            crossAxisCount: 2,
                            children:
                                List.generate(snapshot.data!.length, (index) {
                              return InkWell(
                                onLongPress: () {
                                  showMyDialog(context, snapshot.data![index]);
                                },
                                onTap: () async {
                                  WidgetsBinding.instance!
                                      .addPostFrameCallback((_) async {
                                    GroupService()
                                        .groupViewSink
                                        .add(snapshot.data![index]);
                                  });

                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GroupView(
                                            group: snapshot.data![index])),
                                  );
                                },
                                child: CustomPersonHorizontalTile(
                                  image: (snapshot.data![index].groupPicture !=
                                          null)
                                      ? snapshot.data![index].groupPicture
                                      : null,
                                  title:
                                      snapshot.data![index].displayName ?? ' ',
                                  subTitle:
                                      '${snapshot.data![index].members!.length} members',
                                ),
                              );
                            }),
                          );
                        }
                      } else {
                        return EmptyGroup();
                      }
                    }
                  }
                },
              ),
        floatingActionButton: buildSpeedDial(),
      ),
    );
  }
}

Future<void> showMyDialog(BuildContext context, AtGroup group) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      Uint8List? groupPicture;
      if (group.groupPicture != null) {
        List<int> intList = group.groupPicture.cast<int>();
        groupPicture = Uint8List.fromList(intList);
      }
      return ConfirmationDialog(
        title: '${group.displayName}',
        heading: 'Are you sure you want to delete this group?',
        onYesPressed: () async {
          var result = await GroupService().deleteGroup(group);

          if (result is bool) {
            result ? Navigator.of(context).pop() : null;
          } else {
            CustomToast().show(TextConstants().SERVICE_ERROR, context);
          }
        },
        image: groupPicture,
      );
    },
  );
}
