
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/data/ConversationCellWidget.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:flutter/material.dart';



class ConversationSearch extends SearchDelegate {
  final List<ContactUser> conversationList;
  ConversationSearch(this.conversationList);


  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(onPressed: () {
        query = "";
      }, icon: Icon(Icons.clear,size: 25,color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(onPressed: () {
      Navigator.pop(context);

    }, icon: Icon( Icons.arrow_back_ios,size: 25,color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black));
    throw UnimplementedError();
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults

    List<ContactUser> suggestion = [];
    final String contactsString = LocalData.getString(
        "conversation_list");
    final List<ContactUser> users =
    ContactUser.decode(contactsString);
    query.isEmpty ? suggestion = users : suggestion.addAll(users.where((user) =>
        user.name.toLowerCase().contains(query.toLowerCase())
    ));
    if(suggestion.length != 0) {
      return ListView.builder(

          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          primary: false,
          itemCount: suggestion.length,
          itemBuilder: (context, index) {
            if (suggestion.length != 0) {
              return Column(
                children: [
                  ConversationCellWidget(
                      contactUser: ContactUser(
                        imageUrl: suggestion[index].imageUrl,

                        id: suggestion[index].id,
                        name: suggestion[index].name,
                        description: suggestion[index].description,
                        lastOnline: suggestion[index].lastOnline,
                      )),
                  Divider(height: 1, indent: 65,)
                ],
              );
            } else {
              return Center();
            }
            return Center();
          });
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 1,),
            Icon(Icons.announcement_rounded,size: 30),
            SizedBox(height: 5,),
            Text("No Conversations", style: TextStyle(fontWeight: FontWeight.bold,  fontSize: 20),),
            Spacer(flex: 1,)
          ],
        ),
      );
    }
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions

    List<ContactUser> suggestion = [];
    final String contactsString = LocalData.getString(
        "conversation_list");
    final List<ContactUser> users =
    ContactUser.decode(contactsString);
    query.isEmpty ? suggestion = users : suggestion.addAll(users.where((user) =>
        user.name.toLowerCase().contains(query.toLowerCase())
    ));
    if(suggestion.length != 0) {
      return ListView.builder(

          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          primary: false,
          itemCount: suggestion.length,
          itemBuilder: (context, index) {
            if (suggestion.length != 0) {
              return Column(
                children: [
                  ConversationCellWidget(
                      contactUser: ContactUser(
                        imageUrl: suggestion[index].imageUrl,

                        id: suggestion[index].id,
                        name: suggestion[index].name,
                        description: suggestion[index].description,
                        lastOnline: suggestion[index].lastOnline,
                      )),
                  Divider(height: 1, indent: 65,)
                ],
              );
            } else {
              return Center();
            }
            return Center();
          });
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 1,),
            Icon(Icons.announcement_rounded,size: 30),
            SizedBox(height: 5,),
            Text("No Conversations", style: TextStyle(fontWeight: FontWeight.bold,  fontSize: 20),),
            Spacer(flex: 1,)
          ],
        ),
      );
    }
    throw UnimplementedError();
  }
  
}