import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/data/Models.dart';

class RecentContacts {


  static Future<void> updateUserInformation() async {
    String conversationString = LocalData.getString(
        "contact_list");

    final List<ContactUser> users =
    ContactUser.decode(conversationString);

    for (int i = 0; i < users.length; i++) {
      FirebaseFirestore.instance.collection(users[i].id)
          .doc("Information")
          .get()
          .then((snapshot) {
        ContactUser newUser = ContactUser(
            name: getContactName(ContactUser(id: users[i].id)),
            imageUrl: snapshot.get("imageUrl"),
            id: users[i].id,
            lastOnline: snapshot.get("lastOnline"),
            description: snapshot.get("description"));


        users.removeWhere((item) => item.id == users[i].id);
        users.add(newUser);


        //Speicher Pfad


          final String encodedData = ContactUser.encode(users);


          LocalData.putString("contact_list", encodedData);
      });
    }

  }
}