import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountChangeEmail {


  static Future<void> changeMail(String newEmail) async {
    DocumentSnapshot infoReference = await FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser.displayName).doc("Information").get();
    String oldEmail = infoReference.get("email");
    FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Information")
        .update({"email": newEmail}).asStream();


    FirebaseFirestore.instance
        .collection("Users_Collection").where("email", isEqualTo: oldEmail).get().then((snapshot){
      snapshot.docs.first.reference.delete();
    });

    final userReference = FirebaseFirestore.instance;
    userReference.collection("Users_Collection").doc(newEmail).set({
      'email': newEmail,
      'id': FirebaseAuth.instance.currentUser.displayName,
    }).asStream();
  }


}