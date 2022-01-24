
import 'package:connect/screens/checkup/LoginPage.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import 'LocalData.dart';


class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;


    switch (settings.name) {
      case "/":
        if(LocalData.exits()) {
          if (LocalData.isLocked()) {
            return MaterialPageRoute(
                builder: (context) => AuthenticationPage(isEditable: false,isAutoDelete: false,));
          }
        }

        return MaterialPageRoute(builder: (context) => HomePage());
      case "/setup":
        if (args is String || args == null) {
          return MaterialPageRoute(builder: (context) => LoginPage());
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
