import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AccountChangeEmailPage.dart';
import 'AccountChangePasswordPage.dart';

class AccountPrivacyPage extends StatefulWidget {

  final int currentIndex;

  final Function onChangeIndex;
  final Function updateParent;

  const AccountPrivacyPage({Key key, this.currentIndex, this.onChangeIndex, this.updateParent}) : super(key: key);

  @override
  _AccountPrivacyPageState createState() => _AccountPrivacyPageState();
}

class _AccountPrivacyPageState extends State<AccountPrivacyPage> {

  User user = FirebaseAuth.instance.currentUser;
  Timer timer;
  bool hasUpdatedEmail = false;


  @override
  void initState() {
    super.initState();


  }
  @override
  void dispose(){
    super.dispose();
    if(timer != null) {
      timer.cancel();
    }

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
              onChanged: (bool val) {
                if(title == "Read Receipts") {
                  if(isActive) {
                    changePrivacySettings("Chats.Read_Receipts", false);
                  } else {
                    changePrivacySettings("Chats.Read_Receipts", true);
                  }
                } else if(title == "Show Messages Preview") {
                  if(isActive) {
                    changePrivacySettings("Chats.Show_Messages_Preview", false);
                  } else {
                    changePrivacySettings("Chats.Show_Messages_Preview", true);
                  }
                } else if(title == "Keep Chats Archived") {
                  if(isActive) {
                    changePrivacySettings("Chats.Keep_Chats_Archived", false);
                  } else {
                    changePrivacySettings("Chats.Keep_Chats_Archived", true);
                  }
                } //else if(title == "Prevent Spam") {
                  //if(isActive) {
                  //  changePrivacySettings("Chats.Prevent_Spam", false);
                  //} else {
                  //  changePrivacySettings("Chats.Prevent_Spam", true);
                  //}
                //}
                else if(title == "Show last Online") {
                  if(isActive) {
                    changePrivacySettings("Activity.Show_Last_Online", false);
                  } else {
                    changePrivacySettings("Activity.Show_Last_Online", true);
                  }
                } else if(title == "Show Profile Picture") {
                  if(isActive) {
                    changePrivacySettings("Activity.Show_Profile_Picture", false);
                  } else {
                    changePrivacySettings("Activity.Show_Profile_Picture", true);
                  }
                } else if(title == "Auto-Update last Online") {
                  if(isActive) {
                    changePrivacySettings("Activity.Auto-Update_Last_Online", false);
                  } else {
                    changePrivacySettings("Activity.Auto-Update_Last_Online", true);
                  }
                }
                else if(title == "Show Description") {
                  if(isActive) {
                    changePrivacySettings("Activity.Show_Description", false);
                  } else {
                    changePrivacySettings("Activity.Show_Description", true);
                  }
                }

              },
            ))
      ],
    );
  }

  Future<void> changePrivacySettings(String settingsName, bool isActive) async {


    final databaseReference = FirebaseFirestore.instance;
    databaseReference.collection(FirebaseAuth.instance.currentUser.displayName).doc("Settings").update({
      "Privacy." + settingsName: isActive,
    }).asStream();




  }

  int countdown;



  GestureDetector buildOptionRow(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {

        if(title == "Change your email") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) {
                return ChangeEmailPage(updateParent: refresh,);
              }));

        } else if(title == "Change your password") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) {
                return ChangePasswordPage();
              }));
        }

      },
      child: Padding(
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
  Widget _buildButton() {

    if(!user.emailVerified || hasUpdatedEmail) {
      if( timer == null || timer.tick == 0 || timer.tick == 30) {
        return Container(

          padding: EdgeInsets.only(top: 5, bottom: 5, right: 10, left: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.green,),
          child: InkWell(
            onTap: () {
              CoolAlert.show(
                context: context,

                type: CoolAlertType.confirm,
                backgroundColor: Theme
                    .of(context)
                    .backgroundColor,
                onConfirmBtnTap: () {
                  Navigator.pop(context);

                  user.sendEmailVerification();

                    timer = Timer.periodic(Duration(seconds:1,), (timer)  {
                      if(timer.tick >= 30) {
                        timer.cancel();
                      }
                      setState(() {
                        countdown = timer.tick;
                      });
                      if(timer.tick % 5 == 0) {
                        checkEmailVerified();
                        print(timer.tick);
                      }
                    });

                },

                confirmBtnColor: Colors.green,
                confirmBtnText: "Verify",
                title: "Verify Email!",
                text: "You will receive a verification email with a link!",
              );
            },
            child: Center(
                child: Text(
                  "verify email",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                )),
          ),
        );
      } else {
        return Container(

          padding: EdgeInsets.only(top: 5, bottom: 5, right: 10, left: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.green,),
          child:Center(
                child: Text(
                  countdown.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                )),
        );
      }

    } else {
      return   Icon(Icons.check_circle_rounded, color: Colors.green,);

    }

  }


  Future <void> checkEmailVerified() async {
    if(this.mounted) {
      user = FirebaseAuth.instance.currentUser;
      await user.reload();
      if (user.emailVerified) {
        setState(() {
          hasUpdatedEmail = false;

          timer.cancel();
        });
      }
    }
  }


  refresh() async{
    setState(()  {
        hasUpdatedEmail = true;

    });

  }

  Widget buildEmailField(BuildContext context) {
    if (!LocalData.isGoogleLogIn()) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width * .5,
            child: Text(FirebaseAuth.instance.currentUser.email,
              textAlign: TextAlign.left,

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),


          ),
          Spacer(flex: 3,),

          _buildButton(),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width * .5,
            child: Text(FirebaseAuth.instance.currentUser.email,
              textAlign: TextAlign.left,

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),


          ),
          Spacer(flex: 3,),

          Image(
            width: 35,
            image: AssetImage('assets/images/google.png'),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Privacy",style: TextStyle(
            fontWeight: FontWeight.bold),),
          backgroundColor: Theme.of(context).backgroundColor,),

        body: SingleChildScrollView(
          child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.white,
),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
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
                      "Profile",
                      style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold,),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                                children: [
                      buildEmailField(context, ),
                                  SizedBox(height: 5,),

                                  !LocalData.isGoogleLogIn() ? Divider(
                                    height: 1,
                                    endIndent: 20,
                                  ) : Center(),

    !LocalData.isGoogleLogIn() ?
    buildOptionRow(context, "Change your email") : Center(),
                                  !LocalData.isGoogleLogIn() ?
                                  buildOptionRow(context, "Change your password") : Center(),

                                ],
                              ),
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
                      "Chats",
                      style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold,),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser.displayName).doc("Settings").snapshots(),
                        builder: (context, snapshot) {
                          if(snapshot.connectionState == ConnectionState.active) {
                            if(snapshot.hasData){
                              return Column(
                                children: [
                                  buildSwitchRow("Read Receipts", snapshot.data.get("Privacy.Chats.Read_Receipts")),
                                  Divider(
                                    height: 1,
                                    endIndent: 20,
                                  ),
                                  buildSwitchRow("Show Messages Preview", snapshot.data.get("Privacy.Chats.Show_Messages_Preview")),
                                  Divider(
                                    height: 1,
                                    endIndent: 20,
                                  ),
                                  buildSwitchRow("Keep Chats Archived", snapshot.data.get("Privacy.Chats.Keep_Chats_Archived")),
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
                      "Activity",
                      style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold,),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser.displayName).doc("Settings").snapshots(),
                        builder: (context, snapshot) {
                          if(snapshot.connectionState == ConnectionState.active) {
                            if(snapshot.hasData){
                              return Column(
                                children: [
                                  buildSwitchRow("Auto-Update last Online", snapshot.data.get("Privacy.Activity.Auto-Update_Last_Online")),
                                  Divider(
                                    height: 1,
                                    endIndent: 20,
                                  ),
                                  buildSwitchRow("Show last Online", snapshot.data.get("Privacy.Activity.Show_Last_Online")),
                                  Divider(
                                    height: 1,
                                    endIndent: 20,
                                  ),
                                  buildSwitchRow("Show Profile Picture", snapshot.data.get("Privacy.Activity.Show_Profile_Picture")),
                                  Divider(
                                    height: 1,
                                    endIndent: 20,
                                  ),
                                  buildSwitchRow("Show Description", snapshot.data.get("Privacy.Activity.Show_Description")),
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
            ],
          ),
      ),
        ),
    );
  }
}
