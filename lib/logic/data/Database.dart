import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:date_format/date_format.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:encrypt/encrypt.dart' as encryption;
import 'Encryption.dart';
import 'LocalData.dart';

UploadTask task;

Future<void> signOut() async {
  try {
    updateLastOnline(FirebaseAuth.instance.currentUser.toString(), "offline");
    print(FirebaseAuth.instance.currentUser.toString() + " signed out");
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    FirebaseAuth.instance.signOut();
  } on FirebaseAuthException catch (e) {
    print(e.message);
  }
}



class FirebaseApi {
  static UploadTask uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      return null;
    }
  }

  static UploadTask uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(data);
    } on FirebaseException catch (e) {
      return null;
    }
  }
}

Future uploadImage(String id, var file) async {
  if (file == null) return;

  final destination = "profile_picture_" + id;
  task = FirebaseApi.uploadFile(destination, file);

  if (task == null) return;

  final snapshot = await task.whenComplete(() {});
  final urlDownload = await snapshot.ref.getDownloadURL();

  final databaseReference = FirebaseFirestore.instance;

  databaseReference.collection(id).doc("Information").update({
    'imageUrl': urlDownload,
  }).asStream();
}

Future<int> countConversations() async {
  final QuerySnapshot conversations = await FirebaseFirestore.instance
      .collection(FirebaseAuth.instance.currentUser.displayName)
      .doc("Conversations")
      .collection("Conversations_Collection")
      .get();
  List<DocumentSnapshot> conversationsCount = conversations.docs;
  return conversationsCount.length;
}

Future<int> getMessageId(String id, String otherId) async {
  QuerySnapshot _myDoc = await FirebaseFirestore.instance
      .collection(id)
      .doc("Conversations")
      .collection("Conversations_Collection")
      .doc(otherId)
      .collection("Messages")
      .get();
  List<DocumentSnapshot> _myDocCount = _myDoc.docs;
  return _myDocCount.length; // Count of Documents in Collection
}

Future<String> getLastOnline(ContactUser user) async {
  final databaseReference = await FirebaseFirestore.instance.collection(user.id).doc("Information").get();
  return databaseReference.get("lastOnline");
}
Future<String> getDescription(ContactUser user) async {
  final databaseReference = await FirebaseFirestore.instance.collection(user.id).doc("Information").get();
  return databaseReference.get("description");
}
Future<String> getImageUrl(ContactUser user) async {
  final databaseReference = await FirebaseFirestore.instance.collection(user.id).doc("Information").get();
  return databaseReference.get("imageUrl");
}

Future<void> resetSettings(String id) async {
  FirebaseFirestore.instance.collection(id).doc("Settings").set({
    'Notifications': {
      'Tactful_Notifications': false,
      'User_Activity': true,
    },
    'Privacy': {
      'Activity': {
        'Auto-Update_Last_Online': true,
        'Show_Description': true,
        'Show_Last_Online': true,
        'Show_Profile_Picture': true,
      },
      'Chats': {
        'Prevent_Spam': false,
        'Read_Receipts': true,
        'Show_Messages_Preview': true,
        'Keep_Chats_Archived': false,
      },
    },
    "Security": {
      'Password': {
        'Auto_Delete_Account': false,
        'Biometric_Unlock': false,
        'Use_Password': false,
      },
      'Prevention': {
        'Auto_Delete_Account': false,
      },
    },
  }).asStream();
}

Future<void> deleteConversations(String id) async {
  FirebaseFirestore.instance
      .collection(id)
      .doc("Conversations")
      .collection("Conversations_Collection")
      .get()
      .then((snapshot) {
    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  });
}

Future<void> addContact(ContactUser contactUser) async{
  if(LocalData.exitsString("contact_list")) {
    final String contactsString = LocalData.getString("contact_list");

    List<ContactUser> contacts = ContactUser.decode(contactsString) ?? [];

    contacts.add(ContactUser(
      name: contactUser.name,
      id: contactUser.id,
      imageUrl:contactUser.imageUrl,
      description: contactUser.description,
      lastOnline: contactUser.lastOnline
    ));

    final String encodedData = ContactUser.encode(contacts);

    //Speicher Pfad
    LocalData.putString("contact_list", encodedData);
  } else {
    List<ContactUser> contacts = [];

    contacts.add(ContactUser(
        name: contactUser.name,
        id: contactUser.id,
        imageUrl:contactUser.imageUrl,
        description: contactUser.description,
        lastOnline: contactUser.lastOnline
    ));

    final String encodedData = ContactUser.encode(contacts);

    //Speicher Pfad
    LocalData.putString("contact_list", encodedData);
  }
}

String getContactName(ContactUser contactUser) {
  if (LocalData.exitsString("contact_list")) {

    List<ContactUser> users = ContactUser.decode(
        LocalData.getString("contact_list"));

    for (int i = 0; i < users.length; i++) {
      if (users[i].id == contactUser.id) {
        return (users[i].name);
      }
    }
  }
  return contactUser.id;

}

Future<String> getPublicKey(ContactUser user) async {
  final databaseReference = await FirebaseFirestore.instance.collection(user.id).doc("Information").get();
  return databaseReference.get("publicKey");
}

Future<void> sendMessage( Message message) async {


  final databaseReference = FirebaseFirestore.instance;




  String encryptedTextReceiver = Encryption().encrypt(message.messageText, Encryption().parsePublicKeyFromPem(await getPublicKey(ContactUser(id: message.receiver))));




  final DocumentSnapshot conversation = await databaseReference
      .collection(message.sender)
      .doc("Conversations")
      .collection("Conversations_Collection")
      .doc(message.receiver)
      .get();


  final DocumentSnapshot otherUserConversation = await databaseReference
      .collection(message.receiver)
      .doc("Conversations")
      .collection("Conversations_Collection")
      .doc(message.sender)
      .get();
  if(!otherUserConversation.exists) {
    databaseReference
        .collection(message.receiver)
        .doc("Conversations")
        .collection("Conversations_Collection")
        .doc(message.sender).set({"show_notes": true});
  }
  if(!conversation.exists) {
    databaseReference
        .collection(message.sender)
        .doc("Conversations")
        .collection("Conversations_Collection")
        .doc(message.receiver).set({"show_notes": true});
  }


  databaseReference
      .collection(message.sender)
      .doc("Conversations")
      .collection("Conversations_Collection")
      .doc(message.receiver)
      .collection("Sent_Messages")
      .add({
    "id": message.id,
    "status": "sent",
  }).asStream();


  databaseReference
      .collection(message.receiver)
      .doc("Conversations")
      .collection("Conversations_Collection")
      .doc(message.sender)
      .collection("Messages")
      .add({
    'sender': message.sender,
    'receiver': message.receiver,
    "message": encryptedTextReceiver,
    "type": message.type,
    "time": message.time,
    "id": await getMessageId(message.receiver, message.sender),
    "status": "sent",
  }).asStream();
  // adding conversation


}

Future<void> resetUserInformation(String id) async {
  final databaseReference = FirebaseFirestore.instance;
  databaseReference.collection(id).doc("Information").update({
    'imageUrl': "default_image",
    'lastOnline': "",
    'description': "I'm using MyChat!",
  }).asStream();
}

Future<void> updateLastOnline(String id, String status) async {
  String currentTime = formatDate(
      DateTime.now().toLocal(), [dd, '.', mm, '.', yy, " ", HH, ':', nn]);

  if (status == "offline") {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference.collection(id).doc("Information").update({
      'lastOnline': currentTime,
    }).asStream();
  } else if (status == "online") {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference.collection(id).doc("Information").update({
      'lastOnline': "online",
    }).asStream();
  }
}

Future<void> updatePubKey(String id) {
  final databaseReference = FirebaseFirestore.instance;
  databaseReference
      .collection(id)
      .doc("Information")
      .update({'publicKey': LocalData.getString("publicKey")}).asStream();
}

Future<void> createAccount(
    String id,
    String email,
    String name,
    String imageUrl,
    String description,
    String lastOnline) async {
  final databaseReference = FirebaseFirestore.instance;
  databaseReference.collection(id).doc("Information").set({
    'email': email,
    'name': name,
    'imageUrl': imageUrl,
    'lastOnline': lastOnline,
    'description': description,
    "supporter": false,
    'publicKey': LocalData.getString("publicKey"),
  }).asStream();

  final userReference = FirebaseFirestore.instance;
  userReference.collection("Users_Collection").doc(email).set({
    'email': email,
    'id': id,
  }).asStream();

  resetSettings(id);
}

Future<void> changeDescription(String id, String description) async {
  final databaseReference = FirebaseFirestore.instance;
  databaseReference
      .collection(id)
      .doc("Information")
      .update({'description': description}).asStream();
}
