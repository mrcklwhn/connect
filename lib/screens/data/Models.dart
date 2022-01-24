import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/screens/conversations/conversation/ConversationPage.dart';
import 'package:flutter/material.dart';

class ContactUser {
  String id;
  String name;
  String imageUrl;
  String lastOnline;
  String description;

  ContactUser({
    this.name,
    this.imageUrl,
    this.id,
    this.lastOnline,
    this.description,});

  factory ContactUser.fromJson(Map<String, dynamic> jsonData) {
    return ContactUser(
      id: jsonData['id'],
      name: jsonData['name'],
      imageUrl: jsonData['imageUrl'],
      lastOnline: jsonData['lastOnline'],
      description: jsonData['description'],
    );
  }

  static Map<String, dynamic> toMap(ContactUser user) => {
    'id': user.id,
    'name': user.name,
    'imageUrl': user.imageUrl,
    'lastOnline': user.lastOnline,
    'description': user.description,
  };

  static String encode(List<ContactUser> users) => json.encode(
    users
        .map<Map<String, dynamic>>((user) => ContactUser.toMap(user))
        .toList(),
  );

  static List<ContactUser> decode(String users) =>
      (json.decode(users) as List<dynamic>)
          .map<ContactUser>((item) => ContactUser.fromJson(item))
          .toList();
}

class Message {
  String sender;
  String receiver;
  String messageText;
  String imageURL;
  String type;
  String time;
  String status;
  int id;

  Message({
    this.sender,
    this.receiver,
    this.messageText,
    this.type,
    this.status,
    this.imageURL,
    this.time,
  this.id});

  factory Message.fromJson(Map<String, dynamic> jsonData) {
    return Message(
      sender: jsonData['sender'],
      receiver: jsonData['receiver'],
      messageText: jsonData['messageText'],
      type: jsonData['type'],
      status: jsonData['status'],
      imageURL: jsonData['imageURL'],
      time: jsonData['time'],
      id: jsonData['id'],
    );
  }

  static Map<String, dynamic> toMap(Message message) => {
    'sender': message.sender,
    'receiver': message.receiver,
    'messageText': message.messageText,
    'type': message.type,
    'status': message.status,
    'imageURL': message.imageURL,
    'time': message.time,

    'id': message.id,
  };

  static String encode(List<Message> messages) => json.encode(
    messages
        .map<Map<String, dynamic>>((message) => Message.toMap(message))
        .toList(),
  );

  static List<Message> decode(String messages) =>
      (json.decode(messages) as List<dynamic>)
          .map<Message>((item) => Message.fromJson(item))
          .toList();
}

class StoryTile extends StatelessWidget {

  final ContactUser contactUser;

  const StoryTile({Key key, this.contactUser}) : super(key: key);


  Widget buildImage () {
      if(!contactUser.imageUrl.startsWith("default_image")) {
        return CircleAvatar(
          radius: 38,
          backgroundImage: CachedNetworkImageProvider(contactUser.imageUrl),
        );
      } else {
        return CircleAvatar(
          radius: 38,
          foregroundImage: AssetImage("assets/images/user_icon_" + contactUser.imageUrl.substring(contactUser.imageUrl.length-1) + ".png"),
        );
      }


  }






  @override
  Widget build(BuildContext context) {

    Widget buildDot () {
      if(contactUser.lastOnline == "online") {
        return Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            height: 16,
            width: 16,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(
                  color: Theme.of(context)
                      .scaffoldBackgroundColor,
                  width: 3),
            ),
          ),
        );
      }
      return Center();
    }

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ConversationPage(
            contactUser: contactUser,
          );
        }));
      },
      child: Container(
        margin: EdgeInsets.only(right: 16),
        child: Column(
          children: <Widget>[
            Stack(
              children: [

                        buildImage(),
buildDot(),


                // related_type_equality_checks
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              contactUser.name.split(" ").first,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,),
            )
          ],
        ),
      ),
    );
  }
}







