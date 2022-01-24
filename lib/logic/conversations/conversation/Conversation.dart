 import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/Encryption.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Conversation {


  static void openedConversation(String otherUserId) {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection(otherUserId)
        .doc("Conversations")
        .collection("Conversations_Collection")
        .doc(FirebaseAuth.instance.currentUser.displayName)
        .update({
      'is_opened_by_user': true,
      'show_notes': "",
    }).asStream();
  }

  static void closedConversation(String otherUserId) {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection(otherUserId)
        .doc("Conversations")
        .collection("Conversations_Collection")
        .doc(FirebaseAuth.instance.currentUser.displayName)
        .update({
      'is_opened_by_user': false,
      'show_notes': "",
    }).asStream();
  }

  static void updateMessageStatus(String otherUserId) async {
    FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Conversations")
        .collection("Conversations_Collection")
        .doc(otherUserId)
        .collection("Sent_Messages")
        .orderBy("id", descending: false)
        .snapshots()
        .listen((querySnapshot) {
      querySnapshot.docChanges.forEach((change) async {
        List<Message> messages = LocalData.exitsString(
            "conversation_" + otherUserId)
            ? Message.decode(
            LocalData.getString("conversation_" + otherUserId))
            : [];

        // Do something with change

        print("die länge der conversation ist: " +
            messages.length.toString() +
            "der ander wert ist " +
            (change.doc.get("id") - 1).toString());

        if (change.doc.get("status") != "loading") {
          messages[change.doc.get("id") - 1].status = change.doc.get("status");

          if (change.doc.get("status") == "viewed") {
            FirebaseFirestore.instance
                .collection(FirebaseAuth.instance.currentUser.displayName)
                .doc("Conversations")
                .collection("Conversations_Collection")
                .doc(otherUserId)
                .collection("Sent_Messages")
                .doc(change.doc.id)
                .delete();
          }

          //Speicher Pfad

        }
        final String encodedData = Message.encode(messages);
        LocalData.putString(
            "conversation_" + otherUserId, encodedData);

      });
    });
  }

  static void sendUpdateMessageStatus(String otherUserId) async {
    // updating read receipiest (seen)

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(otherUserId)
        .doc("Conversations")
        .collection("Conversations_Collection")
        .doc(FirebaseAuth.instance.currentUser.displayName)
        .collection("Sent_Messages")
        .orderBy("id", descending: false)
        .get();

    for (int i = 0; i < querySnapshot.size; i++) {
      FirebaseFirestore.instance
          .collection(otherUserId)
          .doc("Conversations")
          .collection("Conversations_Collection")
          .doc(FirebaseAuth.instance.currentUser.displayName)
          .collection("Sent_Messages")
          .doc(querySnapshot.docs[i].id)
          .update({
        'status': "viewed",
      }).asStream();
    }
  }
  static Future<String> getUserName(String id) async {
    final databaseReference = await FirebaseFirestore.instance
        .collection(id)
        .doc("Information")
        .get();
    return databaseReference.get("name");
  }

  static String getLastOnline(String lastOnline) {
    String currentDate =
    formatDate(DateTime.now().toLocal(), [dd, '.', mm, '.', yy]);
    var date = lastOnline.split(" ");

    if (lastOnline.startsWith(currentDate)) {
      return "last seen today at " + date[1].trim();
    } else {
      return "last seen on " + date[0].trim();
    }
  }

  static Future<void> addConversation() async {
    List<ContactUser> conversations = [];

    final QuerySnapshot conversationsQuery = await FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Conversations")
        .collection("Conversations_Collection")
        .get();
    for (int i = 0; i < conversationsQuery.docs.length; i++) {
      final DocumentSnapshot userInfo = await FirebaseFirestore.instance
          .collection(conversationsQuery.docs[i].id)
          .doc("Information")
          .get();
      conversations.add(
        ContactUser(
            name:
            getContactName(ContactUser(id: conversationsQuery.docs[i].id)),
            id: conversationsQuery.docs[i].id,
            imageUrl: userInfo.get("imageUrl"),
            lastOnline: userInfo.get("lastOnline"),
            description: userInfo.get("description")),
      );
        final String encodedData = ContactUser.encode(conversations);

        //Speicher Pfad
        LocalData.putString("conversation_list", encodedData);

    }
  }

  static Future<void> addMessage(Message message) async {
    String encryptedTextSender = Encryption().encrypt(message.messageText,
        Encryption().parsePublicKeyFromPem(LocalData.getString("publicKey")));

    final String messagesString =
    LocalData.getString("conversation_" + message.receiver);

    List<Message> messages =
    LocalData.exitsString("conversation_" + message.receiver)
        ? Message.decode(messagesString)
        : [];

    messages.add(
      Message(
        type: message.type,
        time: message.time,
        status: message.status,
        id: (LocalData.exitsString("conversation_" + message.receiver)
            ? Message.decode(LocalData.getString(
            "conversation_" +message.receiver))
            .length
            : 0) +
            1,
        messageText: encryptedTextSender,
        sender: FirebaseAuth.instance.currentUser.displayName,
        receiver: message.receiver,
      ),
    );
      final String encodedData = Message.encode(messages);
      LocalData.putString("conversation_" + message.receiver, encodedData);
  }

  static Future<void> updateConversations() async {
    final QuerySnapshot conversationsQuery = await FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Conversations")
        .collection("Conversations_Collection")
        .get();
    if (conversationsQuery.size != 0) {
      for (int i = 0; i < conversationsQuery.docs.length; i++) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(conversationsQuery.docs[i].id)
            .doc("Conversations")
            .collection("Conversations_Collection")
            .doc(FirebaseAuth.instance.currentUser.displayName)
            .collection("Sent_Messages")
            .orderBy("id", descending: false)
            .get();

        for (int i1 = 0; i1 < querySnapshot.size; i1++) {
          FirebaseFirestore.instance
              .collection(conversationsQuery.docs[i].id)
              .doc("Conversations")
              .collection("Conversations_Collection")
              .doc(FirebaseAuth.instance.currentUser.displayName)
              .collection("Sent_Messages")
              .doc(querySnapshot.docs[i1].id)
              .update({
            'status': "received",
          }).asStream();
        }

        final String messagesString = LocalData.getString(
            "conversation_" + conversationsQuery.docs[i].id);

        List<Message> messages = LocalData.exitsString(
            "conversation_" + conversationsQuery.docs[i].id)
            ? Message.decode(messagesString)
            : [];

        final QuerySnapshot messagesQuery = await FirebaseFirestore.instance
            .collection(FirebaseAuth.instance.currentUser.displayName)
            .doc("Conversations")
            .collection("Conversations_Collection")
            .doc(conversationsQuery.docs[i].id)
            .collection("Messages")
            .orderBy("id", descending: false)
            .get();

        for (int i1 = 0; i1 < messagesQuery.docs.length; i1++) {
          messages.add(
            Message(
                time: messagesQuery.docs[i1].get("time"),
                type: messagesQuery.docs[i1].get("type"),
                messageText: messagesQuery.docs[i1].get("message"),
                sender: messagesQuery.docs[i1].get("sender"),
                receiver: messagesQuery.docs[i1].get("receiver"),
                status: messagesQuery.docs[i1].get("status")),
          );
          await FirebaseFirestore.instance
              .collection(FirebaseAuth.instance.currentUser.displayName)
              .doc("Conversations")
              .collection("Conversations_Collection")
              .doc(conversationsQuery.docs[i].id)
              .collection("Messages")
              .doc(messagesQuery.docs[i1].id)
              .delete();
          final String encodedData = Message.encode(messages);

          //Speicher Pfad
          LocalData.putString(
              "conversation_" + conversationsQuery.docs[i].id, encodedData);
        }
      }
    }
  }

  static Future<void> updateContactList() async {
    List<ContactUser> conversations = [];
    final QuerySnapshot conversationsQuery = await FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Conversations")
        .collection("Conversations_Collection")
        .get();
    for (int i = 0; i < conversationsQuery.docs.length; i++) {
      final DocumentSnapshot userInfo = await FirebaseFirestore.instance
          .collection(conversationsQuery.docs[i].id)
          .doc("Information")
          .get();

      conversations.add(
        ContactUser(
            name:
            getContactName(ContactUser(id: conversationsQuery.docs[i].id)),
            id: conversationsQuery.docs[i].id,
            imageUrl: userInfo.get("imageUrl"),
            lastOnline: userInfo.get("lastOnline"),
            description: userInfo.get("description")),
      );
      if (conversations.length == conversationsQuery.docs.length) {
        final String encodedData = ContactUser.encode(conversations);

          LocalData.putString("conversation_list", encodedData);

      }
    }
  }



  static void fetchNotifications(Function setState) async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

    void sendTokenToServer(String fcmToken) {
      print('Token: $fcmToken');
      // send key to your server to allow server to use
      // this token to send push notifications
    }

    _firebaseMessaging.onTokenRefresh.listen(sendTokenToServer);
    _firebaseMessaging.getToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
          Timer(Duration(seconds: 2), () => setState());

      }
    });
  }
}