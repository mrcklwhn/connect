import 'package:connect/logic/settings/account/AccountChangeEmail.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChangeEmailPage extends StatefulWidget {
  final Function updateParent;
  const ChangeEmailPage({Key key, this.updateParent}) : super(key: key);

  @override
  _ChangeEmailPageState createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  String _email;
  String _confirmEmail;
  String _password;
  final passwordController = TextEditingController();

  User user = FirebaseAuth.instance.currentUser;


  Widget _buildPassword() {

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).backgroundColor : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: TextFormField(
        style: TextStyle(color: Colors.grey),
        obscureText: true,
        controller: passwordController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(hintText: 'Enter your current Password',border: InputBorder.none,),
        keyboardType: TextInputType.visiblePassword,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Please enter current Password';
          }

          return null;
        },
        onSaved: (String value) {
          setState(() {
            _password = value;
          });
        },
      ),);
  }

  Widget _buildEmail() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).backgroundColor : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: TextFormField(
        style: TextStyle(color: Colors.grey),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: 'Enter your new Email',
          border: InputBorder.none,
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return null;
          }
          if(value == FirebaseAuth.instance.currentUser
              .email) {
            return "You already use this email address";
          }

          if (!RegExp(
                  r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
              .hasMatch(value)) {
            return 'Please enter your correct Email';
          }

          return null;
        },
        onChanged: (String value) {
          setState(() {
            _email = value;
          });
        },
      ),
    );
  }

  Widget _buildConfirmEmail() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).backgroundColor : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: TextFormField(
        style: TextStyle(color: Colors.grey),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: 'Confirm your new Email',
          border: InputBorder.none,
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return null;
          }

          if (value != _email) {
            return "The email addresses do not match";
          }

          if (!RegExp(
                  r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
              .hasMatch(value)) {
            return 'Please enter your correct Email';
          }

          return null;
        },
        onChanged: (String value) {
          setState(() {
            _confirmEmail = value;
          });
        },
      ),
    );
  }




  Widget _buildButton() {
    return RaisedButton(
      onPressed: () async {
            if (RegExp(
                    r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(_confirmEmail)) {

                AuthCredential credential = EmailAuthProvider.credential(email: FirebaseAuth.instance.currentUser
                    .email, password: passwordController.text);

                FirebaseAuth.instance.currentUser.reauthenticateWithCredential(credential).then((credential)   {
                  credential.user.reload();
                  credential.user
                      .updateEmail(_confirmEmail)
                      .then((value) {
                    AccountChangeEmail.changeMail(_confirmEmail);
                    widget.updateParent();
                    CoolAlert.show(
                      context: context,
                      type: CoolAlertType.success,
                      backgroundColor: Theme.of(context).backgroundColor,
                      confirmBtnColor: Colors.indigoAccent,
                      confirmBtnText: "Dismiss",


                      onConfirmBtnTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);

                        credential.user.sendEmailVerification();

                      },
                      title: "Change completed!",
                      text: 'Your email address was changed to "' +
                          _confirmEmail +
                          '"',
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
                      "The password is invalid please check and try again!",
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


            }
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
      appBar: AppBar(title: Text("Email",style: TextStyle(
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
                        "Change Email",
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _buildEmail(),
                      SizedBox(
                        height: 20,
                      ),
                      _buildConfirmEmail(),
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
                      _buildPassword(),
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
