import 'package:flutter/material.dart';

class GroupsListItem extends StatelessWidget {
  const GroupsListItem({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10, top: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                    ),
                    Container(
                      width: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Group Name",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          height: 5,
                        ),
                        Text("last message"),
                      ],
                    ),
                  ],
                ),
                Text("Date"),
              ],
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
