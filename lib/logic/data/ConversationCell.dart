import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Database.dart';
import 'LocalData.dart';

class ConversationCell {

  static String getLastMessageSentTime(String lastOnline) {
    String currentDate =
    formatDate(DateTime.now().toLocal(), [dd, '.', mm, '.', yy]);
    var date = lastOnline.split(" ");

    if (lastOnline.startsWith(currentDate)) {
      return date[1].trim();
    } else {
      return date[0].trim();
    }
  }

  static String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }

  static bool isArchived(ContactUser user) {
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

  static void pinUser(ContactUser user, Function update) {
    List<ContactUser> users = [];
    if (LocalData.exitsString("conversation_pinned")) {
      final String pinnedConversationsString =
      LocalData.getString("conversation_pinned");

      users = ContactUser.decode(pinnedConversationsString);
    }

    users.add(
      ContactUser(
          name: getContactName(ContactUser(id: user.id)),
          id: user.id,
          imageUrl: user.imageUrl,
          lastOnline: user.lastOnline,
          description: user.description),
    );
    final String encodedData = ContactUser.encode(users);

    //Speicher Pfad
    LocalData.putString("conversation_pinned", encodedData);
    update();
  }

  static void unPinUser(ContactUser user, Function update) async {
    List<ContactUser> users =
    ContactUser.decode(LocalData.getString("conversation_pinned"));
    users.removeWhere((item) => item.id == user.id);

    final String encodedData = ContactUser.encode(users);

    //Speicher Pfad
    LocalData.putString("conversation_pinned", encodedData);
    update();
  }



  static bool isPinned(ContactUser user) {
    if (LocalData.exitsString("conversation_pinned")) {
      List<ContactUser> archivedUsers =
      ContactUser.decode(LocalData.getString("conversation_pinned"));

      List<String> archivedUsersIds = [];

      for (int i = 0;
      i <
          ContactUser
              .decode(LocalData.getString("conversation_pinned"))
              .length;
      i++) {
        archivedUsersIds.add(archivedUsers[i].id);
      }
      if (archivedUsersIds.contains(user.id)) {
        return true;
      }
    }
    return false;

  }

  static void archiveUser(ContactUser user, Function update) async {



    final String pinnedConversationsString =
    LocalData.getString(
        "conversation_" + user.id);

    final List<Message> messages =
    Message.decode(pinnedConversationsString);
    if (LocalData.exitsString("conversation_archived")) {
      List<ContactUser> archivedUsers =
      ContactUser.decode(LocalData.getString("conversation_archived"));



      final String pinnedConversationsString =
      LocalData.getString(
          "conversation_" + user.id);

      final List<Message> messages =
      Message.decode(pinnedConversationsString);

      final databaseReference = FirebaseFirestore.instance;
      databaseReference
          .collection(user.id)
          .doc("Information")
          .get()
          .then((snapshot) {
        archivedUsers.add(
          ContactUser(
              name: getContactName(ContactUser(id: user.id)),
              id: user.id,
              imageUrl: snapshot.get("imageUrl"),
              lastOnline: snapshot.get("lastOnline"),
              description: snapshot.get("description")),
        );
        if (archivedUsers.length ==
            ContactUser.decode(LocalData.getString("conversation_archived")).length +
                1) {
          final String encodedData = ContactUser.encode(archivedUsers);

          //Speicher Pfad
          LocalData.putString("conversation_archived", encodedData);
          update();
        }
      });
    } else {
      List<ContactUser> archivedUsers = [];

      final databaseReference = FirebaseFirestore.instance;
      databaseReference
          .collection(user.id)
          .doc("Information")
          .get()
          .then((snapshot) async {

        archivedUsers.add(
          ContactUser(
              name: getContactName(ContactUser(id: user.id)),
              id: user.id,
              imageUrl: snapshot.get("imageUrl"),
              lastOnline: snapshot.get("lastOnline"),
              description: snapshot.get("description")),
        );

        final String encodedData = ContactUser.encode(archivedUsers);

        //Speicher Pfad
        LocalData.putString("conversation_archived", encodedData);
        update();
      });

    }

  }

  static void unArchiveUser(ContactUser user, Function update) async {
    List<ContactUser> archivedUsers =
    ContactUser.decode(LocalData.getString("conversation_archived"));
    archivedUsers.removeWhere((item) => item.id == user.id);

    final String encodedData = ContactUser.encode(archivedUsers);

    //Speicher Pfad
    LocalData.putString("conversation_archived", encodedData);
    update();
  }

  static void deleteConversation(ContactUser user, Function update) async {
    List<ContactUser> conversationsUser =
    ContactUser.decode(LocalData.getString("conversation_list"));
    conversationsUser.removeWhere((item) => item.id == user.id);

    final String encodedData = ContactUser.encode(conversationsUser);

    LocalData.clearString("conversation_" + user.id);


    //Speicher Pfad
    LocalData.putString("conversation_list", encodedData);
    deleteConversations(ContactUser(id: user.id));
    if(isPinned(user)) {
      unPinUser(user, update);
    }
    if(isArchived(user)){
      unArchiveUser(user, update);
    }
    update();
  }

  static void deleteConversations(ContactUser user) {
    FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Conversations")
        .collection("Conversations_Collection")
        .doc(user.id)
        .delete();
    FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Conversations")
        .collection("Conversations_Collection")
        .doc(user.id)
        .collection("Messages")
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }


}