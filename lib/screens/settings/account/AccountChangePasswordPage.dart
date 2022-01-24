

import 'package:connect/logic/settings/account/AccountChangeEmail.dart';
import 'package:connect/logic/settings/account/AccountChangePassword.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  String _password;

  final passwordController = TextEditingController();

  final oldPasswordController = TextEditingController();



  User user = FirebaseAuth.instance.currentUser;


  Widget _buildOldPassword() {



    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).backgroundColor : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: TextFormField(
        style: TextStyle(color: Colors.grey),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: 'Enter your current Password',
          border: InputBorder.none,
        ),
        controller: oldPasswordController,
        validator: (String value) {
          if (value.isEmpty) {
            return null;
          }


          return null;
        },
      ),
    );
  }
  Widget _buildPassword() {


    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).backgroundColor : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: TextFormField(
        style: TextStyle(color: Colors.grey),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: 'Enter your new Password',
          border: InputBorder.none,
        ),
        controller: passwordController,
        validator: (String value) {
          if (value.isEmpty) {
            return null;
          }

          if(!AccountChangePassword.isPasswordStrong(value)) {
            return 'Your Password is not secure enough';

          }

          return null;
        },
        onChanged: (String value) {
          setState(() {
            _password = value;
          });
        },
      ),
    );
  }

  Widget _buildConfirmPassword() {


    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).backgroundColor : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: TextFormField(
        style: TextStyle(color: Colors.grey),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: 'Confirm your new Password',
          border: InputBorder.none,
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return null;
          }

          if (value != _password) {
            return "The passwords do not match";
          }


          return null;
        },
      ),
    );
  }



  Widget _buildButton() {
    return RaisedButton(
      onPressed: () async {


          AuthCredential credential = EmailAuthProvider.credential(email: FirebaseAuth.instance.currentUser
              .email, password: oldPasswordController.text);

          FirebaseAuth.instance.currentUser.reauthenticateWithCredential(credential).then((credential)   {
            credential.user.reload();
            credential.user
                .updatePassword(passwordController.text)
                .then((value) {
              CoolAlert.show(
                context: context,
                type: CoolAlertType.success,
                backgroundColor: Theme.of(context).backgroundColor,
                confirmBtnColor: Colors.indigoAccent,
                confirmBtnText: "Dismiss",


                onConfirmBtnTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);


                },
                title: "Change completed!",
                text: 'Your password change was successful!',
              );
            });

          }).onError ((e, _) {
            if (e.code == 'invalid-email') {
              CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                backgroundColor: Theme.of(context).backgroundColor,
                confirmBtnColor: Colors.red,
                confirmBtnText: "Dismiss",
                title: "Unable to Register!",
                text:
                "The email address is invalid please check and try again!",
              );
            } else if (e.code == 'requires-recent-login') {
              CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                backgroundColor: Theme.of(context).backgroundColor,
                confirmBtnColor: Colors.red,
                confirmBtnText: "Dismiss",
                title: "Unable to Register!",
                text: "A problem has occurred please try again!",
              );
            } else if (e.code == 'email-already-in-use') {
              CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                backgroundColor: Theme.of(context).backgroundColor,
                confirmBtnColor: Colors.red,
                confirmBtnText: "Dismiss",
                title: "Unable to Register!",
                text:
                "The email address is already in use by another account!",
              );
            } else if (e.code == 'wrong-password') {
              CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                backgroundColor: Theme
                    .of(context)
                    .backgroundColor,
                confirmBtnColor: Colors.red,
                confirmBtnText: "Dismiss",
                title: "Unable to Register!",
                text:
                "The password is incorrect please check and try again!",
              );
            } else if (e.code == 'wrong-password') {
              CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                backgroundColor: Theme
                    .of(context)
                    .backgroundColor,
                confirmBtnColor: Colors.red,
                confirmBtnText: "Dismiss",
                title: "Unable to Register!",
                text:
                "The password is invalid please check and try again!",
              );
            } else {
              CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                backgroundColor: Theme
                    .of(context)
                    .backgroundColor,
                confirmBtnColor: Colors.red,
                confirmBtnText: "Dismiss",
                title: "Unable to Register!",
                text:
                "Something went wrong: "  + e.code + "!",
              );
            }
            throw e.code;

          });



      },
      color: Colors.indigoAccent,
      elevation: 0,
      padding: EdgeInsets.all(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Center(
          child: Text(
            "Change",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Password",style: TextStyle(
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
                      "Change Password",
                      style: TextStyle(
                          fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _buildPassword(),
                    SizedBox(
                      height: 20,
                    ),
                    _buildConfirmPassword(),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Confirm Password",
                      style: TextStyle(
                          fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _buildOldPassword(),
                    SizedBox(
                      height: 30,
                    ),
                    _buildButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
