
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InformationEncryptionPage extends StatefulWidget {
  final int currentIndex;

  final Function onChangeIndex;

  const InformationEncryptionPage({Key key, this.currentIndex, this.onChangeIndex})
      : super(key: key);

  @override
  _InformationEncryptionPageState createState() => _InformationEncryptionPageState();
}

class _InformationEncryptionPageState extends State<InformationEncryptionPage> with TickerProviderStateMixin{
  AnimationController _controllerPublic;
  AnimationController _controllerPrivate;
  bool _expandedPublic = false;
  bool _expandedPrivate = false;
  Widget rotateArrow(String type) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 0.5).animate(type == "public" ? _controllerPublic :_controllerPrivate ),
      child: IconButton(
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: () {
          setState(() {
            if(type == "public") {
              if (_expandedPublic) {
                _controllerPublic..reverse(from: 0.5);
              } else {
                _controllerPublic..forward(from: 0.0);
              }
              _expandedPublic = !_expandedPublic;
            } else if(type == "private") {
              if (_expandedPrivate) {
                _controllerPrivate..reverse(from: 0.5);
              } else {
                _controllerPrivate..forward(from: 0.0);
              }
              _expandedPrivate = !_expandedPrivate;
            }
          });
        },
      ),
    );
  }
  @override
  void initState() {
    super.initState();

    _controllerPublic = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      upperBound: 0.5,
    );
    _controllerPrivate = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      upperBound: 0.5,
    );
  }
  @override
  void dispose() {
    super.dispose();
    _controllerPublic.dispose();
    _controllerPrivate.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Encryption",style: TextStyle(
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
                      "About RSA-Encryption",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "RSA (Rivest-Shamir-Adleman) is an asymmetric cryptographic method that uses a key pair consisting of a private key used to decrypt data and a public key used to encrypt. The private key is kept secret and cannot be calculated from the public key with realistic effort.",
                      style: TextStyle(
                        height: 1.5, fontSize: 16,),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              AnimatedContainer(
                curve: Curves.fastOutSlowIn,
                duration: Duration(milliseconds: 500),
                padding: EdgeInsets.only(left:20, top: 20, right: 20, bottom: _expandedPublic ? 20 : 0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Theme.of(context).backgroundColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Public Key",
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        rotateArrow("public"),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _expandedPublic ? Text(
                      LocalData.getString("publicKey"),
                      style: TextStyle(
                        height: 1.5, fontSize: 16,),
                    ) : Center(),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              AnimatedContainer(
                curve: Curves.fastOutSlowIn,
                duration: Duration(milliseconds: 500),
                padding: EdgeInsets.only(left:20, top: 20, right: 20 ,bottom: _expandedPrivate ? 20 : 0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Theme.of(context).backgroundColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Private Key",
                          style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),

                        rotateArrow("private"),

                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _expandedPrivate ? Text(
                        LocalData.getString("privateKey"),
                      style: TextStyle(
                          height: 1.5, fontSize: 16),
                    ) : Center(),
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
