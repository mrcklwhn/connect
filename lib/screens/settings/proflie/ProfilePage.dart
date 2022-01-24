import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sliding_switch/sliding_switch.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final Function onMenuTap;

  const ProfilePage({
    Key key,
    this.onMenuTap,
  }) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File image;

  String prevDescription = "";
  String prevName = "";
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isOnline = false;

  Future<void> loadDescription() async {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Information")
        .get()
        .then((snapshot) {
      descriptionController.text = snapshot.get("description");
    });
  }

  Future<void> loadName() async {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Information")
        .get()
        .then((snapshot) {
      nameController.text = snapshot.get("name");
    });
  }

  Future<void> updateDescription(String description) async {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Information")
        .update({
      'description': description,
    }).asStream();
  }

  Future<void> updateUserName(String userName) async {
    final databaseReference = FirebaseFirestore.instance;

    databaseReference
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Information")
        .update({
      'name': userName.trim(),
    }).asStream();
  }

  Widget buildImage() {
    return FutureBuilder(
        future: _getStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (!"${snapshot.data['imageUrl']}".startsWith("default_image")) {
              return Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                            "${snapshot.data['imageUrl']}"))),
              );
            } else {
              return Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/images/user_icon_" +
                      "${snapshot.data['imageUrl']}".substring(
                          "${snapshot.data['imageUrl']}".length - 1) +
                      ".png"),
                )),
              );
            }
          }

          return Center();
        });
  }

  @override
  // ignore: must_call_super
  void initState() {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection(FirebaseAuth.instance.currentUser.displayName)
        .doc("Information")
        .get()
        .then((snapshot) {
      if (snapshot.get("lastOnline") == "online") {
        setState(() {
          isOnline = true;
        });
      } else {
        setState(() {
          isOnline = false;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadDescription();
      await loadName();
    });

    descriptionController.addListener(updateDescriptionListener);
    nameController.addListener(updateNameListener);

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

  void updateNameListener() {
    if (prevName == nameController.text || prevName == "") {
      updateUserName(nameController.text.trim());
    }
    setState(() {
      prevName = nameController.text.trim();
    });
  }

  void updateDescriptionListener() {
    if (prevDescription == descriptionController.text ||
        prevDescription == "") {
      updateDescription(descriptionController.text.trim());
    }
    setState(() {
      prevDescription = descriptionController.text.trim();
    });
  }

  Widget buildEditIcon() => InkWell(
        onTap: () async {
          try {
            final image =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            if (image == null) return;

            final tempImage = File(image.path);
            this.image = tempImage;

            File croppedImage = await ImageCropper.cropImage(
              sourcePath: tempImage.path,
              cropStyle: CropStyle.rectangle,
              aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            );
            await uploadImage(
                FirebaseAuth.instance.currentUser.displayName, croppedImage);
            CoolAlert.show(
                context: context,
                type: CoolAlertType.loading,
                text: "Uploading image...",
                autoCloseDuration: Duration(seconds: 1));
            setState(() {});
          } on PlatformException catch (e) {
            print("Failed to pick image:" + e.toString());
          }
        },
        child: Icon(
          Icons.add_a_photo_rounded,
          size: 30,
        ),
      );

  buildProfile() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 1.5,
                child: TextField(
                  controller: nameController,
                  maxLength: 20,
                  onChanged: (text) {
                    if (text.trim().length != 0) {
                      updateUserName(text);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "",
                    counterText: "",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                FirebaseAuth.instance.currentUser.displayName,
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
          SizedBox(
            height: 30,
          ),
          SlidingSwitch(
            value: isOnline ? true : false,
            width: 330,
            textOff: "Offline",
            textOn: "Online",
            colorOn: Colors.green,
            colorOff: Colors.red,
            background: Theme.of(context).backgroundColor,
            inactiveColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            onChanged: (bool value) {
              if (isOnline) {
                setState(() {
                  isOnline = false;
                  updateLastOnline(
                      FirebaseAuth.instance.currentUser.displayName, "offline");
                });
              } else {
                setState(() {
                  isOnline = true;
                  updateLastOnline(
                      FirebaseAuth.instance.currentUser.displayName, "online");
                });
              }
            },
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .1),
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: null,
                  maxLength: 100,
                  decoration: InputDecoration(
                    hintText: "Enter your description...",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: TextStyle(fontSize: 16, height: 1.4),
                )
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  bool isCollabsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          buildEditIcon(),
          SizedBox(
            width: 20,
          )
        ],
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: buildBody(),
    );
  }

  int currentIndex = 0;

  Future _getStream = FirebaseFirestore.instance
      .collection(FirebaseAuth.instance.currentUser.displayName)
      .doc("Information")
      .get();

  buildBody() {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
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
            SliverToBoxAdapter(
              child: buildProfile(),
            ),
          ],
        ));
  }
}
