
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InformationPrivacyPage extends StatefulWidget {
  final int currentIndex;

  final Function onChangeIndex;

  const InformationPrivacyPage({Key key, this.currentIndex, this.onChangeIndex})
      : super(key: key);

  @override
  _InformationPrivacyPageState createState() => _InformationPrivacyPageState();
}

class _InformationPrivacyPageState extends State<InformationPrivacyPage> {
  Widget _buildButton() {
    return RaisedButton(
      onPressed: () async {
        await resetSettings(FirebaseAuth.instance.currentUser.displayName);
        LocalData.clearString("conversation_list");
        LocalData.clearString("contact_list");

        await deleteConversations(
            FirebaseAuth.instance.currentUser.displayName);
        CoolAlert.show(
            context: context,
            type: CoolAlertType.loading,
            text: "Clearing Data...",
            autoCloseDuration: Duration(seconds: 1));
      },
      color: Colors.indigoAccent,
      elevation: 0,
      padding: EdgeInsets.all(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Center(
          child: Text(
        "Clear Data",
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Data Privacy",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                      "Intention",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "The most important thing at Connect. is Security, so we did everything we can to improve your experience and keep all of your data save.",
                      style: TextStyle(
                        height: 1.5,
                        fontSize: 16,
                      ),
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
                      "How Data is Stored",
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "First of all, we do not save any of your unencrypted conversation, not on your device or on our servers. \nIn addition, none of your data will be linked to your private data. \nIn order to maintain your security, we recommend that you do not share your personal data and passwords with other users.",
                      style: TextStyle(height: 1.5, fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              _buildButton()
            ],
          ),
        ),
      ),
    );
  }
}
