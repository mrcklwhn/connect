import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/conversations/conversation/OtherUserProfile.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/Encryption.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/contacts/AddContactPage.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encryption;

// ignore: must_be_immutable
class OtherUserProfilePage extends StatefulWidget {
  ContactUser contactUser;
  Function updateParent;
  OtherUserProfilePage({@required this.contactUser, this.updateParent});

  @override
  _OtherUserProfilePageState createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  String prevNotes = "";
  String prevName = "";

  final notesController = TextEditingController();

  final nameController = TextEditingController();

  updateParent() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text(
            "Information",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          actions: widget.contactUser.name == widget.contactUser.id
              ? [
                  InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Add_Contact_Page(
                            updateParent: updateParent,
                            id: widget.contactUser.id,
                            imageUrl: widget.contactUser.imageUrl,
                          );
                        }));
                      },
                      child: Icon(Icons.person_add)),
                  SizedBox(
                    width: 20,
                  )
                ]
              : [],
        ),
        body: buildBody());
  }

  Widget buildImage() {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection(widget.contactUser.id)
            .doc("Settings")
            .get(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.get("Privacy.Activity.Show_Profile_Picture")) {
              if (!widget.contactUser.imageUrl.startsWith("default_image")) {
                return Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                              widget.contactUser.imageUrl))),
                );
              } else {
                return Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/user_icon_" +
                              widget.contactUser.imageUrl.substring(
                                  widget.contactUser.imageUrl.length - 1) +
                              ".png"))),
                );
              }
            }
          }
          return Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/user_icon_" +
                        widget.contactUser.imageUrl
                            .substring(widget.contactUser.imageUrl.length - 1) +
                        ".png"))),
          );
        });
  }

  Widget nameField() {
    if (widget.contactUser.id == widget.contactUser.name) {
      return Text(
        widget.contactUser.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width / 1.5,
        child: TextField(
          controller: nameController,
          maxLength: 15,
          decoration: InputDecoration(
            hintText: "Enter name...",
            counterText: "",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          textAlign: TextAlign.center,
          onChanged: (text) {
            if (text.trim() != "") {
              OtherUserProfile.changeUserName(widget.contactUser, text.trim());
            }
          },
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      );
    }
  }

  Future<void> loadNotes() async {
    final databaseReference = await FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Conversations")
        .collection("Conversations_Collection")
        .doc(widget.contactUser.id)
        .get();
    if (databaseReference.data().containsKey("notes")) {
      setState(() {
        notesController.text = Encryption().decrypt(
            databaseReference.get("notes"),
            Encryption()
                .parsePrivateKeyFromPem(LocalData.getString("privateKey")));
      });
    } else {
      notesController.text = "";
    }
  }

  Future<void> loadName() async {
    if (widget.contactUser.id != widget.contactUser.name) {
      List<ContactUser> users =
          ContactUser.decode(LocalData.getString("contact_list"));
      int index = users.indexOf(
          users.firstWhere((item) => item.id == widget.contactUser.id));
      nameController.text = users[index].name;
    }
  }

  @override
  // ignore: must_call_super
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadNotes();
      await loadName();
    });

    notesController.addListener(updateNotesListener);
    nameController.addListener(updateNameListener);
  }

  void updateNameListener() {
    if (prevName == nameController.text || prevName == "") {
      if (nameController.text.trim() != "") {
        OtherUserProfile.changeUserName(
            widget.contactUser, nameController.text.trim());
      }
    }
    setState(() {
      prevName = nameController.text.trim();
    });
  }

  void updateNotesListener() {
    if (prevNotes == notesController.text || prevNotes == "") {
      if (notesController.text.trim() != "") {
        OtherUserProfile.updateNotes(
            ContactUser(id: FirebaseAuth.instance.currentUser.displayName),
            ContactUser(id: widget.contactUser.id),
            notesController.text.trim());
        OtherUserProfile.updateNotes(
            ContactUser(id: widget.contactUser.id),
            ContactUser(id: FirebaseAuth.instance.currentUser.displayName),
            notesController.text.trim());
      }
    }
    setState(() {
      prevNotes = notesController.text;
    });
  }

  buildProfile() {
    return Container(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.transparent,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            nameField(),
            Column(
              children: [
                const SizedBox(height: 4),
                FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection(widget.contactUser.id)
                        .doc("Information")
                        .get(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          widget.contactUser.id == widget.contactUser.name
                              ? "~ " + snapshot.data.get("name")
                              : widget.contactUser.id,
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      return Center();
                    }),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * .1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Theme.of(context).backgroundColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection(widget.contactUser.id)
                                .doc("Settings")
                                .get(),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data
                                    .get("Privacy.Activity.Show_Description")) {
                                  return Text(
                                    widget.contactUser.description,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  );
                                }
                              }
                              return Text(
                                "This user has hidden their description from you!",
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Theme.of(context).backgroundColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: notesController,
                          maxLines: null,
                          maxLength: 100,
                          decoration: InputDecoration(
                            hintText: "Enter your notes...",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          style: TextStyle(fontSize: 16, height: 1.4),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Theme.of(context).backgroundColor),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.photo_library_rounded),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Images',
                          style: TextStyle(
                              fontSize: 21, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          CoolAlert.show(
                              context: context,
                              type: CoolAlertType.confirm,
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              confirmBtnColor: Colors.indigoAccent,
                              confirmBtnText: "Clear",
                              cancelBtnText: "Cancel",
                              title: "Clear Conversation!",
                              text:
                                  "Do you want to delete all conversation of this Conversation?",
                              onConfirmBtnTap: () {
                                LocalData.clearString(
                                    "conversation_" + widget.contactUser.id);
                                Navigator.pop(context);
                              });
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width * .5 -
                                  (MediaQuery.of(context).size.width * .1)) -
                              10,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: Colors.indigoAccent),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.auto_delete, color: Colors.white),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Clear',
                                style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      InkWell(
                        onTap: () {
                          CoolAlert.show(
                              context: context,
                              type: CoolAlertType.confirm,
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              confirmBtnColor: Colors.red,
                              confirmBtnText: "Delete",
                              cancelBtnText: "Cancel",
                              title: "Delete Conversation!",
                              text: "Do you want to delete this Conversation?",
                              onConfirmBtnTap: () {
                                void deleteConversations() {
                                  FirebaseFirestore.instance
                                      .collection(FirebaseAuth
                                          .instance.currentUser.displayName)
                                      .doc("Conversations")
                                      .collection("Conversations_Collection")
                                      .doc(widget.contactUser.id)
                                      .delete();
                                  FirebaseFirestore.instance
                                      .collection(FirebaseAuth
                                          .instance.currentUser.displayName)
                                      .doc("Conversations")
                                      .collection("Conversations_Collection")
                                      .doc(widget.contactUser.id)
                                      .collection("Messages")
                                      .get()
                                      .then((snapshot) {
                                    for (DocumentSnapshot ds in snapshot.docs) {
                                      ds.reference.delete();
                                    }
                                  });
                                }

                                void deleteConversation(
                                    ContactUser user) async {
                                  List<ContactUser> conversationsUser =
                                      ContactUser.decode(LocalData.getString(
                                          "conversation_list"));
                                  conversationsUser.removeWhere(
                                      (item) => item.id == user.id);

                                  final String encodedData =
                                      ContactUser.encode(conversationsUser);

                                  LocalData.clearString(
                                      "conversation_" + user.id);

                                  //Speicher Pfad
                                  LocalData.putString(
                                      "conversation_list", encodedData);
                                  void pinUser(ContactUser user) {
                                    List<ContactUser> users = [];
                                    if (LocalData.exitsString(
                                        "conversation_pinned")) {
                                      final String pinnedConversationsString =
                                          LocalData.getString(
                                              "conversation_pinned");

                                      users = ContactUser.decode(
                                          pinnedConversationsString);
                                    }

                                    users.add(
                                      ContactUser(
                                          name: getContactName(ContactUser(
                                              id: widget.contactUser.id)),
                                          id: widget.contactUser.id,
                                          imageUrl: widget.contactUser.imageUrl,
                                          lastOnline:
                                              widget.contactUser.lastOnline,
                                          description:
                                              widget.contactUser.description),
                                    );
                                    final String encodedData =
                                        ContactUser.encode(users);

                                    //Speicher Pfad
                                    LocalData.putString(
                                        "conversation_pinned", encodedData);
                                  }

                                  void unArchiveUser(ContactUser user) async {
                                    List<ContactUser> archivedUsers =
                                        ContactUser.decode(LocalData.getString(
                                            "conversation_archived"));
                                    archivedUsers.removeWhere(
                                        (item) => item.id == user.id);

                                    final String encodedData =
                                        ContactUser.encode(archivedUsers);

                                    //Speicher Pfad
                                    LocalData.putString(
                                        "conversation_archived", encodedData);
                                  }

                                  void unPinUser(ContactUser user) async {
                                    List<ContactUser> users =
                                        ContactUser.decode(LocalData.getString(
                                            "conversation_pinned"));
                                    users.removeWhere(
                                        (item) => item.id == user.id);

                                    final String encodedData =
                                        ContactUser.encode(users);

                                    //Speicher Pfad
                                    LocalData.putString(
                                        "conversation_pinned", encodedData);
                                  }

                                  bool isPinned(ContactUser user) {
                                    if (LocalData.exitsString(
                                        "conversation_pinned")) {
                                      List<ContactUser> archivedUsers =
                                          ContactUser.decode(
                                              LocalData.getString(
                                                  "conversation_pinned"));

                                      List<String> archivedUsersIds = [];

                                      for (int i = 0;
                                          i <
                                              ContactUser.decode(
                                                      LocalData.getString(
                                                          "conversation_pinned"))
                                                  .length;
                                          i++) {
                                        archivedUsersIds
                                            .add(archivedUsers[i].id);
                                      }
                                      if (archivedUsersIds.contains(user.id)) {
                                        return true;
                                      }
                                    }
                                    return false;
                                  }

                                  deleteConversations();
                                  if (isPinned(user)) {
                                    unPinUser(user);
                                  }

                                  if (OtherUserProfile.isArchived(user)) {
                                    unArchiveUser(user);
                                  }
                                }

                                deleteConversation(widget.contactUser);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              });
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width * .5 -
                                  (MediaQuery.of(context).size.width * .1)) -
                              10,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: Colors.red),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.delete, color: Colors.white),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Delete',
                                style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  buildBody() {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: MediaQuery.of(context).size.width - 120,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: [StretchMode.zoomBackground],
                  collapseMode: CollapseMode.parallax,
                  background: buildImage(),
                ),
              ),
              SliverToBoxAdapter(child: buildProfile()),
            ],
          ),
        ));
  }
}
