import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Contacts.dart';

class Add_Contact_Page extends StatefulWidget {

  final String id ;
  final String imageUrl;
  final Function updateParent;
  const Add_Contact_Page({Key key, this.id, this.imageUrl, this.updateParent
  }) : super(key: key);

  @override
  _Add_Contact_PageState createState() => _Add_Contact_PageState();
}

// ignore: camel_case_types
class _Add_Contact_PageState extends State<Add_Contact_Page> {


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  final _firstNameController = TextEditingController();

  final _lastNameController = TextEditingController();

  final _idController = TextEditingController();




  buildLowerPart() {

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40)),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40,),
                _buildId(),
                SizedBox(height: 30,),
                _buildFirstName(),
                SizedBox(height: 20,),
                _buildLastName(),
                SizedBox(height: MediaQuery.of(context).size.height*0.1,),
                _buildButton(),
                SizedBox(height: 40,),

              ],
            )),
      ),
    );

  }

  Widget _buildId() {
    return Container(
    width: MediaQuery.of(context).size.width-MediaQuery.of(context).size.width*.5,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(20))),
    child: TextFormField(
      enabled: widget.id != null ? false: true,
      onChanged: (idText) async {
        if(idText.length == 18) {
          final databaseReference =
          await FirebaseFirestore.instance.collection(idText).get();
          final docReference =
          await FirebaseFirestore.instance.collection(idText).doc("Information").get();
          if (databaseReference != null || databaseReference.size != 0) {
            String newUrl = docReference.get("imageUrl");
            print(newUrl);
            setState(() {
              this.imageUrl = newUrl;
            });
          }
        } else {
          setState(() {
            this.imageUrl = null;
          });
        }
      },

      style: TextStyle(color: Colors.grey),
      controller: _idController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        new LengthLimitingTextInputFormatter(12),
        new NumberFormatter()
      ],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: 'XXXX - XXXX - XXXX',
        border: InputBorder.none,
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter ID';
        }

        return null;
      },
      onSaved: (String value) {
      },
    ),
      );
  }

  Widget _buildFirstName() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: TextFormField(
        enabled: imageUrl == null ? false : true,
        style: TextStyle(color: Colors.grey),
        controller: _firstNameController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: 'First Name',
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.visiblePassword,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Please enter First Name'
                ;
          }

          return null;
        },
        onSaved: (String value) {
        },
      ),
    );
  }

  Widget _buildLastName() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: TextFormField(
        enabled: imageUrl == null ? false : true,
        style: TextStyle(color: Colors.grey),
        controller: _lastNameController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: 'Last Name',
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.visiblePassword,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Please enter Last Name'
            ;
          }

          return null;
        },
        onSaved: (String value) {
        },
      ),
    );
  }


  Widget _buildButton() {
    return RaisedButton(
      onPressed: () async {
        if(LocalData.exitsString("contact_list")) {
          final String contactsString =
          LocalData.getString("contact_list");

          final List<ContactUser> users =
          ContactUser.decode(contactsString);
          List<String> userIds = [];
          for (int i = 0 ; i < users.length; i++) {
            userIds.add(users[i].id);
          }

            final databaseReference = await FirebaseFirestore
                .instance
                .collection(_idController.text.toString())
                .get();
            if(_firstNameController.text.isNotEmpty && _firstNameController.text.trim().length != 0) {
              if (databaseReference.docs.length != 0 ||
                  databaseReference.size != 0) {
                if (!userIds.contains(_idController.text.toString())) {
                  addContact(ContactUser(name: _firstNameController.text.trim() + " " +
                      _lastNameController.text.trim(), id: _idController.text, imageUrl: await getImageUrl(ContactUser(id: _idController.text)), lastOnline: await getLastOnline(ContactUser(id: _idController.text)), description: await getDescription(ContactUser(id: _idController.text))));
                  widget.updateParent();
                  Navigator.pop(context,
                      MaterialPageRoute(builder: (_) {
                        return ContactsPage();
                      }));
                } else {
                  CoolAlert.show(
                    context: context,
                    type: CoolAlertType.error,
                    backgroundColor: Theme
                        .of(context)
                        .backgroundColor,
                    confirmBtnColor: Colors.indigoAccent,
                    confirmBtnText: "Dismiss",
                    title: "Unable to save Contact!",
                    text: "You already have saved this user to your Contacts!",
                  );
                }
              } else {
                CoolAlert.show(
                  context: context,
                  type: CoolAlertType.error,
                  backgroundColor: Theme
                      .of(context)
                      .backgroundColor,
                  confirmBtnColor: Colors.indigoAccent,
                  confirmBtnText: "Dismiss",
                  title: "Unable to save Contact!",
                  text: "The ID you entered does not exits!",
                );
              }
            } else {
              CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                backgroundColor: Theme
                    .of(context)
                    .backgroundColor,
                confirmBtnColor: Colors.indigoAccent,
                confirmBtnText: "Dismiss",
                title: "Unable to save Contact!",
                text: "You have to enter a name first!",
              );
            }
        }else {
          final databaseReference = await FirebaseFirestore
              .instance
              .collection(_idController.text.toString())
              .get();
          if(_firstNameController.text.isNotEmpty && _firstNameController.text.trim().length != 0) {
            if (databaseReference.docs.length != 0 ||
                databaseReference.size != 0) {
              addContact(ContactUser(name: _firstNameController.text.trim() + " " +
                  _lastNameController.text.trim(), id: _idController.text, imageUrl: await getImageUrl(ContactUser(id: _idController.text)), lastOnline: await getLastOnline(ContactUser(id: _idController.text)), description: await getDescription(ContactUser(id: _idController.text))));
              widget.updateParent();
              Navigator.pop(context,
                    MaterialPageRoute(builder: (_) {
                      return ContactsPage();
                    }));

            } else {
              CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                backgroundColor: Theme
                    .of(context)
                    .backgroundColor,
                confirmBtnColor: Colors.indigoAccent,
                confirmBtnText: "Dismiss",
                title: "Unable to save Contact!",
                text: "The ID you entered does not exits!",
              );
            }
          } else {
            CoolAlert.show(
              context: context,
              type: CoolAlertType.error,
              backgroundColor: Theme
                  .of(context)
                  .backgroundColor,
              confirmBtnColor: Colors.indigoAccent,
              confirmBtnText: "Dismiss",
              title: "Unable to save Contact!",
              text: "You have to enter a name first!",
            );
          }
        }
      },
      color: Colors.indigoAccent,
      elevation: 0,
      padding: EdgeInsets.all(18),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      child: Center(
          child: Text(
            "Save",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      if(widget.id != null) {
        imageUrl = widget.imageUrl;
        _idController.text = widget.id;
      }
    });
  }

  buildBody() {


    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.white,

          child: CustomScrollView(

            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: MediaQuery.of(context).size.width-120,
                stretch: true,

                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: [
                    StretchMode.zoomBackground
                  ],
                  collapseMode: CollapseMode.parallax,
                  background: buildImage(),
                ),
              ),
              SliverToBoxAdapter(

                  child: buildLowerPart()
              ),
            ],
          ),
        )
    );
  }

  String imageUrl;

  Widget buildImage () {


      if(imageUrl == null) {
        return Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/images/user_icon_4.png")
              )),
        );
      }else {
        if(imageUrl.startsWith("default_image")) {
          return Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/user_icon_" + imageUrl.substring(imageUrl.length-1) + ".png"),
                )),
          );
        } else {
    return Container(
    decoration: BoxDecoration(
    image: DecorationImage(
    fit: BoxFit.cover,
    image: CachedNetworkImageProvider(imageUrl)
    )),
    );
    }
      }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("New Contact", style: TextStyle(fontWeight: FontWeight.bold),),
          backgroundColor: Theme.of(context).backgroundColor,),

        body: buildBody()
    );
  }
}
class NumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i+1;
      if (nonZeroIndex <= 4) {
        if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
          buffer.write(' - '); // Add double spaces.
        }
      } else {
        if (nonZeroIndex % 8 == 0 && nonZeroIndex != text.length) {
          buffer.write(' - '); // Add double spaces.
        }
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}
