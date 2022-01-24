import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/conversations/RecentConversations.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/data/ConversationCellWidget.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RecentConversationsPage extends StatefulWidget {
  final int currentIndex;

  final Function onChangeIndex;
  final Function updateParent;

  const RecentConversationsPage(
      {Key key, this.currentIndex, this.onChangeIndex, this.updateParent})
      : super(key: key);

  @override
  _RecentConversationsPageState createState() => _RecentConversationsPageState();
}

class _RecentConversationsPageState extends State<RecentConversationsPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);



  update() {
    widget.updateParent();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    RecentConversations.fetchNotifications(update);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RecentConversations.updateConversations();
    });
  }


  void _onRefresh() async {
    // monitor network fetch
    widget.updateParent();

    await RecentConversations.updateConversations();

    await RecentConversations.updateUserInformation();

    if (mounted) setState(() {});
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 500));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = widget.currentIndex;

    bool isArchived(ContactUser user) {
      if (LocalData.exitsString("conversation_archived")) {
        List<ContactUser> archivedUsers =
            ContactUser.decode(LocalData.getString("conversation_archived"));

        List<String> archivedUsersIds = [];

        for (int i = 0;
            i <
                ContactUser.decode(LocalData.getString("conversation_archived"))
                    .length;
            i++) {
          archivedUsersIds.add(archivedUsers[i].id);
        }
        if (archivedUsersIds.contains(user.id)) {
          return true;
        }
        return false;
      } else {
        return false;
      }
    }

    Widget buildListView() {
      if (LocalData.exitsString("conversation_list")) {
        if (ContactUser.decode(LocalData.getString("conversation_list"))
                .length !=
            0) {
          return Expanded(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: BezierCircleHeader(
                bezierColor: Colors.transparent,
                circleColor: Colors.grey,
                dismissType: BezierDismissType.None,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  primary: false,
                  itemCount: ContactUser.decode(
                          LocalData.getString("conversation_list"))
                      .length,
                  itemBuilder: (context, index) {
                    final String contactsString =
                        LocalData.getString("conversation_list");

                    final List<ContactUser> users =
                        ContactUser.decode(contactsString);
                    if (!isArchived(ContactUser(id: users[index].id))) {
                      return Column(
                        children: [
                          ConversationCellWidget(
                              updateParent: update,
                              contactUser: ContactUser(
                                imageUrl: users[index].imageUrl,
                                id: users[index].id,
                                name: users[index].name,
                                description: users[index].description,
                                lastOnline: users[index].lastOnline,
                              )),
                          Divider(
                            height: 1,
                            indent: 65,
                          )
                        ],
                      );
                    }
                    return Center();
                  }),
            ),
          );
        }
      }
      return Expanded(
          child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: BezierCircleHeader(
          bezierColor: Colors.transparent,
          circleColor: Colors.grey,
          dismissType: BezierDismissType.None,
        ),
        controller: _refreshController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(
              flex: 2,
            ),
            Icon(Icons.announcement_rounded, size: 30),
            SizedBox(
              height: 5,
            ),
            Text(
              "No Conversations",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Spacer(
              flex: 3,
            )
          ],
        ),
      ));
    }

    return Expanded(
      child: Container(
          child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      if (currentIndex != 0) {
                        setState(() {
                          currentIndex = 0;
                        });
                        widget.onChangeIndex(0);
                      }
                    },
                    child: Text("Recent",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  TextButton(
                    onPressed: () {
                      if (currentIndex != 1) {
                        setState(() {
                          currentIndex = 1;
                        });
                        widget.onChangeIndex(1);
                      }
                    },
                    child: Text("Active",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.archive_rounded),
                    onPressed: () {
                      if (currentIndex != 2) {
                        setState(() {
                          currentIndex = 2;
                        });
                        widget.onChangeIndex(2);
                      }
                    },
                    color: Colors.grey,
                    iconSize: 25,
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .01,
          ),
          buildListView(),
        ],
      )),
    );
  }
}
