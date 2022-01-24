import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/Encryption.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtherUserProfile {
  static void changeUserName(ContactUser user, String name) {
    List<ContactUser> users =
    ContactUser.decode(LocalData.getString("contact_list"));
    int index = users.indexOf(users.firstWhere((item) => item.id == user.id));
    users[index].name = name;

    final String encodedData = ContactUser.encode(users);

    //Speicher Pfad
    LocalData.putString("contact_list", encodedData);
  }

  static Future<void> updateNotes(
      ContactUser sender, ContactUser receiver, String notes) async {


    String encryptedTextReceiver =  Encryption().encrypt(
        notes.trim(), Encryption().parsePublicKeyFromPem(await getPublicKey(ContactUser(id: receiver.id))));
    String encryptedTextSender =  Encryption().encrypt(
        notes.trim(),Encryption().parsePublicKeyFromPem(await getPublicKey(ContactUser(id: sender.id))));

    final databaseReference = FirebaseFirestore.instance;

    final DocumentSnapshot conversation = await databaseReference
        .collection(sender.id)
        .doc("Conversations")
        .collection("Conversations_Collection")
        .doc(receiver.id)
        .get();

    if (!conversation.exists) {
      databaseReference
          .collection(sender.id)
          .doc("Conversations")
          .collection("Conversations_Collection")
          .doc(receiver.id)
          .set({
        "notes": encryptedTextSender,
      }).asStream();
    } else {
      databaseReference
          .collection(sender.id)
          .doc("Conversations")
          .collection("Conversations_Collection")
          .doc(receiver.id)
          .update({
        'notes': encryptedTextSender,
      }).asStream();
    }

    final DocumentSnapshot otherUserConversation = await databaseReference
        .collection(receiver.id)
        .doc("Conversations")
        .collection("Conversations_Collection")
        .doc(sender.id)
        .get();

    if (!otherUserConversation.exists) {
      databaseReference
          .collection(receiver.id)
          .doc("Conversations")
          .collection("Conversations_Collection")
          .doc(sender.id)
          .set({
        "notes": encryptedTextReceiver,
      }).asStream();
    } else {
      databaseReference
          .collection(receiver.id)
          .doc("Conversations")
          .collection("Conversations_Collection")
          .doc(sender.id)
          .update({
        'notes': encryptedTextReceiver,
      }).asStream();
    }
  }

  static bool isArchived(ContactUser user) {
    bool isArchived;
    FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Conversations")
        .collection("Conversations_Collection")
        .doc(user.id)
        .get()
        .then((snapshot) {
      if(snapshot.exists) {
        if (snapshot.get("isArchived") == true) {
          isArchived = true;
          return isArchived;
        }
      }
    });
    return false;
  }
}