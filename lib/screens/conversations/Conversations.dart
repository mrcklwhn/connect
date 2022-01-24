import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ActiveConversationsPage.dart';
import 'ArchivedConversationsPage.dart';
import 'RecentConversationsPage.dart';

class ConversationsPage extends StatefulWidget {
  final Function onMenuTap;

  const ConversationsPage({Key key, this.onMenuTap}) : super(key: key);
  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  void onChangeIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  // ignore: must_call_super

  buildFixedChats() {
    if (LocalData.exitsString("conversation_pinned")) {
      final String pinnedConversationsString =
          LocalData.getString("conversation_pinned");

      final List<ContactUser> users =
          ContactUser.decode(pinnedConversationsString);
      if (users.length != 0) {
        return Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              height: 120,
              child: ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(
                        width: 16,
                      ),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: ContactUser.decode(
                          LocalData.getString("conversation_pinned"))
                      .length,
                  itemBuilder: (context, index) {
                    return StoryTile(
                      contactUser: ContactUser(
                        imageUrl: users[index].imageUrl,
                        id: users[index].id,
                        name: users[index].name,
                        description: users[index].description,
                      ),
                    );
                  }),
            ),
          ],
        );
      }
    }
    return Center();
  }

  buildBody() {
    return Column(
      children: [
        // ignore: unrelated_type_equality_checks
        buildFixedChats(),

        buildLowerPart(),
      ],
    );
  }

  refresh() {
    setState(() {});
  }

  Widget buildLowerPart() {
    if (currentIndex == 0) {
      return RecentConversationsPage(
        currentIndex: currentIndex,
        onChangeIndex: onChangeIndex,
        updateParent: refresh,
      );
    } else if (currentIndex == 1) {
      return ActiveConversationsPage(
        currentIndex: currentIndex,
        onChangeIndex: onChangeIndex,
      );
    } else if (currentIndex == 2) {
      return ArchivedConversationsPage(
          currentIndex: currentIndex, onChangeIndex: onChangeIndex);
    }
    return Center();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Got a new connectivity status!

      if (mounted) {
        if (result == ConnectivityResult.mobile) {
          Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 5),
              backgroundColor: Colors.indigoAccent,
              content: Row(
                children: [
                  Spacer(
                    flex: 1,
                  ),
                  Icon(
                    Icons.signal_cellular_alt_rounded,
                    color: Colors.white,
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Text(
                    "Connection to the internet was successful!",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(
                    flex: 2,
                  ),
                ],
              )));
          // I am connected to a mobile network.
        } else if (result == ConnectivityResult.wifi) {
          Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 5),
              backgroundColor: Colors.indigoAccent,
              content: Row(
                children: [
                  Spacer(
                    flex: 1,
                  ),
                  Icon(
                    CupertinoIcons.wifi,
                    color: Colors.white,
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Text(
                    "Connection to the internet was successful!",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(
                    flex: 2,
                  ),
                ],
              )));
          // I am connected to a wifi network.
        } else if (result == ConnectivityResult.none) {
          Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 30),
              backgroundColor: Colors.red,
              content: Row(
                children: [
                  Spacer(
                    flex: 1,
                  ),
                  Icon(
                    CupertinoIcons.wifi_exclamationmark,
                    color: Colors.white,
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Text(
                    "Connection to the internet was unsuccessful!",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(
                    flex: 2,
                  ),
                ],
              )));
          // I am connected to a wifi network.
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: buildBody(),
    );
  }
}
