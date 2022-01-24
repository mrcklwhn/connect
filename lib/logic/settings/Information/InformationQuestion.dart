import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/Messaging.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InformationQuestion {

  static Future<bool> isSuporter(String id) async {
    final databaseReference = await FirebaseFirestore.instance
        .collection(id)
        .doc("Information")
        .get();
    return databaseReference.get("supporter") ?? "";
  }

  static Future<int> getQuestionId(String sender) async {
    QuerySnapshot _myDoc =
    await FirebaseFirestore.instance.collection("Users_Questions").get();
    List<DocumentSnapshot> _myDocCount = _myDoc.docs;
    return _myDocCount.length; // Count of Documents in Collection
  }

  static getLastOnline(String lastOnline) {
    String currentDate =
    formatDate(DateTime.now().toLocal(), [dd, '.', mm, '.', yy]);
    var date = lastOnline.split(" ");

    if (lastOnline.startsWith(currentDate)) {
      return date[1].trim();
    } else {
      return date[0].trim();
    }
  }

  static Future<void> addQuestion(String sender, String message, var context) async {
    DateTime time = DateTime.now().toLocal();
    String currentTime = formatDate(time, [
      dd,
      '.',
      mm,
      '.',
      yy,
      " ",
      HH,
      ':',
      nn,
    ]);
    final databaseReference = FirebaseFirestore.instance;
    databaseReference.collection("Users_Questions").add({
      'id': await getQuestionId(sender),
      "sender": sender,
      "supporter": "",
      'question': message,
      'answer': "",
      "time": currentTime
    }).asStream();
    final response = await Messaging.sendToTopic(
      title: "Support - A new question was asked!",
      body: message,
      type: "support",
      topic: "support",
      // fcmToken: fcmToken,
    );

    if (response.statusCode != 200) {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        backgroundColor: Theme.of(context).backgroundColor,
        confirmBtnColor: Colors.red,
        confirmBtnText: "Try again",
        cancelBtnText: "Cancel",
        title: "Unable to send message!",
        text: "Connection to the internet was unsuccessful!!",
      );
    }
  }

  static Future<int> getUserQuestions(String sender) async {
    QuerySnapshot _myDoc =
    await FirebaseFirestore.instance.collection("Users_Questions").get();

    List<DocumentSnapshot> _myDocCount = _myDoc.docs;

    int counter = 0;
    for (int i = 0; i < _myDocCount.length; i++) {
      if (_myDoc.docs[i].get("sender") == sender) {
        counter++;
      }
    }
    return counter; // Count of Documents in Collection
  }
  static Future<void> updateQuestion(String docId, String answer) {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference.collection("Users_Questions").doc(docId).update({
      'answer': answer,
      "supporter": FirebaseAuth.instance.currentUser.displayName
    }).asStream();
  }

  static Future<void> makeSupporter() {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Information")
        .update({'supporter': true}).asStream();
  }
}