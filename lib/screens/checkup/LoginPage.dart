import 'dart:math';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/checkup/Login.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/Encryption.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'RegisterPage.dart';
import 'authentication/AuthenticationPage.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  String _email, _password;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _id;


  void signIn() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    try {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('Users_Collection').doc(_email);
      DocumentSnapshot doc = await userDocRef.get();
      if (doc.exists) {
        CoolAlert.show(
          context: context,
          type: CoolAlertType.loading,
          text: "Login to Connect.",
        );
        UserCredential user =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        final keyPair = Encryption().generateKeyPair();
        LocalData.putString("privateKey",  Encryption().encodePrivateKeyToPem(keyPair.privateKey));
        LocalData.putString("publicKey",  Encryption().encodePublicKeyToPem(keyPair.publicKey));
        updatePubKey(FirebaseAuth.instance.currentUser.displayName);

        Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
        print("Logged in User:" + user.toString());
      } else {
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          backgroundColor: Theme.of(context).backgroundColor,
          confirmBtnColor: Colors.red,
          confirmBtnText: "Cancel",
          title: "Unable to login!",
          text: "There is no account with this email!",
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          backgroundColor: Theme.of(context).backgroundColor,
          confirmBtnColor: Colors.red,
          confirmBtnText: "Cancel",
          title: "Unable to login!",
          text: "There is no account with this email!",
        );
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          backgroundColor: Theme.of(context).backgroundColor,
          confirmBtnColor: Colors.red,
          confirmBtnText: "Cancel",
          title: "Unable to login!",
          text: "You entered the wrong password!",
        );
      }
    }
  }



  Widget _buildEmail() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).backgroundColor
              : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: TextFormField(
        style: TextStyle(color: Colors.grey),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: 'Email',
          border: InputBorder.none,
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Please enter your Email';
          }

          if (!RegExp(
                  r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
              .hasMatch(value)) {
            return 'Please enter your correct Email';
          }

          return null;
        },
        onSaved: (String value) {
          _email = value;
        },
      ),
    );
  }

  Widget _buildPassword() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).backgroundColor
              : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: TextFormField(
        style: TextStyle(color: Colors.grey),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Password',
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.visiblePassword,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Please enter your Password';
          }

          return null;
        },
        onSaved: (String value) {
          _password = value;
        },
      ),
    );
  }


  Widget thirdPartSignIn() {
    final appleSignInAvailable =
    Provider.of<AppleSignInAvailable>(context, listen: false);
    if (appleSignInAvailable.isAvailable) {
      return Row(
        children: [
          InkWell(
            onTap: () {
              Login.signInWithApple(context);
            },
            child: Container(
              padding: EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              decoration: BoxDecoration(color: Theme
                  .of(context)
                  .backgroundColor, borderRadius: BorderRadius.circular(20)),
              width: (MediaQuery
                  .of(context)
                  .size
                  .width / 2) - 30,
              height: 70,
              child: Row(
                children: [
                  Image(
                    width: 50,
                    height: 50,
                    image: AssetImage('assets/images/google.png'),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text("Sign in")
                ],
              ),
            ),
          ),
          SizedBox(width: 20,),
          InkWell(
            onTap: () {
              Login.signInWithApple(context);
            },
            child: Container(
              padding: EdgeInsets.only(
                  left: 15, right: 15, top: 15, bottom: 15),
              decoration: BoxDecoration(color: Theme
                  .of(context)
                  .backgroundColor, borderRadius: BorderRadius.circular(20)),
              width: (MediaQuery
                  .of(context)
                  .size
                  .width / 2) - 30,
              height: 70,

              child: Row(
                children: [
                  Image(
                    width: 40,
                    height: 40,
                    image: AssetImage('assets/images/apple.png'),
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Text("Sign in")
                ],
              ),
            ),
          ),
        ],
      );

  } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RaisedButton(
            onPressed: () {Login.signInWithGoogle(context);
            },
            elevation: 0,
            color: Theme.of(context).backgroundColor,

            padding: EdgeInsets.only(
                left: 10, right: 10, top: 5, bottom: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: MediaQuery.of(context).size.width/2,
              child: Row(
                children: [
                  Image(
                    width: 50,
                    image: AssetImage('assets/images/google.png'),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text("Sign in with Google")
                ],
              ),
            ),
          ),
        ],
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final appleSignInAvailable =
    Provider.of<AppleSignInAvailable>(context, listen: false);
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).backgroundColor
            : Colors.white,
        body: Container(
          child: Container(
            width: size.width,
            height: size.height,
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: size.height * 0.15,
                    ),
                    Text(
                      "Hello, \nWelcome Back!",
                      style: TextStyle(
                          fontSize: size.width * 0.1,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: size.height * 0.05),
                    thirdPartSignIn(),
                    Divider(height: 50,thickness: 2,endIndent: appleSignInAvailable.isAvailable ? 0 : 35,indent: appleSignInAvailable.isAvailable ? 0 : 35,),

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
                            "Sign in",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          _buildEmail(),
                          SizedBox(height: 15),
                          _buildPassword(),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                    Column(
                      children: [
                        RaisedButton(
                          onPressed: () async {
                            var connectivityResult =
                                await (Connectivity().checkConnectivity());
                            if (connectivityResult ==
                                    ConnectivityResult.mobile ||
                                connectivityResult == ConnectivityResult.wifi) {
                              signIn();
                              if( FirebaseAuth.instance.currentUser != null) {
                                updateLastOnline(
                                    FirebaseAuth.instance.currentUser
                                        .displayName,
                                    "online");
                              }
                            } else {
                              CoolAlert.show(
                                context: context,
                                type: CoolAlertType.error,
                                backgroundColor:
                                    Theme.of(context).backgroundColor,
                                confirmBtnColor: Colors.red,
                                confirmBtnText: "Try again",
                                cancelBtnText: "Cancel",
                                title: "Unable to login!",
                                text:
                                    "Connection to the internet was unsuccessful!!",
                              );
                            }
                          },
                          color: Colors.indigoAccent,
                          elevation: 0,
                          padding: EdgeInsets.all(18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                              child: Text(
                            "Login",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Create account",
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
