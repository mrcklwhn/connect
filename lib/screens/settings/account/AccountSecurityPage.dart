import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountSecurityPage extends StatefulWidget {
  final int currentIndex;

  final Function onChangeIndex;

  const AccountSecurityPage({Key key, this.currentIndex, this.onChangeIndex})
      : super(key: key);

  @override
  _AccountSecurityPageState createState() => _AccountSecurityPageState();
}



class _AccountSecurityPageState extends State<AccountSecurityPage> {

   updateParent() {
    setState(() {

    });
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
                if (title == "Use Password") {
                  setState(() {
                    if (isActive) {
                      LocalData.setBiometricPasswordState(false);
                      LocalData.setPasswordState(false);
                      LocalData.setLocked(false);
                    } else {

                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return AuthenticationPage(isEditable: true, isAutoDelete: false,updateParent: updateParent);
                          }));
                    }
                  });
                } else if (title == "Biometric Unlock") {
                  setState(() {
                    if (isActive) {
                      LocalData.setBiometricPasswordState(false);
                    } else {
                      LocalData.setBiometricPasswordState(true);
                    }
                  });
                } else if (title == "Enable Auto-Delete") {
                  if (LocalData.getPasswordState()) {
                    if (isActive) {
                      setState(() {
                        LocalData.setAutoDeletePasswordState(false);
                      });
                    } else {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return AuthenticationPage(isEditable: false,
                                isAutoDelete: true,
                                updateParent: updateParent);
                          }));
                    }
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
      onTap: () {
        if(title == "Change Password") {
          setState(() {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return AuthenticationPage(
                    isEditable: true, updateParent: updateParent,);
                }));
          });
        } else if (title == "Change Auto-Delete Password") {
          setState(() {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return AuthenticationPage(isEditable: false,
                    isAutoDelete: true, updateParent: updateParent,);
                }));
          });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Security",style: TextStyle(
            fontWeight: FontWeight.bold),),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.transparent
              : Colors.white,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
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
                      "Password",
                      style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    buildSwitchRow(
                        "Use Password", LocalData.getPasswordState()),
                    LocalData.getPasswordState()
                        ? buildSwitchRow("Biometric Unlock",
                            LocalData.getBiometricPasswordState())
                        : Center(),
                    LocalData.getPasswordState()
                        ? buildOptionRow(context, "Change Password")
                        : Center(),
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
                      "Auto-Delete",
                      style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    buildSwitchRow(
                        "Enable Auto-Delete", LocalData.getAutoPasswordPasswordState()),
                    LocalData.getAutoPasswordPasswordState()
                        ? buildOptionRow(context, "Change Auto-Delete Password")
                        : Center(),
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
