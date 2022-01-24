import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/contacts/RecentContacts.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/data/ContactCellWidget.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'AddContactPage.dart';

class ActiveContacts extends StatefulWidget {
  final int currentIndex;

  final Function onChangeIndex;

  const ActiveContacts({Key key, this.currentIndex, this.onChangeIndex})
      : super(key: key);

  @override
  _ActiveContactsState createState() => _ActiveContactsState();
}



class _ActiveContactsState extends State<ActiveContacts> {



  RefreshController _refreshController =
  RefreshController(initialRefresh: false);



  void _onRefresh() async{
    // monitor network fetch
    await RecentContacts.updateUserInformation();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if(mounted)
      setState(() {

      });
    _refreshController.loadComplete();
  }
  refresh() {

    setState(() {
    });

  }


  Widget buildListView() {
    if(LocalData.exitsString("contact_list")) {
      if(ContactUser.decode(LocalData.getString("contact_list"))
          .length != 0) {


        return Expanded(
          child:
          SmartRefresher(
            enablePullDown: true,
            enablePullUp: false,
            header: BezierCircleHeader(bezierColor: Colors.transparent,circleColor: Colors.grey,dismissType: BezierDismissType.None,),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: ListView.builder(


                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount:
                ContactUser
                    .decode(LocalData.getString("contact_list"))
                    .length,
                itemBuilder: (context, index) {
                  final String contactsString =
                  LocalData.getString("contact_list");

                  final List<ContactUser> users =
                  ContactUser.decode(contactsString);
                  if(users[index].lastOnline == "online") {
                    return Column(
                      children: [
                        ContactCellWidget(
                            updateParent: refresh,
                            contactUser: ContactUser(
                                id: users[index].id,
                                name: users[index].name,
                                imageUrl: users[index].imageUrl,
                                lastOnline: users[index].lastOnline,
                                description: users[index].description
                            )),
                        Divider(height: 1, indent: 65,)
                      ],
                    );
                  }
                  return Center();
                }),
          ),
        );
      }
    }
    return Expanded(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(flex: 2,),
        Icon(Icons.contacts,size: 30),
        SizedBox(height: 5,),
        Text("No Contacts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
        Spacer(flex: 3,)
      ],
    ));

  }


  @override
  Widget build(BuildContext context) {


    return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.transparent,),

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
                        if (widget.currentIndex != 0) {
                          setState(() {
                            widget.onChangeIndex(0);
                          });
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
                        if (widget.currentIndex != 1) {
                          setState(() {
                            widget.onChangeIndex(1);
                          });
                        }
                      },
                      child: Text("Active",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.person_add_alt_1,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return Add_Contact_Page(updateParent: refresh,);
                            }));
                      },
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
        ));
  }
}
