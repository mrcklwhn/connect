import 'dart:core';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/ConversationCell.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/Encryption.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/conversations/conversation/ConversationPage.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:encrypt/encrypt.dart' as encryption;

import 'Models.dart';


class ConversationCellWidget extends StatelessWidget {

  final Function updateParent;
  final Message message;
  final ContactUser contactUser;

  const ConversationCellWidget({Key key, this.contactUser, this.message, this.updateParent})
      : super(key: key);


  Widget notificationBanner(int counter) {
    return Container(
      child: Text(
        counter.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget getIconButton(color, icon) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        ///set you real bg color in your content
        color: color,
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }




  List<SwipeAction> leadingActions() {


    if (getContactName(ContactUser(id: contactUser.id)) != contactUser.id) {
      if(!ConversationCell.isArchived(ContactUser(id: contactUser.id))) {
        List<SwipeAction> actions = [];
        actions.add(
          SwipeAction(
              widthSpace: ConversationCell.isPinned(contactUser) ? 85 : 70,
              icon: ConversationCell.isPinned(contactUser)
                  ? Icon(CupertinoIcons.pin_slash_fill, size: 30, color: Colors.white)
                  : Icon(CupertinoIcons.pin_fill, size: 30, color: Colors.white),
              style: TextStyle(fontSize: 18, height: 1.3, color: Colors.white),
              title: ConversationCell.isPinned(contactUser) ? "Unpin" : "Pin",
              color: Colors.indigoAccent,
              onTap: (handler) {
                if (ConversationCell.isPinned(contactUser)) {
                  ConversationCell.unPinUser(contactUser, updateParent);
                } else {
                  ConversationCell.pinUser(contactUser, updateParent);
                }

                // ignore: unnecessary_statements
              }),
        );

        return actions;
      }
    }
    return null;
  }



  @override
  Widget build(BuildContext context) {
    int messages = 0;

    Widget unreadMessages () {

      FirebaseFirestore.instance
          .collection(FirebaseAuth.instance.currentUser.displayName)
          .doc("Conversations")
          .collection("Conversations_Collection")
          .doc(contactUser.id)
          .collection("Messages")
          .get()
          .then((snapshot) {
        for (int i = 0; i < snapshot.docs.length; i++) {
          if (snapshot.docs[i].get("receiver") ==
              FirebaseAuth.instance.currentUser.displayName) {
            if (snapshot.docs[i].get("status") == "sent") {
              messages++;

            }
          }

        }



      });
      return messages != 0 ? notificationBanner(messages.toInt()) : Center();
    }


    Widget getMessageText() {
      if(LocalData.exitsString("conversation_" + contactUser.id) && Message.decode(LocalData.getString("conversation_" + contactUser.id)).length != 0) {
        String decryptedText =  Encryption()
            .decrypt(Message.decode(LocalData.getString("conversation_" + contactUser.id)).last.messageText, Encryption().parsePrivateKeyFromPem(LocalData.getString("privateKey")));

        if (Message
            .decode(LocalData.getString("conversation_" + contactUser.id))
            .last
            .type == "text") {
          return Text(
            decryptedText,
            maxLines: 1,

            overflow: TextOverflow.ellipsis,
          );
        } else if (Message
            .decode(LocalData.getString("conversation_" + contactUser.id))
            .last
            .type == "image") {
          return Row(
            children: [
              Icon(Icons.camera_alt_rounded,
                size: 18,),
              Text(
                " Image",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        }
      }
      return Text(
        "There are no messages in this conversation!",
        maxLines: 2,

        overflow: TextOverflow.ellipsis,
      );
    }

    Widget buildImage() {
      if (contactUser.lastOnline == "online") {
        if (!contactUser.imageUrl.startsWith("default_image")) {
          return Stack(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage:
                    CachedNetworkImageProvider(contactUser.imageUrl),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  height: 16,
                  width: 16,
                  decoration: BoxDecoration(
                    color: Colors.lightGreen,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.green,
                        width: 3),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Stack(
            children: [
              CircleAvatar(
                radius: 32,
                foregroundImage: AssetImage("assets/images/user_icon_" + contactUser.imageUrl.substring(contactUser.imageUrl.length-1) + ".png"),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  height: 16,
                  width: 16,
                  decoration: BoxDecoration(
                    color: Colors.lightGreen,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.green,
                        width: 3),
                  ),
                ),
              ),
            ],
          );
        }
      } else {
        if (!contactUser.imageUrl.startsWith("default_image")) {
          return CircleAvatar(
            radius: 32,
            backgroundImage: CachedNetworkImageProvider(contactUser.imageUrl),
          );
        } else {
          return CircleAvatar(
            radius: 32,
            foregroundImage: AssetImage("assets/images/user_icon_" + contactUser.imageUrl.substring(contactUser.imageUrl.length-1) + ".png"),
          );
        }
      }
    }
    List<SwipeAction> actions() {
      List<SwipeAction> actions = [];




      actions.add(SwipeAction(
          icon: Icon(ConversationCell.isArchived(ContactUser(id: contactUser.id)) ? Icons.unarchive_rounded: Icons.archive_rounded, color: Colors.white),
          style: TextStyle(fontSize: 16,height: 1.3, color: Colors.white),
          title: ConversationCell.isArchived(ContactUser(id: contactUser.id)) ? "Unarchive" : "Archive",
          color: Colors.grey,
          onTap: (handler) {
            if(ConversationCell.isArchived(ContactUser(id: contactUser.id))) {
              ConversationCell.unArchiveUser(ContactUser(id: contactUser.id), updateParent);
            }else {
              ConversationCell.unPinUser(ContactUser(id: contactUser.id), updateParent);
              ConversationCell.archiveUser(ContactUser(id: contactUser.id),updateParent);
            }
          }));
      actions.add(
          SwipeAction(
              icon: Icon(Icons.delete, color: Colors.white),
              style: TextStyle(fontSize: 18,height: 1.3, color: Colors.white),
              title: "Delete",
              color: Colors.red,
              onTap: (handler) async {


                handler(false);
                CoolAlert.show(
                    context: context,
                    type: CoolAlertType.confirm,

                    backgroundColor: Theme.of(context).backgroundColor,

                    confirmBtnColor: Colors.red,
                    confirmBtnText: "Delete",
                    cancelBtnText: "Cancel",
                    title: "Delete Conversation!",
                    text: "Do you want to delete this Conversation?",
                    onConfirmBtnTap: () {
                      ConversationCell.deleteConversation(contactUser, updateParent);
                      Navigator.pop(context);
                    }
                );

              }));


      return actions;
    }

    return SwipeActionCell(
      backgroundColor: Colors.transparent,
      key: ValueKey(contactUser),
      closeWhenScrolling: true,

      leadingActions: leadingActions(),
      trailingActions: actions(),
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        height: 80,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ConversationPage(
                updateParent: updateParent,
                contactUser: contactUser,
              );
            }));
          },
          child: Row(
            children: [
              buildImage(),
              SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10,),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      contactUser.name,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,),
                    ),
                  ),
                  SizedBox(height: 8),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection(
                          FirebaseAuth.instance.currentUser.displayName)
                          .doc("Settings")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            if (snapshot.data
                                .get("Privacy.Chats.Show_Messages_Preview")) {
                              return Container(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child: getMessageText());
                            } else {
                              return Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(Message.decode(LocalData.getString("conversation_" + contactUser.id)).length.toString()
                                   +
                                      " Messages in this Chat",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }
                          }
                        }
                        return Center();
                      }),

                ],
              ),
              Spacer(),
              LocalData.exitsString("conversation_" + contactUser.id) && Message.decode(LocalData.getString("conversation_" + contactUser.id)).length != 0?
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ConversationCell.getLastMessageSentTime(Message.decode(LocalData.getString("conversation_" + contactUser.id)).last.time),
                    ),
                    unreadMessages()
                  ],
                ): Center(),
            ],
          ),
        ),
      ),
    );
  }
}
