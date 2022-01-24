import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/Encryption.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Register {

  static String createRnd() {
    random(min, max) {
      var rn = new Random();
      return min + rn.nextInt(max - min);
    }

    int idInt1 = random(1000, 9999);

    int idInt2 = random(1000, 9999);

    int idInt3 = random(1000, 9999);

    String id = (idInt1.toString() +
        " - " +
        idInt2.toString() +
        " - " +
        idInt3.toString());
    return id;
  }

  // ignore: missing_return
  static Future<String> createId() async {

    String id = createRnd();

    final databaseReference = await FirebaseFirestore.instance
        .collection(id)
        .get();

    if(databaseReference == null || databaseReference.size == 0) {
      print("Eine freie Id wurde gefunden!");
      return id;

    }else {
      print("Es wird nach einer freien Id gesucht!!");
      int i = 1;
      while (i == 1) {
        String secId = createRnd();
        final databaseRef = await FirebaseFirestore.instance
            .collection(secId)
            .get();
        if (databaseRef == null || databaseRef.size == 0) {
          print("Eine freie Id wurde gefunden!");
          i=0;
          return secId;
        }

      }
    }


  }







}
