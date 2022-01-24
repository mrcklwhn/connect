import 'package:connect/logic/data/Database.dart';
import 'package:connect/screens/groups/groupsListItem.dart';
import 'package:flutter/material.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({Key key}) : super(key: key);

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
      itemCount: 20,
      itemBuilder: (BuildContext context, int index) {
        return GroupsListItem();
      },
    ));
  }
}
