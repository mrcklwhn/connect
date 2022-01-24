import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


ThemeData lightTheme() {
  return ThemeData(
//    primarySwatch: primaryColor,
    brightness: Brightness.light,
    backgroundColor: Color(0xFFF5F5F5),
    textTheme: new TextTheme(
      bodyText1: new TextStyle(color: Colors.black),
      headline1: new TextStyle(fontSize: 78),
      button: new TextStyle(color: Colors.black),
    ),
    // tabBarTheme:
    // accentIconTheme:
    // accentTextTheme:
    appBarTheme: AppBarTheme(centerTitle: true, color: Color(0xFFF5F5F5), titleTextStyle: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w600,
        color: Colors.black,
    ),
    iconTheme: IconThemeData(color: Colors.black),
    elevation: 0,
    ),
    // bottomAppBarTheme:
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Colors.black))
    ),
    buttonTheme: new ButtonThemeData(

      buttonColor: Colors.orange,
      textTheme: ButtonTextTheme.primary,
      minWidth: 200,
    ),
    cardTheme: CardTheme(
      elevation: 5,
      color: Colors.indigo,
    ),
    // chipTheme:
    // dialogTheme:
    // floatingActionButtonTheme:

    iconTheme: IconThemeData(color: Colors.black),
    // inputDecorationTheme:
    // pageTransitionsTheme:
    // primaryIconTheme:
    // primaryTextTheme:
    // sliderTheme:
    primaryColor: Colors.black,
    accentColor: Colors.blue,
    fontFamily: 'Varela Round',
    buttonColor: Colors.grey,
    // scaffoldBackgroundColor: backgroundColor,
    cardColor: Colors.white,
  );
}

ThemeData darkTheme() {
  return ThemeData(
//    primarySwatch: primaryColor,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0x44444444),
    backgroundColor: Color(0x44444444),
    textTheme: new TextTheme(
      bodyText1: new TextStyle(color: Colors.black),
      headline1: new TextStyle(fontSize: 78),
      button: new TextStyle(color: Colors.black),
    ),
    // tabBarTheme:
    // accentIconTheme:
    // accentTextTheme:

    appBarTheme: AppBarTheme(centerTitle: true,color: Colors.transparent,titleTextStyle: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w600,
        color: Colors.white
    ),
      elevation: 0,
    ),
    // bottomAppBarTheme:
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Colors.white))
    ),
    buttonTheme: new ButtonThemeData(

      buttonColor: Colors.orange,
      textTheme: ButtonTextTheme.primary,
      minWidth: 200,
    ),
    cardTheme: CardTheme(
      elevation: 5,
      color: Colors.indigo,
    ),
    // chipTheme:
    // dialogTheme:
    // floatingActionButtonTheme:

    iconTheme: IconThemeData(color: Colors.white),
    // inputDecorationTheme:
    // pageTransitionsTheme:
    // primaryIconTheme:
    // primaryTextTheme:
    // sliderTheme:
    primaryColor: Color(0x44444444),
    accentColor: Colors.blue,
    fontFamily: 'Varela Round',
    buttonColor: Colors.grey,
    // scaffoldBackgroundColor: backgroundColor,
    cardColor: Colors.white,
  );
}