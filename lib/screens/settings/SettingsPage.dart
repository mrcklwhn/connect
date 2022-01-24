import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/logic/settings/account/AccountPrivacy.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/settings/proflie/ProfilePage.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Information/InformationEncryptionPage.dart';
import 'Information/InformationPrivacyPage.dart';
import 'Information/InformationQuestionPage.dart';
import 'account/AccountPrivacyPage.dart';
import 'account/AccountSecurityPage.dart';

class SettingsPage extends StatefulWidget {
  final Function onMenuTap;

  const SettingsPage({Key key, this.onMenuTap}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<DocumentSnapshot> getData() async {
    await Firebase.initializeApp();
    return await FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Information")
        .get();
  }

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Got a new connectivity status!

      if (mounted) {
        if (result == ConnectivityResult.mobile) {
          Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 5),
              backgroundColor: Colors.indigoAccent,
              content: Row(
                children: [
                  Spacer(
                    flex: 1,
                  ),
                  Icon(
                    Icons.signal_cellular_alt_rounded,
                    color: Colors.white,
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Text(
                    "Connection to the internet was successful!",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(
                    flex: 2,
                  ),
                ],
              )));
          // I am connected to a mobile network.
        } else if (result == ConnectivityResult.wifi) {
          Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 5),
              backgroundColor: Colors.indigoAccent,
              content: Row(
                children: [
                  Spacer(
                    flex: 1,
                  ),
                  Icon(
                    CupertinoIcons.wifi,
                    color: Colors.white,
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Text(
                    "Connection to the internet was successful!",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(
                    flex: 2,
                  ),
                ],
              )));
          // I am connected to a wifi network.
        } else if (result == ConnectivityResult.none) {
          Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 30),
              backgroundColor: Colors.red,
              content: Row(
                children: [
                  Spacer(
                    flex: 1,
                  ),
                  Icon(
                    CupertinoIcons.wifi_exclamationmark,
                    color: Colors.white,
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Text(
                    "Connection to the internet was unsuccessful!",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(
                    flex: 2,
                  ),
                ],
              )));
          // I am connected to a wifi network.
        }
      }
    });
  }

  bool isCollabsed = false;

  void onChangeIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  buildSettingsOverview() {
    return SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ProfilePage();
                  }));
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context).backgroundColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection(
                                  FirebaseAuth.instance.currentUser.displayName)
                              .doc("Information")
                              .get(),
                          builder: (context, future) {
                            if (future.hasData) {
                              if (!future.data
                                  .get("imageUrl")
                                  .startsWith("default_image")) {
                                return Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              future.data.get("imageUrl")),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(future.data.get("name"),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20)),
                                        Divider(
                                          height: 10,
                                          thickness: 2,
                                          endIndent: 20,
                                        ),
                                        Text(
                                            FirebaseAuth.instance.currentUser
                                                .displayName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.grey)),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(future.data.get("description"),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.grey)),
                                      ],
                                    )
                                  ],
                                );
                              } else {
                                return Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      foregroundImage: AssetImage(
                                          "assets/images/user_icon_" +
                                              future.data
                                                  .get("imageUrl")
                                                  .substring(future.data
                                                          .get("imageUrl")
                                                          .length -
                                                      1) +
                                              ".png"),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(future.data.get("name"),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20)),
                                        Divider(
                                          height: 10,
                                          thickness: 2,
                                          endIndent: 20,
                                        ),
                                        Text(
                                            FirebaseAuth.instance.currentUser
                                                .displayName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.grey)),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          future.data.get("description"),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              }
                            }
                            return Center();
                          }),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Theme.of(context).backgroundColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account",
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    buildOptionRow(context, "Privacy"),
                    Divider(
                      height: 1,
                      thickness: 2,
                      endIndent: 20,
                    ),
                    buildOptionRow(context, "Security"),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Theme.of(context).backgroundColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notifications",
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection(
                                FirebaseAuth.instance.currentUser.displayName)
                            .doc("Settings")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            if (snapshot.hasData) {
                              return Column(
                                children: [
                                  buildSwitchRow(
                                      "Tactful Notifications",
                                      snapshot.data.get(
                                          "Notifications.Tactful_Notifications")),
                                  Divider(
                                    height: 1,
                                    thickness: 2,
                                    endIndent: 20,
                                  ),
                                  buildSwitchRow(
                                      "User Activity",
                                      snapshot.data
                                          .get("Notifications.User_Activity")),
                                ],
                              );
                            }
                          }
                          return Center();
                        }),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Theme.of(context).backgroundColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Information",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    buildOptionRow(context, "Ask a Question"),
                    Divider(
                      height: 1,
                      thickness: 2,
                      endIndent: 20,
                    ),
                    buildOptionRow(context, "Data Privacy"),
                    Divider(
                      height: 1,
                      thickness: 2,
                      endIndent: 20,
                    ),
                    buildOptionRow(context, "Encryption"),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(child: _buildButton()),
              SizedBox(
                height: 30,
              ),
            ],
          )),
    );
  }

  Widget _buildButton() {
    return RaisedButton(
      onPressed: () {
        CoolAlert.show(
            context: context,
            type: CoolAlertType.confirm,
            backgroundColor: Theme.of(context).backgroundColor,
            confirmBtnColor: Colors.red,
            confirmBtnText: "Log out",
            cancelBtnText: "Cancel",
            title: "Log out?",
            text: "All of your local data will be deleted!",
            onConfirmBtnTap: () async {
              LocalData.deleteData();
              await deleteConversations(
            FirebaseAuth.instance.currentUser.displayName);
              signOut();
              LocalData.setGoogleLogIn(false);
              Navigator.pushReplacementNamed(context, "/setup");
            });
      },
      color: Colors.red,
      elevation: 0,
      padding: EdgeInsets.all(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Center(
          child: Text(
        "Log Out",
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: buildSettingsOverview(),
      bottom: false,
    );
  }

  int currentIndex = 0;

  Future<void> changeNotificationsSettings(
      String settingsName, bool isActive) async {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Settings")
        .update({
      "Notifications." + settingsName: isActive,
    }).asStream();
  }

  Row buildSwitchRow(String title, bool isActive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]),
        ),
        Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
              value: isActive,
              onChanged: (bool val) async {
                setState(() {
                  if (isCollabsed) {
                    isCollabsed = false;
                    widget.onMenuTap();
                  }
                });
                if (title == "Tactful Notifications") {
                  if (isActive) {
                    changeNotificationsSettings("Tactful_Notifications", false);
                  } else {
                    changeNotificationsSettings("Tactful_Notifications", true);
                  }
                } else if (title == "User Activity") {
                  if (isActive) {
                    changeNotificationsSettings("User_Activity", false);
                  } else {
                    changeNotificationsSettings("User_Activity", true);
                  }
                }
              },
            ))
      ],
    );
  }

  GestureDetector buildOptionRow(BuildContext context, String title) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (isCollabsed) {
          isCollabsed = false;
          widget.onMenuTap();
        }
        if (title == "Privacy") {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AccountPrivacyPage();
          }));
        } else if (title == "Security") {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AccountSecurityPage();
          }));
        } else if (title == "Ask a Question") {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return InformationQuestionsPage();
          }));
        } else if (title == "Data Privacy") {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return InformationPrivacyPage();
          }));
        } else if (title == "Encryption") {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return InformationEncryptionPage();
          }));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

