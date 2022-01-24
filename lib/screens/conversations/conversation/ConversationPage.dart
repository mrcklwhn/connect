import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/conversations/conversation/Conversation.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/logic/data/Messaging.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/data/ConversationMessageWidget.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'OtherUserProfilePage.dart';


// ignore: must_be_immutable
class ConversationPage extends StatefulWidget {
  ContactUser contactUser;
  Function updateParent;

  ConversationPage({@required this.contactUser, this.updateParent});
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage>
    with WidgetsBindingObserver {
  Timer timer;
  TextEditingController _messageController = new TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (FirebaseAuth.instance.currentUser != null) {
      // TODO: implement didChangeAppLifecycleState

      super.didChangeAppLifecycleState(state);
      if (AppLifecycleState.paused == state) {
        timer.cancel();
      } else if (AppLifecycleState.resumed == state) {
        if (!timer.isActive) {
          timer = Timer.periodic(
              Duration(
                seconds: 1,
              ), (timer) async {
            Conversation.sendUpdateMessageStatus(widget.contactUser.id);
          });
        }
      } else if (AppLifecycleState.inactive == state) {
        timer.cancel();
      } else if (AppLifecycleState.detached == state) {
        timer.cancel();
      }
    }
  }

  void update() {
     setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Conversation.fetchNotifications(update);
    Conversation.openedConversation(widget.contactUser.id);
    Conversation.updateMessageStatus(widget.contactUser.id);
    timer = Timer.periodic(
        Duration(
          seconds: 1,
        ), (timer) async {
      Conversation.sendUpdateMessageStatus(widget.contactUser.id);
    });

    // After 1 second, it takes you to the bottom of the ListView
    Timer(Duration(seconds: 1), () => scrollToBottom());
  }



  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    Conversation.closedConversation(widget.contactUser.id);
    if (timer != null) {
      timer.cancel();
    }
  }


  Widget userPicture(ContactUser contactUser) {
    if (!widget.contactUser.imageUrl.startsWith("default_image")) {
      return InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return OtherUserProfilePage(
                contactUser: widget.contactUser,
                updateParent: widget.updateParent);
          }));
        },
        child: CircleAvatar(
          radius: 25,
          backgroundImage:
              CachedNetworkImageProvider(widget.contactUser.imageUrl),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return OtherUserProfilePage(
                contactUser: widget.contactUser,
                updateParent: widget.updateParent);
          }));
        },
        child: CircleAvatar(
          radius: 25,
          foregroundImage: AssetImage("assets/images/user_icon_" +
              widget.contactUser.imageUrl
                  .substring(widget.contactUser.imageUrl.length - 1) +
              ".png"),
        ),
      );
    }
  }

  TextButton userInfo(ContactUser contactUser) {
    return TextButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return OtherUserProfilePage(contactUser: widget.contactUser);
        }));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.contactUser.name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(contactUser.id)
                  .doc("Information")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data.get("lastOnline") != "online"
                          ? Conversation.getLastOnline(snapshot.data.get("lastOnline"))
                          : "online",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    );
                  }
                }
                return Center();
              }),
        ],
      ),
    );
  }

  scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent + 5,
        duration: Duration(milliseconds: 500), curve: Curves.bounceIn);
  }

  Column buildBody() {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: LocalData.exitsString(
                          "conversation_" + widget.contactUser.id)
                      ? Message.decode(LocalData.getString(
                              "conversation_" + widget.contactUser.id))
                          .length
                      : 0,
                  itemBuilder: (context, index) {
                    if (LocalData.exitsString(
                        "conversation_" + widget.contactUser.id)) {
                      final String pinnedConversationsString =
                          LocalData.getString(
                              "conversation_" + widget.contactUser.id);

                      final List<Message> messages =
                          Message.decode(pinnedConversationsString);

                      if (messages.length != 0) {
                        if (index < messages.length - 1) {
                          if (messages[index].receiver ==
                                  messages[index + 1].receiver ||
                              messages[index].sender ==
                                  messages[index + 1].sender) {
                            return ConversationMessage(
                              nextMessageByUser: true,
                              message: Message(
                                  messageText: messages[index].messageText,
                                  sender: messages[index].sender,
                                  receiver: messages[index].receiver,
                                  status: messages[index].status,
                                  imageURL: widget.contactUser.imageUrl,
                                  type: messages[index].type,
                                  time: messages[index].time),
                              user: widget.contactUser,
                            );
                          } else {
                            return ConversationMessage(
                              nextMessageByUser: false,
                              message: Message(
                                  messageText: messages[index].messageText,
                                  sender: messages[index].sender,
                                  receiver: messages[index].receiver,
                                  status: messages[index].status,
                                  imageURL: widget.contactUser.imageUrl,
                                  type: messages[index].type,
                                  time: messages[index].time),
                              user: widget.contactUser,
                            );
                          }
                        } else {
                          return ConversationMessage(
                            nextMessageByUser: false,
                            message: Message(
                                messageText: messages[index].messageText,
                                sender: messages[index].sender,
                                receiver: messages[index].receiver,
                                status: messages[index].status,
                                imageURL: widget.contactUser.imageUrl,
                                type: messages[index].type,
                                time: messages[index].time),
                            user: widget.contactUser,
                          );
                        }
                      }
                    }
                    return Center();
                  }),
            ),
          ),
        ),
        buildInputField()
      ],
    );
  }

  buildInputField() {
    return GestureDetector(
      onVerticalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity > 0) {
          // User swiped Left
          FocusScope.of(context).unfocus();
        }
      },
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * 0.75,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).backgroundColor
                        : Colors.white,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: TextField(
                          autocorrect: false,
                          style: TextStyle(fontSize: 17),
                          controller: _messageController,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: "Type message",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.attach_file,
                        ),
                        onPressed: () async {
                          final String messagesString = LocalData.getString(
                              "conversation_" + widget.contactUser.id);

                          List<Message> messages = LocalData.exitsString(
                                  "conversation_" + widget.contactUser.id)
                              ? Message.decode(messagesString)
                              : [];

                          try {
                            final image = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (image == null) return;

                            final tempImage = File(image.path);

                            File croppedImage = await ImageCropper.cropImage(
                              sourcePath: tempImage.path,
                              cropStyle: CropStyle.rectangle,
                              aspectRatio:
                                  CropAspectRatio(ratioX: 1, ratioY: 1),
                            );

                            if (croppedImage == null) return;

                            final destination =
                                FirebaseAuth.instance.currentUser.displayName +
                                    "_" +
                                    widget.contactUser.id +
                                    "_" +
                                    messages.length.toString();
                            task = FirebaseApi.uploadFile(
                                destination, croppedImage);

                            if (task == null) return;

                            final snapshot = await task.whenComplete(() {});
                            var urlDownload =
                                await snapshot.ref.getDownloadURL();
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

                            await Conversation.addMessage(Message(
                                sender: FirebaseAuth.instance.currentUser.displayName,
                                receiver: widget.contactUser.id,
                                status: "loading",
                                messageText: urlDownload,
                                type: "image",
                                time: currentTime));

                            await sendMessage(Message(
                                sender: FirebaseAuth
                                    .instance.currentUser.displayName,
                                receiver: widget.contactUser.id,
                                messageText: urlDownload,
                                type: "image",
                                status: "sent",
                                id: (LocalData.exitsString(
                                        "conversation_" + widget.contactUser.id)
                                    ? Message.decode(LocalData.getString(
                                            "conversation_" +
                                                widget.contactUser.id))
                                        .length
                                    : 0),
                                time: currentTime));
                            await Conversation.addConversation();

                            //Speicher Pfad
                            DocumentSnapshot ref = await FirebaseFirestore
                                .instance
                                .collection(widget.contactUser.id)
                                .doc("Settings")
                                .get();
                            if (ref.get(
                                    "Notifications.Tactful_Notifications") ==
                                false) {
                              final response = await Messaging.sendToTopic(
                                title: await Conversation.getUserName(FirebaseAuth
                                        .instance.currentUser.displayName) ??
                                    FirebaseAuth
                                        .instance.currentUser.displayName,
                                body: "Image",
                                senderId: FirebaseAuth
                                    .instance.currentUser.displayName,
                                type: "image",
                                topic: removeCharacters(widget.contactUser.id),
                                // fcmToken: fcmToken,
                              );

                              if (response.statusCode != 200) {
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.error,
                                  backgroundColor:
                                      Theme.of(context).backgroundColor,
                                  confirmBtnColor: Colors.red,
                                  confirmBtnText: "Try again",
                                  cancelBtnText: "Cancel",
                                  title: "Unable to send message!",
                                  text:
                                      "Connection to the internet was unsuccessful!!",
                                );
                              }
                            } else {
                              final response = await Messaging.sendToTopic(
                                title: "New Notification from MyChat",
                                body:
                                    "You received a message while you were absent!",
                                senderId: FirebaseAuth
                                    .instance.currentUser.displayName,
                                type: "message",
                                topic: removeCharacters(widget.contactUser.id),
                                // fcmToken: fcmToken,
                              );

                              if (response.statusCode != 200) {
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.error,
                                  backgroundColor:
                                      Theme.of(context).backgroundColor,
                                  confirmBtnColor: Colors.red,
                                  confirmBtnText: "Try again",
                                  cancelBtnText: "Cancel",
                                  title: "Unable to send message!",
                                  text:
                                      "Connection to the internet was unsuccessful!!",
                                );
                              }
                            }

                            CoolAlert.show(
                                context: context,
                                type: CoolAlertType.loading,
                                text: "Sending image...",
                                autoCloseDuration: Duration(seconds: 1));
                          } on PlatformException {
                            print("Failed to pick image:§e");
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  color: Colors.indigoAccent,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: IconButton(
                    icon: Icon(Icons.send_rounded),
                    color: Colors.white,
                    onPressed: () async {
                      if (_messageController.text.isNotEmpty) {
                        String msg = _messageController.text;

                        setState(() {
                          _messageController.clear();
                        });
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

                        await Conversation.addMessage(Message(
                          sender: FirebaseAuth.instance.currentUser.displayName,
                            receiver: widget.contactUser.id,
                            status: "loading",
                            messageText: msg,
                            type: "text",
                            time: currentTime));

                        await sendMessage(Message(
                            sender:
                                FirebaseAuth.instance.currentUser.displayName,
                            receiver: widget.contactUser.id,
                            messageText: msg,
                            type: "text",
                            status: "sent",
                            id: (LocalData.exitsString(
                                    "conversation_" + widget.contactUser.id)
                                ? Message.decode(LocalData.getString(
                                        "conversation_" +
                                            widget.contactUser.id))
                                    .length
                                : 0),
                            time: currentTime));
                        await Conversation.addConversation();

                        //Speicher Pfad
                        DocumentSnapshot ref = await FirebaseFirestore.instance
                            .collection(widget.contactUser.id)
                            .doc("Settings")
                            .get();
                        if (ref.get("Notifications.Tactful_Notifications") ==
                            false) {
                          final response = await Messaging.sendToTopic(
                            title: await Conversation.getUserName(FirebaseAuth
                                    .instance.currentUser.displayName) ??
                                FirebaseAuth.instance.currentUser.displayName,
                            body: msg.toString(),
                            senderId:
                                FirebaseAuth.instance.currentUser.displayName,
                            type: "message",
                            topic: removeCharacters(widget.contactUser.id),
                            // fcmToken: fcmToken,
                          );

                          if (response.statusCode != 200) {
                            CoolAlert.show(
                              context: context,
                              type: CoolAlertType.error,
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              confirmBtnColor: Colors.red,
                              confirmBtnText: "Try again",
                              cancelBtnText: "Cancel",
                              title: "Unable to send message!",
                              text:
                                  "Connection to the internet was unsuccessful!!",
                            );
                          }
                        } else {
                          final response = await Messaging.sendToTopic(
                            title: "New Notification from MyChat",
                            body:
                                "You received a message while you were absent!",
                            senderId:
                                FirebaseAuth.instance.currentUser.displayName,
                            type: "message",
                            topic: removeCharacters(widget.contactUser.id),
                            // fcmToken: fcmToken,
                          );

                          if (response.statusCode != 200) {
                            CoolAlert.show(
                              context: context,
                              type: CoolAlertType.error,
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              confirmBtnColor: Colors.red,
                              confirmBtnText: "Try again",
                              cancelBtnText: "Cancel",
                              title: "Unable to send message!",
                              text:
                                  "Connection to the internet was unsuccessful!!",
                            );
                          }
                        }
                        if (widget.updateParent != null) {
                          widget.updateParent();
                        }
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: userInfo(widget.contactUser),
        actions: [
          userPicture(widget.contactUser),
          SizedBox(
            width: 20,
          )
        ],
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: buildBody(),
    );
  }
}
