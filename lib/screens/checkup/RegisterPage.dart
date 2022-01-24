
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/checkup/Register.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/Encryption.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'LoginPage.dart';
import 'authentication/AuthenticationPage.dart';




class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterPageState();
  }
}

class RegisterPageState extends State<RegisterPage> {
  String _email, _firstName, _lastName, _password, _confirmpassword;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> register() async {



    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();
    String _id = await Register.createId();
    random(min, max) {
      var rn = new Random();
      return min + rn.nextInt(max - min);
    }
    int ppid = random(1, 4);

    DocumentReference userDocRef = FirebaseFirestore.instance.collection('Users_Collection').doc(_email);
    DocumentSnapshot doc = await userDocRef.get();
    final keyPair = Encryption().generateKeyPair();
    LocalData.putString("privateKey",  Encryption().encodePrivateKeyToPem(keyPair.privateKey));
    LocalData.putString("publicKey",  Encryption().encodePublicKeyToPem(keyPair.publicKey));
    if (!doc.exists) {
      try {
        FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _email, password: _password)
            .then(
                (user) {
              // here you can use either the returned user object or       firebase.auth().currentUser. I will use the returned user object
              print("Registered in User:" + user.user.toString());
              createAccount(
                  _id, _email, _firstName + " " + _lastName,
                  "default_image_" + ppid.toString(), "Hey, I'm using MyChat!",
                  "");
              updateLastOnline(
                  _id,
                  "online");
              user.user.updateDisplayName(_id).then((value) =>
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/", (_) => false));
            });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');

          CoolAlert.show(
            context: context,

            type: CoolAlertType.error,
            backgroundColor: Theme.of(context).backgroundColor,

            confirmBtnColor: Colors.red,
            confirmBtnText: "Cancel",
            title: "Unable to Register!",
            text: "The email address is already in use by another account!",
          );
        } else if (e.code == 'email-already-in-use') {
          CoolAlert.show(
            context: context,

            type: CoolAlertType.error,
            text: "The email address is already in use by another account!",
          );
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }
    } else {
      CoolAlert.show(
        context: context,

        type: CoolAlertType.error,
        backgroundColor: Theme.of(context).backgroundColor,

        confirmBtnColor: Colors.red,
        confirmBtnText: "Cancel",
        title: "Unable to Register!",
        text: "The email address is already in use by another account!",
      );
    }


  }


  Widget _buildFirstName() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).backgroundColor : Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(20))
    ),
    child: TextFormField(
      style: TextStyle(color: Colors.grey),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(hintText: 'First Name',border: InputBorder.none,),
      validator: (String value) {
        if (value.trim().isEmpty) {
          return 'Please enter your First Name';
        }

        return null;
      },
      onChanged: (String value) {
        _firstName = value;
      },
    ),);
  }

  Widget _buildLastName() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).backgroundColor : Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(20))
    ),
    child: TextFormField(
      style: TextStyle(color: Colors.grey),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    decoration: InputDecoration(hintText: 'Last Name',border: InputBorder.none,),
      validator: (String value) {
        if (value.trim().isEmpty) {
          return 'Please enter your Last Name';
        }

        return null;
      },
      onChanged: (String value) {
        _lastName = value;
      },
    ),);
  }

  Widget _buildEmail() {

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).backgroundColor : Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20))
    ),
    child: TextFormField(
      style: TextStyle(color: Colors.grey),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    decoration: InputDecoration(hintText: 'Email',border: InputBorder.none,),
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
      onChanged: (String value) {
        _email = value;
      },
    ),);
  }

  Widget _buildPassword() {
    bool isPasswordStrong(String password, [int minLength = 6]) {
      if (password == null || password.isEmpty) {
        return false;
      }

      bool hasUppercase = password.contains(new RegExp(r'[A-Z]'));
      bool hasDigits = password.contains(new RegExp(r'[0-9]'));
      bool hasLowercase = password.contains(new RegExp(r'[a-z]'));
      bool hasMinLength = password.length > minLength;

      return hasDigits & hasUppercase & hasLowercase &  hasMinLength;
    }
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).backgroundColor : Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(20))
    ),
    child: TextFormField(
      style: TextStyle(color: Colors.grey),
      obscureText: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    decoration: InputDecoration(hintText: 'Password',border: InputBorder.none,),
      keyboardType: TextInputType.visiblePassword,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter your Password';
        }
        if(!isPasswordStrong(value)) {
          return 'Your Password is not secure enough';

        }

        return null;
      },
      onChanged: (String value) {
        _password = value;
      },
    ),);
  }
  Widget _buildConfirmPassword() {

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).backgroundColor : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: TextFormField(
        style: TextStyle(color: Colors.grey),
        obscureText: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(hintText: 'Confirm Password',border: InputBorder.none,),
        keyboardType: TextInputType.visiblePassword,
        validator: (String value) {
          if (value.isEmpty) {
            return null;
          }
          if (_confirmpassword != _password) {
            return "The passwords do not match";
          }

          return null;
        },
        onChanged: (String value) {
          _confirmpassword = value;
        },
      ),);
  }



  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).backgroundColor : Colors.white,

      body: Container(
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
            child: SingleChildScrollView(
              child: Form(

                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: <Widget>[
                    SizedBox(height: size.height * 0.15,),
                    Text(
                      "Welcome, \ncreate Account!",

                      style: TextStyle(fontSize: size.width * 0.1, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: size.height * 0.05),
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
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 15),
                          _buildFirstName(),
                          SizedBox(height: 15),
                          _buildLastName(),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),

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
                            "Email",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 15),
                          _buildEmail(),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),

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
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 15),
                          _buildPassword(),
                          SizedBox(height: 15),
                          _buildConfirmPassword(),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height*0.05,),
                    Column(
                      children: [
                        RaisedButton(
                          onPressed: () async{
                            var connectivityResult = await (Connectivity()
                                .checkConnectivity());
                            if (connectivityResult == ConnectivityResult.mobile ||
                                connectivityResult == ConnectivityResult.wifi) {

                              register();
                            } else {
                              CoolAlert.show(
                                context: context,
                                type: CoolAlertType.error,

                                backgroundColor: Theme.of(context).backgroundColor,

                                confirmBtnColor: Colors.red,
                                confirmBtnText: "Try again",
                                cancelBtnText: "Cancel",
                                title: "Unable to login!",
                                text: "Connection to the internet was unsuccessful!!",

                              );
                            }
                          },
                          elevation: 0,
                          color: Colors.indigoAccent,
                          padding: EdgeInsets.all(18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Center(child: Text("Create Account", style: TextStyle(fontWeight: FontWeight.bold),)),
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          ), child: Text("Sign In"),
                        )
                      ],
                    ),

                  ],
                ),
              ),
            ),

        ),
      ),
    );
  }
}
