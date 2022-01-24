
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ActiveContactsPage.dart';
import 'RecentContactsPage.dart';

class ContactsPage extends StatefulWidget {

  final Function onMenuTap;

  const ContactsPage({Key key,this.onMenuTap}) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {

  int currentIndex = 0;


  void onChangeIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }



  buildBody() {
    return currentIndex == 1 ? ActiveContacts(currentIndex: currentIndex, onChangeIndex: onChangeIndex,) : RecentContactsPage(currentIndex: currentIndex, onChangeIndex: onChangeIndex,);



  }
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Got a new connectivity status!

      if(mounted) {
        if (result == ConnectivityResult.mobile) {

          Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 5),
              backgroundColor: Colors.indigoAccent,
              content:Row(
                children: [
                  Spacer(flex: 1,),
                  Icon(Icons.signal_cellular_alt_rounded, color: Colors.white,),

                  Spacer(flex: 1,),
                  Text("Connection to the internet was successful!",style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),
                  Spacer(flex: 2,),

                ],

              )
          ));
          // I am connected to a mobile network.
        } else if (result == ConnectivityResult.wifi) {
          Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 5),
              backgroundColor: Colors.indigoAccent,
              content:Row(
                children: [
                  Spacer(flex: 1,),

                  Icon(CupertinoIcons.wifi, color: Colors.white,),

                  Spacer(flex: 1,),
                  Text("Connection to the internet was successful!",style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),
                  Spacer(flex: 2,),

                ],

              )
          ));
          // I am connected to a wifi network.
        } else if (result == ConnectivityResult.none) {
          Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 30),
              backgroundColor: Colors.red,
              content:Row(
                children: [
                  Spacer(flex: 1,),

                  Icon(CupertinoIcons.wifi_exclamationmark, color: Colors.white,),

                  Spacer(flex: 1,),
                  Text("Connection to the internet was unsuccessful!",style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),
                  Spacer(flex: 2,),

                ],

              )
          ));
          // I am connected to a wifi network.
        }
      }
    });
  }

  bool isCollabsed = false;


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(child: buildBody(),
        bottom: false,),
    );
  }
}