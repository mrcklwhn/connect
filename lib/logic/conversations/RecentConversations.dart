import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class RecentConversations {


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
          Timer(Duration(seconds: 1), () => setState());

      }
    });
  }

  static Future<void> updateConversations() async {
    if (FirebaseAuth.instance.currentUser != null) {
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
              name: getContactName(
                  ContactUser(id: conversationsQuery.docs[i].id)),
              id: conversationsQuery.docs[i].id,
              imageUrl: userInfo.get("imageUrl"),
              lastOnline: userInfo.get("lastOnline"),
              description: userInfo.get("description")),
        );
        final String encodedData = ContactUser.encode(conversations);
        LocalData.putString("conversation_list", encodedData);

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(conversationsQuery.docs[i].id)
            .doc("Conversations")
            .collection("Conversations_Collection")
            .doc(FirebaseAuth.instance.currentUser.displayName)
            .collection("Sent_Messages")
            .orderBy("id", descending: false)
            .get();
        if (querySnapshot != null) {
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
        }

        List<Message> messages = LocalData.exitsString(
            "conversation_" + conversationsQuery.docs[i].id) &&
            Message.decode(LocalData.getString(
                "conversation_" + conversationsQuery.docs[i].id))
                .length !=
                0
            ? Message.decode(LocalData.getString(
            "conversation_" + conversationsQuery.docs[i].id))
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

          //Speicher Pfad
          final String encodedDataMsg = Message.encode(messages);
          LocalData.putString(
              "conversation_" + conversationsQuery.docs[i].id, encodedDataMsg);
        }
      }
    }
  }

  static Future<void> updateUserInformation() async {
    String conversationString = LocalData.getString("conversation_list");

    final List<ContactUser> users = ContactUser.decode(conversationString);

    for (int i = 0; i < users.length; i++) {
      FirebaseFirestore.instance
          .collection(users[i].id)
          .doc("Information")
          .get()
          .then((snapshot) {
        ContactUser newUser = ContactUser(
            name: getContactName(ContactUser(id: users[i].id)),
            imageUrl: snapshot.get("imageUrl"),
            id: users[i].id,
            lastOnline: snapshot.get("lastOnline"),
            description: snapshot.get("description"));

        users.removeWhere((item) => item.id == users[i].id);
        users.add(newUser);

        //Speicher Pfad

        final String encodedData = ContactUser.encode(users);

        LocalData.putString("conversation_list", encodedData);
      });
    }
  }
}