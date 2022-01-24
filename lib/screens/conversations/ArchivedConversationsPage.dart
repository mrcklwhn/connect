
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/data/ConversationCellWidget.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:flutter/material.dart';

class ArchivedConversationsPage extends StatefulWidget {
  final int currentIndex;

  final Function onChangeIndex;

  const ArchivedConversationsPage({Key key, this.currentIndex, this.onChangeIndex})
      : super(key: key);

  @override
  _ArchivedConversationsPageState createState() => _ArchivedConversationsPageState();
}

class _ArchivedConversationsPageState extends State<ArchivedConversationsPage> {


  update() {
    setState(() {});
  }

  Widget buildListView() {
    if(LocalData.exitsString("conversation_archived")) {
      if (ContactUser
          .decode(LocalData.getString("conversation_archived"))
          .length > 0) {
        return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: ContactUser
                .decode(LocalData.getString("conversation_archived"))
                .length,
            itemBuilder: (context, index) {

              final String contactsString = LocalData.getString(
                  "conversation_archived");

              final List<ContactUser> users =
              ContactUser.decode(contactsString);

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
                  Divider(height: 1,indent: 65,)
                ],
              );


            });

      }
    }
    return Expanded(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(flex: 2,),
        Icon(Icons.announcement_rounded,size: 30),
        SizedBox(height: 5,),
        Text("No Conversations", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
        Spacer(flex: 3,)
      ],
    ));

  }





  @override
  Widget build(BuildContext context) {

    int currentIndex = widget.currentIndex;





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

                                color: Colors.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
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

