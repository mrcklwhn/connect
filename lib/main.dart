import 'dart:async';

import 'package:apple_sign_in/apple_sign_in.dart' as apple;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/contacts/ContactSearch.dart';
import 'package:connect/screens/contacts/Contacts.dart';
import 'package:connect/screens/conversations/ConversationSearch.dart';
import 'package:connect/screens/conversations/Conversations.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:connect/screens/data/Theme.dart';
import 'package:connect/screens/settings/SettingsPage.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'logic/data/Database.dart';
import 'logic/data/LocalData.dart';
import 'logic/data/Messaging.dart';
import 'logic/data/RouteBuilder.dart';
import 'screens/groups/groups.dart';

class AppleSignInAvailable {
  AppleSignInAvailable(this.isAvailable);
  final bool isAvailable;

  static Future<AppleSignInAvailable> check() async {
    return AppleSignInAvailable(await apple.AppleSignIn.isAvailable());
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalData.init();
  if (FirebaseAuth.instance.currentUser != null) {
    FirebaseMessaging.instance.subscribeToTopic(
        removeCharacters(FirebaseAuth.instance.currentUser.displayName));
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final appleSignInAvailable = await AppleSignInAvailable.check();
  runApp(Provider<AppleSignInAvailable>.value(
    value: appleSignInAvailable,
    child: MyApp(),
  ));
}

Future<bool> isSupporter(String id) async {
  final databaseReference =
      await FirebaseFirestore.instance.collection(id).doc("Information").get();
  return databaseReference.get("supporter") ?? false;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connect.',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RouteGenerator.generateRoute,
      initialRoute: FirebaseAuth.instance.currentUser != null ? "/" : "/setup",
    );
  }
}

class HomePage extends StatefulWidget {
  final UserCredential user;
  const HomePage({Key key, this.user}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  Timer timer;

  int currentIndex = 1;

  List<Widget> screens = [
    ConversationsPage(),
    GroupsPage(),
    ContactsPage(),
    SettingsPage()
  ];

  Future<bool> getAutoUpdateLastOnline() async {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Settings")
        .get()
        .then((snapshot) {
      return snapshot.get("Privacy.Activity.Auto-Update_Last_Online");
    });
  }

  void fetchNotifications() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

    if (Platform.isIOS) {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }
    }

    void sendTokenToServer(String fcmToken) {
      print('Token: $fcmToken');
      // send key to your server to allow server to use
      // this token to send push notifications
    }

    _firebaseMessaging.onTokenRefresh.listen(sendTokenToServer);
    _firebaseMessaging.getToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        if (message.data["type"] == "message") {
          // updating read receipiest (received)

          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(message.data["senderId"])
              .doc("Conversations")
              .collection("Conversations_Collection")
              .doc(FirebaseAuth.instance.currentUser.displayName)
              .collection("Sent_Messages")
              .orderBy("id", descending: false)
              .get();

          for (int i = 0; i < querySnapshot.size; i++) {
            FirebaseFirestore.instance
                .collection(message.data["senderId"])
                .doc("Conversations")
                .collection("Conversations_Collection")
                .doc(FirebaseAuth.instance.currentUser.displayName)
                .collection("Sent_Messages")
                .doc(querySnapshot.docs[i].id)
                .update({
              'status': "received",
            }).asStream();
          }

          List<ContactUser> conversations = [];
          final String messagesString =
              LocalData.getString("conversation_" + message.data["senderId"]);

          List<Message> messages = (LocalData.exitsString(
                      "conversation_" + message.data["senderId"]) ||
                  LocalData.getString(
                              "conversation_" + message.data["senderId"])
                          .length !=
                      0)
              ? Message.decode(messagesString)
              : [];

          final QuerySnapshot messagesQuery = await FirebaseFirestore.instance
              .collection(FirebaseAuth.instance.currentUser.displayName)
              .doc("Conversations")
              .collection("Conversations_Collection")
              .doc(message.data["senderId"])
              .collection("Messages")
              .orderBy("id", descending: false)
              .get();

          for (int i = 0; i < messagesQuery.docs.length; i++) {
            messages.add(
              Message(
                  time: messagesQuery.docs[i].get("time"),
                  type: messagesQuery.docs[i].get("type"),
                  messageText: messagesQuery.docs[i].get("message"),
                  sender: messagesQuery.docs[i].get("sender"),
                  receiver: messagesQuery.docs[i].get("receiver"),
                  status: messagesQuery.docs[i].get("status")),
            );
            final String encodedData = Message.encode(messages);

            //Speicher Pfad
            LocalData.putString(
                "conversation_" + message.data["senderId"], encodedData);
          }

          final QuerySnapshot conversationsQuery = await FirebaseFirestore
              .instance
              .collection(FirebaseAuth.instance.currentUser.displayName)
              .doc("Conversations")
              .collection("Conversations_Collection")
              .get();
          for (int i = 0; i < conversationsQuery.docs.length; i++) {
            final QuerySnapshot messageInfo = await FirebaseFirestore.instance
                .collection(FirebaseAuth.instance.currentUser.displayName)
                .doc("Conversations")
                .collection("Conversations_Collection")
                .doc(conversationsQuery.docs[i].id)
                .collection("Messages")
                .orderBy("id", descending: true)
                .get();
            if (messageInfo.size != 0) {
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

              for (int i1 = 0; i1 < messageInfo.docs.length; i1++) {
                await FirebaseFirestore.instance
                    .collection(FirebaseAuth.instance.currentUser.displayName)
                    .doc("Conversations")
                    .collection("Conversations_Collection")
                    .doc(conversationsQuery.docs[i].id)
                    .collection("Messages")
                    .doc(messageInfo.docs[i1].id)
                    .delete();
              }
              final String encodedData = ContactUser.encode(conversations);

              //Speicher Pfad
              LocalData.putString("conversation_list", encodedData);
            }
          }

          if (mounted) {
            setState(() {});
          }
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final databaseReference = FirebaseFirestore.instance;
    if (FirebaseAuth.instance.currentUser != null) {
      databaseReference
          .collection(FirebaseAuth.instance.currentUser.displayName)
          .doc("Settings")
          .get()
          .then((snapshot) {
        bool getUpdateLastOnlineStatus =
            snapshot.get("Privacy.Activity.Auto-Update_Last_Online");
        // TODO: implement didChangeAppLifecycleState

        super.didChangeAppLifecycleState(state);
        if (AppLifecycleState.paused == state) {
          updateLastOnline(
              FirebaseAuth.instance.currentUser.displayName, "offline");
          if (LocalData.getPasswordState()) {
            if (!LocalData.isLocked()) {
              LocalData.setLocked(true);

              Navigator.of(context).pushNamed('/');
            }
          }
        } else if (AppLifecycleState.resumed == state) {
          if (getUpdateLastOnlineStatus) {
            updateLastOnline(
                FirebaseAuth.instance.currentUser.displayName, "online");
          }
        } else if (AppLifecycleState.inactive == state) {
          updateLastOnline(
              FirebaseAuth.instance.currentUser.displayName, "offline");
          if (LocalData.getPasswordState()) {
            if (!LocalData.isLocked()) {
              LocalData.setLocked(true);

              Navigator.of(context).pushNamed('/');
            }
          }
        } else if (AppLifecycleState.detached == state) {
          updateLastOnline(
              FirebaseAuth.instance.currentUser.displayName, "offline");
          if (LocalData.getPasswordState()) {
            if (!LocalData.isLocked()) {
              LocalData.setLocked(true);

              Navigator.of(context).pushNamed('/');
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer.cancel();
    }

    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    notifyUserActivity();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<String> getUserName(String id) async {
    final databaseReference = await FirebaseFirestore.instance
        .collection(id)
        .doc("Information")
        .get();
    return databaseReference.get("name");
  }

  void notifyUserActivity() async {
    if (FirebaseAuth.instance.currentUser != null) {
      DocumentSnapshot myRef = await FirebaseFirestore.instance
          .collection(FirebaseAuth.instance.currentUser.displayName ?? "sd")
          .doc("Settings")
          .get();
      if (myRef.get("Notifications.User_Activity") == true) {
        if (LocalData.exitsString("contact_list")) {
          timer = Timer(Duration(seconds: 10), () async {
            for (int i = 0;
                i <
                    ContactUser.decode(LocalData.getString("contact_list"))
                        .length;
                i++) {
              DocumentSnapshot ref = await FirebaseFirestore.instance
                  .collection(
                      ContactUser.decode(LocalData.getString("contact_list"))[i]
                          .id)
                  .doc("Settings")
                  .get();
              if (ref.get("Notifications.User_Activity") == true) {
                final response = await Messaging.sendToTopic(
                  title: "New Notification from MyChat",
                  body: (await getUserName(
                              FirebaseAuth.instance.currentUser.displayName) ??
                          FirebaseAuth.instance.currentUser.displayName) +
                      " is now online again!",
                  senderId: FirebaseAuth.instance.currentUser.displayName,
                  type: "activity",
                  topic: removeCharacters(
                      ContactUser.decode(LocalData.getString("contact_list"))[i]
                          .id),
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
            }
          });
        }
      }
    }
  }

  Widget buildEditIcon() => InkWell(
        onTap: () async {
          try {
            final image =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            if (image == null) return;

            final tempImage = File(image.path);

            File croppedImage = await ImageCropper.cropImage(
              sourcePath: tempImage.path,
              cropStyle: CropStyle.rectangle,
              aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            );
            await uploadImage(
                    FirebaseAuth.instance.currentUser.displayName, croppedImage)
                .whenComplete(() {
              setState(() {});
            });
            CoolAlert.show(
                context: context,
                type: CoolAlertType.loading,
                text: "Uploading image...",
                autoCloseDuration: Duration(seconds: 1));
          } on PlatformException catch (e) {
            print("Failed to pick image:" + e.toString());
          }
        },
        child: Icon(
          Icons.add_a_photo_rounded,
          size: 30,
        ),
      );

  PreferredSizeWidget createAppBar() {
    if (currentIndex == 0) {
      return AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Messages",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          LocalData.exitsString("conversation_list")
              ? IconButton(
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate: ConversationSearch(ContactUser.decode(
                            LocalData.getString("conversation_list"))));
                  },
                  icon: Icon(
                    Icons.search,
                    size: 25,
                  ))
              : Center()
        ],
        backgroundColor: Theme.of(context).backgroundColor,
      );
    } else if (currentIndex == 1) {
      return AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Contacts",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          LocalData.exitsString("contact_list")
              ? IconButton(
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate: ContactSearch(ContactUser.decode(
                            LocalData.getString("contact_list"))));
                  },
                  icon: Icon(
                    Icons.search,
                    size: 25,
                  ))
              : Center()
        ],
        backgroundColor: Theme.of(context).backgroundColor,
      );
    } else if (currentIndex == 2) {
      return AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [],
        backgroundColor: Theme.of(context).backgroundColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: createAppBar(),
        body: screens[currentIndex],
        bottomNavigationBar: Container(
          color: Theme.of(context).backgroundColor,
          child: SafeArea(
            child: SalomonBottomBar(
              margin: EdgeInsets.all(15),
              currentIndex: currentIndex,
              onTap: (i) => setState(() => currentIndex = i),
              items: [
                /// Likes
                SalomonBottomBarItem(
                  icon: Icon(Icons.message_outlined),
                  activeIcon: Icon(
                    Icons.message,
                    color: Colors.orange,
                  ),
                  title: Text("Messages"),
                  selectedColor: Colors.orange,
                ),

                SalomonBottomBarItem(
                  icon: Icon(
                    Icons.groups_outlined,
                  ),
                  activeIcon: Icon(
                    Icons.groups,
                    color: Colors.blue,
                  ),
                  title: Text("Groups"),
                  selectedColor: Colors.blue,
                ),

                /// Search
                SalomonBottomBarItem(
                  icon: Icon(
                    Icons.contacts_outlined,
                  ),
                  activeIcon: Icon(
                    Icons.contacts,
                    color: Colors.blue,
                  ),
                  title: Text("Contacts"),
                  selectedColor: Colors.blue,
                ),

                /// Profile
                SalomonBottomBarItem(
                  icon: Icon(
                    Icons.settings_outlined,
                  ),
                  activeIcon: Icon(
                    Icons.settings,
                    color: Colors.red,
                  ),
                  title: Text("Settings"),
                  selectedColor: Colors.red,
                ),
              ],
            ),
          ),
        ));
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.notification != null) {
    if (message.data["type"] == "message") {
      // updating read receipiest (received)

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(message.data["senderId"])
          .doc("Conversations")
          .collection("Conversations_Collection")
          .doc(FirebaseAuth.instance.currentUser.displayName)
          .collection("Sent_Messages")
          .orderBy("id", descending: false)
          .get();

      for (int i = 0; i < querySnapshot.size; i++) {
        FirebaseFirestore.instance
            .collection(message.data["senderId"])
            .doc("Conversations")
            .collection("Conversations_Collection")
            .doc(FirebaseAuth.instance.currentUser.displayName)
            .collection("Sent_Messages")
            .doc(querySnapshot.docs[i].id)
            .update({
          'status': "received",
        }).asStream();
      }

      List<ContactUser> conversations = [];
      final String messagesString =
          LocalData.getString("conversation_" + message.data["senderId"]);

      List<Message> messages = (LocalData.exitsString(
                  "conversation_" + message.data["senderId"]) ||
              LocalData.getString("conversation_" + message.data["senderId"])
                      .length !=
                  0)
          ? Message.decode(messagesString)
          : [];

      final QuerySnapshot messagesQuery = await FirebaseFirestore.instance
          .collection(FirebaseAuth.instance.currentUser.displayName)
          .doc("Conversations")
          .collection("Conversations_Collection")
          .doc(message.data["senderId"])
          .collection("Messages")
          .orderBy("id", descending: false)
          .get();

      for (int i = 0; i < messagesQuery.docs.length; i++) {
        messages.add(
          Message(
              time: messagesQuery.docs[i].get("time"),
              type: messagesQuery.docs[i].get("type"),
              messageText: messagesQuery.docs[i].get("message"),
              sender: messagesQuery.docs[i].get("sender"),
              receiver: messagesQuery.docs[i].get("receiver"),
              status: messagesQuery.docs[i].get("status")),
        );
        final String encodedData = Message.encode(messages);

        //Speicher Pfad
        LocalData.putString(
            "conversation_" + message.data["senderId"], encodedData);
      }

      final QuerySnapshot conversationsQuery = await FirebaseFirestore.instance
          .collection(FirebaseAuth.instance.currentUser.displayName)
          .doc("Conversations")
          .collection("Conversations_Collection")
          .get();
      for (int i = 0; i < conversationsQuery.docs.length; i++) {
        final QuerySnapshot messageInfo = await FirebaseFirestore.instance
            .collection(FirebaseAuth.instance.currentUser.displayName)
            .doc("Conversations")
            .collection("Conversations_Collection")
            .doc(conversationsQuery.docs[i].id)
            .collection("Messages")
            .orderBy("id", descending: true)
            .get();
        if (messageInfo.size != 0) {
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

          for (int i1 = 0; i1 < messageInfo.docs.length; i1++) {
            await FirebaseFirestore.instance
                .collection(FirebaseAuth.instance.currentUser.displayName)
                .doc("Conversations")
                .collection("Conversations_Collection")
                .doc(conversationsQuery.docs[i].id)
                .collection("Messages")
                .doc(messageInfo.docs[i1].id)
                .delete();
          }
          final String encodedData = ContactUser.encode(conversations);

          //Speicher Pfad
          LocalData.putString("conversation_list", encodedData);
        }
      }
    }
  }
}
