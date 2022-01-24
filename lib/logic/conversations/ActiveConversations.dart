import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ActiveConversations {
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
        setState();
      }
    });
  }

  static void updateUserInformation() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
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

          final String encodedData = ContactUser.encode(users);

          LocalData.putString("conversation_list", encodedData);
        });
      }
    }
  }
}
