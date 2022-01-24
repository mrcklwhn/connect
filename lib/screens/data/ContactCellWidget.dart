import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/logic/data/ContactCell.dart';
import 'package:connect/screens/conversations/conversation/ConversationPage.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';

import 'Models.dart';

class ContactCellWidget extends StatelessWidget {
  final Function updateParent;
  final ContactUser contactUser;

  const ContactCellWidget({Key key, this.contactUser, this.updateParent})
      : super(key: key);
  Widget _getIconButton(color, icon) {
    return Container(
      width: 55,
      height: 55,
      child: Icon(
        icon,
        color: color,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
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
                foregroundImage: AssetImage("assets/images/user_icon_" +
                    contactUser.imageUrl
                        .substring(contactUser.imageUrl.length - 1) +
                    ".png"),
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
            foregroundImage: AssetImage("assets/images/user_icon_" +
                contactUser.imageUrl
                    .substring(contactUser.imageUrl.length - 1) +
                ".png"),
          );
        }
      }
    }

    return SwipeActionCell(
      backgroundColor: Colors.transparent,
      key: ValueKey(contactUser),
      closeWhenScrolling: true,
      trailingActions: [
        SwipeAction(
            widthSpace: 90,
            icon: Icon(
              Icons.delete,
              color: Colors.white,
              size: 30,
            ),
            style: TextStyle(fontSize: 18, height: 1.3, color: Colors.white),
            title: "Delete",
            onTap: (CompletionHandler handler) async {
              ///false means that you just do nothing,it will close
              /// action buttons by default
              ///
              handler(false);
              CoolAlert.show(
                  context: context,
                  type: CoolAlertType.confirm,
                  backgroundColor: Theme.of(context).backgroundColor,
                  confirmBtnColor: Colors.red,
                  confirmBtnText: "Delete",
                  cancelBtnText: "Cancel",
                  title: "Delete Contact!",
                  text: "Do you want to delete this Contact?",
                  onConfirmBtnTap: () {
                    ContactCell.deleteUser(ContactUser(id: contactUser.id));
                    Navigator.pop(context);
                  });
            },
            color: Colors.red),
      ],
      child: Container(
        height: 80,
        margin: EdgeInsets.only(left: 10, right: 10),
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ConversationPage(
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
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      contactUser.name,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      contactUser.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Text(
                contactUser.lastOnline != "online"
                    ? ContactCell.getLastOnline(contactUser.lastOnline)
                    : "",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
