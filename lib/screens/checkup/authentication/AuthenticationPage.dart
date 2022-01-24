import 'dart:core';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/Encryption.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encryption;

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      return <BiometricType>[];
    }
  }

  static Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    print(isAvailable);
    if (!isAvailable) return false;

    try {
      return await _auth.authenticateWithBiometrics(
        iOSAuthStrings: IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Please set up your Face ID.'),
        androidAuthStrings: AndroidAuthMessages(
            signInTitle: "Scan Biometrics to unlock Connect."),
        localizedReason: 'Scan Biometrics to unlock Connect.',
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }
}

String replaceCharAt(String oldString, int index, String newChar) {
  return oldString.substring(0, index) +
      newChar +
      oldString.substring(index + 1);
}

String removeCharacters(String id) {
  String key = id;
  String newKey = replaceCharAt(key, 4, "");
  String newKey1 = replaceCharAt(newKey, 4, "");
  String newKey2 = replaceCharAt(newKey1, 4, "");
  String newKey3 = replaceCharAt(newKey2, 8, "");
  String newKey4 = replaceCharAt(newKey3, 8, "");
  String newKey5 = replaceCharAt(newKey4, 8, "");
  return (newKey5);
}


class AuthenticationPage extends StatefulWidget {
  final bool isAutoDelete;
  final bool isEditable;
  final Function updateParent;
  const AuthenticationPage(
      {Key key, this.isEditable, this.updateParent, this.isAutoDelete})
      : super(key: key);

  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage>
    with SingleTickerProviderStateMixin {
  void authenticate() async {
    final isAuthenticated = await LocalAuthApi.authenticate();

    if (isAuthenticated) {
      LocalData.setLocked(false);
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushNamed(context, "/");
      }
    }
  }

  // Variables
  Size _screenSize;
  int _currentDigit;
  int _firstDigit;
  int _secondDigit;
  int _thirdDigit;
  int _fourthDigit;

  // Returns "Appbar"
  get _getAppbar {
    return new AppBar(
      automaticallyImplyLeading:
          widget.isEditable || widget.isAutoDelete == true ? true : false,
      backgroundColor: Theme.of(context).backgroundColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.isEditable == true || widget.isAutoDelete == true
              ? Icons.lock_open
              : Icons.lock),
          SizedBox(
            width: 10,
          ),
          Text("Connect.", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      elevation: 0.0,
      centerTitle: true,
    );
  }

  // Return "Verification Code" label

  // Return "Email" label
  get _getEmailLabel {
    return new Text(
      widget.isEditable == true || widget.isAutoDelete
          ? "Enter your new pin!"
          : "Enter your pin to open!",
      textAlign: TextAlign.center,
      style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
    );
  }

  // Return "OTP" input field
  get _getInputField {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _otpTextField(_firstDigit),
        _otpTextField(_secondDigit),
        _otpTextField(_thirdDigit),
        _otpTextField(_fourthDigit),
      ],
    );
  }

  // Returns "OTP" input part
  get _getInputPart {
    return new Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Spacer(),
        _getEmailLabel,
        Spacer(),
        _getInputField,
        Spacer(),
        _getOtpKeyboard
      ],
    );
  }

  // Returns "Resend" button

  Widget _biometricUnlock() {
    if (LocalData.getBiometricPasswordState()) {
      if (widget.isEditable != true) {
        return _otpKeyboardActionButton(
            label: new Icon(
              Icons.fingerprint,
            ),
            onPressed: () {
              authenticate();
            });
      } else {
        return SizedBox(
          width: 80,
        );
      }
    } else {
      return SizedBox(
        width: 80,
      );
    }
  }

  // Returns "Otp" keyboard
  get _getOtpKeyboard {
    return new Container(
        height: _screenSize.width,
        child: new Column(
          children: <Widget>[
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "1",
                      onPressed: () {
                        _setCurrentDigit(1);
                      }),
                  _otpKeyboardInputButton(
                      label: "2",
                      onPressed: () {
                        _setCurrentDigit(2);
                      }),
                  _otpKeyboardInputButton(
                      label: "3",
                      onPressed: () {
                        _setCurrentDigit(3);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "4",
                      onPressed: () {
                        _setCurrentDigit(4);
                      }),
                  _otpKeyboardInputButton(
                      label: "5",
                      onPressed: () {
                        _setCurrentDigit(5);
                      }),
                  _otpKeyboardInputButton(
                      label: "6",
                      onPressed: () {
                        _setCurrentDigit(6);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "7",
                      onPressed: () {
                        _setCurrentDigit(7);
                      }),
                  _otpKeyboardInputButton(
                      label: "8",
                      onPressed: () {
                        _setCurrentDigit(8);
                      }),
                  _otpKeyboardInputButton(
                      label: "9",
                      onPressed: () {
                        _setCurrentDigit(9);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _biometricUnlock(),
                  _otpKeyboardInputButton(
                      label: "0",
                      onPressed: () {
                        _setCurrentDigit(0);
                      }),
                  _otpKeyboardActionButton(
                      label: new Icon(
                        Icons.backspace,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_fourthDigit != null) {
                            _fourthDigit = null;
                          } else if (_thirdDigit != null) {
                            _thirdDigit = null;
                          } else if (_secondDigit != null) {
                            _secondDigit = null;
                          } else if (_firstDigit != null) {
                            _firstDigit = null;
                          }
                        });
                      }),
                ],
              ),
            ),
          ],
        ));
  }

  // Overridden methods
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEditable == false && widget.isAutoDelete == false) {
        if (LocalData.getBiometricPasswordState()) {
          if (mounted) {
            authenticate();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    if (!widget.isEditable && !widget.isAutoDelete) {
      return WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
          appBar: _getAppbar,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).backgroundColor
              : Colors.white,
          body: SafeArea(
            child: Container(
              width: _screenSize.width,
//        padding: new EdgeInsets.only(bottom: 16.0),
              child: _getInputPart,
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: _getAppbar,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).backgroundColor
            : Colors.white,
        body: SafeArea(
          child: new Container(
            width: _screenSize.width,
//        padding: new EdgeInsets.only(bottom: 16.0),
            child: _getInputPart,
          ),
        ),
      );
    }
  }

  // Returns "Otp custom text field"
  Widget _otpTextField(int digit) {
    return Container(
      padding: EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 5),
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).backgroundColor,
      ),
      child: Container(
        alignment: Alignment.center,
        width: 50.0,
        height: 65.0,
        child: new Text(
          digit != null ? digit.toString() : " ",
          style: new TextStyle(
            fontSize: 30.0,
          ),
        ),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          width: 2.0,
        ))),
      ),
    );
  }

  // Returns "Otp keyboard input Button"
  Widget _otpKeyboardInputButton({String label, VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: new BorderRadius.circular(20.0),
      child: new Container(
        height: 80.0,
        width: 80.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Theme.of(context).backgroundColor,
        ),
        child: new Center(
          child: new Text(
            label,
            style: new TextStyle(
              fontSize: 30.0,
            ),
          ),
        ),
      ),
    );
  }

  // Returns "Otp keyboard action Button"
  _otpKeyboardActionButton({Widget label, VoidCallback onPressed}) {
    return new InkWell(
      onTap: onPressed,
      borderRadius: new BorderRadius.circular(40.0),
      child: new Container(
        height: 80.0,
        width: 80.0,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: new Center(
          child: label,
        ),
      ),
    );
  }

  // Current digit
  Future<void> _setCurrentDigit(int i) async {
    setState(() {
      _currentDigit = i;
      if (_firstDigit == null) {
        _firstDigit = _currentDigit;
      } else if (_secondDigit == null) {
        _secondDigit = _currentDigit;
      } else if (_thirdDigit == null) {
        _thirdDigit = _currentDigit;
      } else if (_fourthDigit == null) {
        _fourthDigit = _currentDigit;
        var otp = _firstDigit.toString() +
            _secondDigit.toString() +
            _thirdDigit.toString() +
            _fourthDigit.toString();
        if (widget.isAutoDelete && !widget.isEditable) {
          if (otp != LocalData.getPassword()) {
            LocalData.setAutoDeletePassword(otp);
            LocalData.setAutoDeletePasswordState(true);
            LocalData.setLocked(false);
            widget.updateParent();

            Navigator.pop(context);
          } else {
            CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                backgroundColor: Theme.of(context).backgroundColor,
                confirmBtnColor: Colors.indigoAccent,
                confirmBtnText: "Change",
                cancelBtnText: "Cancel",
                title: "Unable to save Password!",
                text: "You already use this password to login!",
                onConfirmBtnTap: () async {
                  Navigator.pop(context);
                });
            clearOtp();
          }
        }
        if (widget.isEditable == true && !widget.isAutoDelete) {
          LocalData.setPassword(otp);
          LocalData.setPasswordState(true);
          LocalData.setLocked(false);
          LocalData.reload();
          widget.updateParent();
          Navigator.pop(context);
        }
        if (!widget.isEditable && !widget.isAutoDelete) {
          if (otp == LocalData.getPassword()) {
            LocalData.setLocked(false);
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamed(context, "/");
            }
          } else if (otp == LocalData.getAutoDeletePassword()) {
            CoolAlert.show(
                context: context,
                type: CoolAlertType.confirm,
                backgroundColor: Theme.of(context).backgroundColor,
                confirmBtnColor: Colors.red,
                confirmBtnText: "Delete",
                cancelBtnText: "Cancel",
                title: "Delete all data!",
                text:
                    "Do you really want to delete all Conversations and Contacts?",
                onConfirmBtnTap: () async {
                  deleteConversations(
                      FirebaseAuth.instance.currentUser.displayName);

                  LocalData.deleteData();

                  Navigator.of(context).pushNamed('/setup');
                });
            clearOtp();
          } else {
            CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                backgroundColor: Theme.of(context).backgroundColor,
                confirmBtnColor: Colors.red,
                confirmBtnText: "Try again",
                title: "Unable to unlock!",
                text: "You entered the wrong pin!",
                onConfirmBtnTap: () {
                  Navigator.pop(context);
                });
            clearOtp();
          }

          // Verify your otp by here. API call
        }
      }
    });
  }

  void clearOtp() {
    _fourthDigit = null;
    _thirdDigit = null;
    _secondDigit = null;
    _firstDigit = null;
    setState(() {});
  }
}
