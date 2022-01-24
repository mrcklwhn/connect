import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/Encryption.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encryption;

import 'Models.dart';

class ConversationMessage extends StatefulWidget {
  final Message message;
  final ContactUser user;
  final bool nextMessageByUser;
  const ConversationMessage({
    Key key,
    // ignore: non_constant_identifier_names
    @required this.message,
    @required this.user,
    this.nextMessageByUser,
  }) : super(key: key);
  @override
  _ConversationMessageState createState() => _ConversationMessageState();
}

class _ConversationMessageState extends State<ConversationMessage> {

  userPicture(ContactUser contactUser) {
    if (!contactUser.imageUrl.startsWith("default_image")) {
      return CircleAvatar(
        radius: 15,
        backgroundImage:
        CachedNetworkImageProvider(contactUser.imageUrl),
      );
    } else {
      return CircleAvatar(
        radius: 15,
        foregroundImage: AssetImage("assets/images/user_icon_" +
            contactUser.imageUrl
                .substring(contactUser.imageUrl.length - 1) +
            ".png"),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    Widget messageContaint(Message message) {
      switch (message.type) {
        case "text":
          return TextMessage(message: message, nextMessageByUser: widget.nextMessageByUser);
        case "image":
          return ImageMessage(message: message, nextMessageByUser: widget.nextMessageByUser);
      //case "Video"
      //  return VideoMessage();
        default:
          return SizedBox();
      }
    }

    return Padding(
      padding:  EdgeInsets.only(bottom: widget.nextMessageByUser ? 3 : 8, left: widget.user.name == FirebaseAuth.instance.currentUser.displayName ? 0 : 10 , right: widget.user.name == FirebaseAuth.instance.currentUser.displayName ? 0 : 10),
      child: Row(
        mainAxisAlignment: widget.message.sender ==
            FirebaseAuth.instance.currentUser.displayName
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (widget.message.sender !=
              FirebaseAuth.instance.currentUser.displayName) ...[
            if(!widget.nextMessageByUser) ...[
              userPicture(widget.user),
              SizedBox(width: 10),
            ],
          ],
          if (widget.message.sender !=
              FirebaseAuth.instance.currentUser.displayName) ...[
            if(widget.nextMessageByUser) ...[
              SizedBox(width: 40,)
            ],
          ],
          messageContaint(widget.message),
          if (widget.message.sender ==
              FirebaseAuth.instance.currentUser.displayName)
            MessageStatusDot(
              messageStatus: widget.message.status,
              user: widget.user,
            ),
        ],
      ),
    );
  }
}

class ImageMessage extends StatefulWidget {
  final Message message;

  final bool nextMessageByUser;

  const ImageMessage({Key key, this.message, this.nextMessageByUser}) : super(key: key);

  @override
  _ImageMessageState createState() => _ImageMessageState();
}

class _ImageMessageState extends State<ImageMessage> {


  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    String decryptedText =  Encryption()
        .decrypt(widget.message.messageText, Encryption().parsePrivateKeyFromPem(LocalData.getString("privateKey")));

    _getLastOnline(String lastOnline) {
      String currentDate =
      formatDate(DateTime.now().toLocal(), [dd, '.', mm, '.', yy]);
      var date = lastOnline.split(" ");

      if (lastOnline.startsWith(currentDate)) {
        return date[1].trim();
      } else {
        return date[0].trim();
      }
    }


    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
      },
      child: AnimatedContainer(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment:  widget.message.sender == FirebaseAuth.instance.currentUser.displayName ? CrossAxisAlignment.end :CrossAxisAlignment.start ,
            children: [
              AnimatedContainer(
                curve: Curves.fastOutSlowIn,
                duration: Duration(milliseconds: 500),
                width: isSelected
                    ? MediaQuery.of(context).size.height * .35
                    : MediaQuery.of(context).size.height * .2,
                height: isSelected
                    ? MediaQuery.of(context).size.height * .35
                    : MediaQuery.of(context).size.height * .2,
                decoration: new BoxDecoration(
                  borderRadius: widget.nextMessageByUser ? BorderRadius.circular(10) : BorderRadius.only(bottomLeft: widget.message.sender == FirebaseAuth.instance.currentUser.displayName ? Radius.circular(10) : Radius.circular(5), bottomRight: widget. message.sender == FirebaseAuth.instance.currentUser.displayName ? Radius.circular(5) : Radius.circular(10),
                      topRight: Radius.circular(10), topLeft: Radius.circular(10)),

                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image:               CachedNetworkImageProvider(decryptedText),

                  ),
                ),
              ),
              SizedBox(height: 3,),
              Text(_getLastOnline(widget.message.time), style: TextStyle(fontSize: 10, color: Colors.white))
            ],
          ),
        ),
        curve: Curves.fastOutSlowIn,
        duration: Duration(milliseconds: 500),
        width: isSelected
            ? MediaQuery.of(context).size.height * .35
            : MediaQuery.of(context).size.height * .2,
        height: isSelected
            ? MediaQuery.of(context).size.height * .35 +25
            : MediaQuery.of(context).size.height * .2 +25,
        decoration: BoxDecoration(
          color: widget.message.sender == FirebaseAuth.instance.currentUser.displayName
              ? Colors.indigoAccent             : Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black26,
            borderRadius: widget.nextMessageByUser ? BorderRadius.circular(15) : BorderRadius.only(bottomLeft: widget.message.sender == FirebaseAuth.instance.currentUser.displayName ? Radius.circular(15) : Radius.circular(5), bottomRight: widget. message.sender == FirebaseAuth.instance.currentUser.displayName ? Radius.circular(5) : Radius.circular(15),
                topRight: Radius.circular(15), topLeft: Radius.circular(15)),
           ),
      ),
    );
  }
}

class TextMessage extends StatelessWidget {
  final Message message;

  final bool nextMessageByUser;

  const TextMessage({
    Key key,
    this.message,
    this.nextMessageByUser
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {


    String decryptedText =  Encryption()
        .decrypt(message.messageText, Encryption().parsePrivateKeyFromPem(LocalData.getString("privateKey")));
    _getLastOnline(String lastOnline) {
      String currentDate =
      formatDate(DateTime.now().toLocal(), [dd, '.', mm, '.', yy]);
      var date = lastOnline.split(" ");

      if (lastOnline.startsWith(currentDate)) {
        return date[1].trim();
      } else {
        return date[0].trim();
      }
    }

    return Flexible(

      child: Container(
        margin: message.sender == FirebaseAuth.instance.currentUser.displayName ? EdgeInsets.only(left: 50) : EdgeInsets.only(right: 50) ,
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: message.sender == FirebaseAuth.instance.currentUser.displayName
              ? Colors.indigoAccent             : Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black26,
          borderRadius: nextMessageByUser ? BorderRadius.circular(15) : BorderRadius.only(bottomLeft: message.sender == FirebaseAuth.instance.currentUser.displayName ? Radius.circular(15) : Radius.circular(5), bottomRight: message.sender == FirebaseAuth.instance.currentUser.displayName ? Radius.circular(5) : Radius.circular(15),
              topRight: Radius.circular(15), topLeft: Radius.circular(15)),
        ),
        child: Column(
          crossAxisAlignment:  message.sender == FirebaseAuth.instance.currentUser.displayName ? CrossAxisAlignment.end :CrossAxisAlignment.start ,
          children: [
            Text(
              decryptedText,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 3,),
            Text(_getLastOnline(message.time), style: TextStyle(fontSize: 10, color: Colors.white))
          ],
        ),
      ),
    );
  }
}

class MessageStatusDot extends StatelessWidget {
  final ContactUser user;

  final String messageStatus;

  const MessageStatusDot({Key key, this.messageStatus, this.user})
      : super(key: key);

  Future<bool> userHasDisabledReadReceipts(ContactUser user) async {
    final databaseReference = await FirebaseFirestore.instance.collection(user.id).doc("Settings").get();
    return databaseReference.get("Privacy.Chats.Read_Receipts");
  }

  @override
  Widget build(BuildContext context) {

    Icon messageStatusIcon () {

      if(messageStatus == "loading") {
        return Icon(Icons.access_time,
          size: 11,
          color: Colors.white70,
        );
      }else if(messageStatus == "sent") {
        return Icon(Icons.done,
          size: 11,
          color: Colors.white70,
        );
      }else if(messageStatus == "received") {
        return Icon(Icons.done_all,
          size: 11,
          color: Colors.white70,
        );
      }else if(messageStatus == "viewed") {
        return Icon(Icons.done_all,
          size: 11,
          color: Colors.white70,
        );
      }

      return Icon(Icons.close,
        size: 11,
        color: Colors.white70,
      );
    }


    Color dotColor(String messageStatus) {
      switch (messageStatus) {
        case "not_sent":
          return Theme.of(context).errorColor;
        case "loading":
          return Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black26;
        case "sent":
          return Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black26;
        case "received":
          return Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black26;
        case "viewed":
          return Colors.green;
        default:
          return Colors.transparent;
      }
    }

    return Container(
          margin: EdgeInsets.only(left: 20 / 2),
          height: 15,
          width: 15,
          decoration: BoxDecoration(
            color: dotColor(messageStatus),
            shape: BoxShape.circle,
          ),
          child: messageStatusIcon(),
        );

  }
}
