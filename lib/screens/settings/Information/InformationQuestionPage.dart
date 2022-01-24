import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/Messaging.dart';
import 'package:connect/logic/settings/Information/InformationQuestion.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InformationQuestionsPage extends StatefulWidget {
  final int currentIndex;

  final Function onChangeIndex;

  const InformationQuestionsPage({Key key, this.currentIndex, this.onChangeIndex})
      : super(key: key);

  @override
  _InformationQuestionsPageState createState() => _InformationQuestionsPageState();
}

class _InformationQuestionsPageState extends State<InformationQuestionsPage>
    with TickerProviderStateMixin {
  AnimationController _controllerAnswered;
  AnimationController _controllerPending;
  AnimationController _controllerSupport;
  TextEditingController questionController = new TextEditingController();
  List<TextEditingController> supportAnswerControllerList = [];
  bool _expandedSupport = false;
  bool _expandedAnswered = false;
  bool _expandedPending = false;



  Widget rotateArrow(String type) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 0.5).animate(type == "pending"
          ? _controllerPending
          : type == "support"
              ? _controllerSupport
              : _controllerAnswered),
      child: IconButton(
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: () {
          setState(() {
            if (type == "pending") {
              if (_expandedPending) {
                _controllerPending..reverse(from: 0.5);
              } else {
                _controllerPending..forward(from: 0.0);
              }
              _expandedPending = !_expandedPending;
            } else if (type == "answered") {
              if (_expandedAnswered) {
                _controllerAnswered..reverse(from: 0.5);
              } else {
                _controllerAnswered..forward(from: 0.0);
              }
              _expandedAnswered = !_expandedAnswered;
            } else if (type == "support") {
              if (_expandedSupport) {
                _controllerSupport..reverse(from: 0.5);
              } else {
                _controllerSupport..forward(from: 0.0);
              }
              _expandedSupport = !_expandedSupport;
            }
          });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _controllerAnswered = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      upperBound: 0.5,
    );
    _controllerSupport = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      upperBound: 0.5,
    );
    _controllerPending = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      upperBound: 0.5,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controllerSupport.dispose();
    _controllerAnswered.dispose();
    _controllerPending.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Ask a Question",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.transparent
                  : Colors.white,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * .3,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context).backgroundColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "How can we help you?",
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: questionController,
                        onChanged: (val) {
                          setState(() {});
                        },
                      ),
                      Spacer(),
                      _buildSendButton(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                AnimatedContainer(
                  curve: Curves.fastOutSlowIn,
                  duration: Duration(milliseconds: 500),
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context).backgroundColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection("Users_Questions")
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<DocumentSnapshot> _myDocCount =
                                  snapshot.data.docs;
                              int counter = 0;
                              for (int i = 0; i < _myDocCount.length; i++) {
                                if (snapshot.data.docs[i].get("sender") ==
                                        FirebaseAuth.instance.currentUser
                                            ?.displayName &&
                                    snapshot.data?.docs[i].get("supporter") !=
                                        "") {
                                  counter++;
                                }
                              }
                              return Row(
                                children: [
                                  Text(
                                    "Answered questions",
                                    style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  Text(
                                    counter.toString(),
                                    style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  counter == 0
                                      ? SizedBox(
                                          width: 20,
                                        )
                                      : Center(),
                                  counter != 0
                                      ? rotateArrow("answered")
                                      : Center(),
                                ],
                              );
                            }
                            return Text(
                              "Answered questions",
                              style: TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.bold),
                            );
                          }),
                      _expandedAnswered ? _buildAnsweredQuestions() : Center(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                AnimatedContainer(
                  curve: Curves.fastOutSlowIn,
                  duration: Duration(milliseconds: 500),
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context).backgroundColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection("Users_Questions")
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<DocumentSnapshot> _myDocCount =
                                  snapshot.data.docs;
                              int counter = 0;
                              for (int i = 0; i < _myDocCount.length; i++) {
                                if (snapshot.data.docs[i].get("sender") ==
                                        FirebaseAuth
                                            .instance.currentUser.displayName &&
                                    snapshot.data.docs[i].get("supporter") ==
                                        "") {
                                  counter++;
                                }
                              }
                              return Row(
                                children: [
                                  Text(
                                    "Pending questions",
                                    style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  Text(
                                    counter.toString(),
                                    style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  counter == 0
                                      ? SizedBox(
                                          width: 20,
                                        )
                                      : Center(),
                                  counter != 0
                                      ? rotateArrow("pending")
                                      : Center(),
                                ],
                              );
                            }
                            return Text(
                              "Pending questions",
                              style: TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.bold),
                            );
                          }),
                      _expandedPending ? _buildPendingQuestions() : Center(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                _buildSupporterQuestions(),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildAnsweredQuestions() {
    return FutureBuilder(
        future: FirebaseFirestore.instance.collection("Users_Questions").get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> _myDocCount = snapshot.data.docs;
            int counter = 0;
            for (int i = 0; i < _myDocCount.length; i++) {
              if (snapshot.data.docs[i].get("sender") ==
                      FirebaseAuth.instance.currentUser.displayName &&
                  snapshot.data.docs[i].get("supporter") != "") {
                counter++;
              }
            }
            return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: _myDocCount.length,
                itemBuilder: (context, index) {
                   if (snapshot.data.docs[index].get("sender") ==
                      FirebaseAuth.instance.currentUser.displayName &&
                  snapshot.data.docs[index].get("supporter") != "") {
                  return Container(
                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data.docs[index].get("question"),
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          snapshot.data.docs[index].get("answer"),
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Divider(
                          height: 5,
                          endIndent: 150,
                          thickness: 2,
                        ),
                        Text(
                          "by " + snapshot.data.docs[index].get("supporter"),
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).backgroundColor
                            : Colors.white),
                  );
                  }
                  return Center();
                });
            return Text(counter.toString());
          }
          return Center();
        });
  }

  Widget _buildPendingQuestions() {
    return FutureBuilder(
        future: FirebaseFirestore.instance.collection("Users_Questions").get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> _myDocCount = snapshot.data.docs;
            int counter = 0;
            for (int i = 0; i < _myDocCount.length; i++) {
              if (snapshot.data.docs[i].get("sender") ==
                      FirebaseAuth.instance.currentUser.displayName &&
                  snapshot.data.docs[i].get("supporter") == "") {
                counter++;
              }
            }
            return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: _myDocCount.length,
                itemBuilder: (context, index) {
                  if (snapshot.data.docs[index].get("sender") ==
                          FirebaseAuth.instance.currentUser.displayName &&
                      snapshot.data.docs[index].get("supporter") == "") {
                    return Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data.docs[index].get("question"),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Divider(
                            height: 5,
                            endIndent: 150,
                            thickness: 2,
                          ),
                          Text(
                            InformationQuestion.getLastOnline(
                                snapshot.data.docs[index].get("time")),
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).backgroundColor
                              : Colors.white),
                    );
                  }
                  return Center();
                });
            return Text(counter.toString());
          }
          return Center();
        });
  }

  Widget _buildSupporterQuestions() {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection(FirebaseAuth.instance.currentUser.displayName)
            .doc("Information")
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.get("supporter") == true) {
              return AnimatedContainer(
                curve: Curves.fastOutSlowIn,
                duration: Duration(milliseconds: 500),
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Theme.of(context).backgroundColor,
                ),
                child: FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection("Users_Questions")
                        .get(),
                    builder: (context, secSnapshot) {
                      if (secSnapshot.hasData) {
                        List<DocumentSnapshot> _myDocCount =
                            secSnapshot.data.docs;
                        int counter = 0;
                        for (int i = 0; i < _myDocCount.length; i++) {
                          if (secSnapshot.data.docs[i].get("supporter") == "" &&
                              secSnapshot.data.docs[i].get("sender") !=
                                  FirebaseAuth
                                      .instance.currentUser.displayName) {
                            //TextEditingController i = TextEditingController();
                            supportAnswerControllerList
                                .add(TextEditingController());

                            counter++;
                          }
                        }
                        return Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Asked questions",
                                  style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold),
                                ),
                                Spacer(),
                                Text(
                                  counter.toString(),
                                  style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold),
                                ),
                                counter == 0
                                    ? SizedBox(
                                        width: 20,
                                      )
                                    : Center(),
                                counter != 0
                                    ? rotateArrow("support")
                                    : Center(),
                              ],
                            ),
                            _expandedSupport
                                ? ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: _myDocCount.length,
                                    itemBuilder: (context, index) {
                                      if (secSnapshot.data.docs[index]
                                                  .get("supporter") ==
                                              "" &&
                                          secSnapshot.data.docs[index]
                                                  .get("sender") !=
                                              FirebaseAuth.instance.currentUser
                                                  .displayName) {
                                        return Column(
                                          children: [
                                            Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    secSnapshot.data.docs[index]
                                                        .get("question"),
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Divider(
                                                    height: 5,
                                                    endIndent: 150,
                                                    thickness: 1,
                                                  ),
                                                  Text(
                                                    InformationQuestion.getLastOnline(secSnapshot
                                                        .data.docs[index]
                                                        .get("time")),
                                                    style:
                                                        TextStyle(fontSize: 13),
                                                  ),
                                                  TextField(
                                                    controller:
                                                        supportAnswerControllerList[
                                                            index - 1],
                                                    onChanged: (val) {
                                                      setState(() {});
                                                    },
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  _buildAnswerButton(
                                                      secSnapshot
                                                          .data.docs[index].id,
                                                      index),
                                                ],
                                              ),
                                              padding: EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20)),
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Theme.of(context)
                                                          .backgroundColor
                                                      : Colors.white),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        );
                                      }
                                      return Center();
                                    })
                                : Center(),
                          ],
                        );
                        return Text(counter.toString());
                      }
                      return Center();
                    }),
              );
            } else {
              return Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Theme.of(context).backgroundColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Become a Supporter",
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    FirebaseAuth.instance.currentUser.emailVerified
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                size: 18,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text("Verified",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold))
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 18,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text("Not verified yet",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                    SizedBox(
                      height: 15,
                    ),
                    _buildEnrollButton(),
                  ],
                ),
              );
            }
          }
          return Center();
        });
  }

  Widget _buildEnrollButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          RaisedButton(
            onPressed: FirebaseAuth.instance.currentUser.emailVerified
                ? () {
              InformationQuestion.makeSupporter();

                    CoolAlert.show(
                        context: context,
                        type: CoolAlertType.success,
                        backgroundColor: Theme.of(context).backgroundColor,
                        confirmBtnColor: Colors.indigoAccent,
                        confirmBtnText: "Dismiss",
                        title: "Enrollment was submitted!",
                        text:
                            "We have forwarded your enrollment, you will shortly receive an answer from us!",
                        onConfirmBtnTap: () async {
                          Navigator.pop(context);
                        });
                  }
                : null,
            disabledColor: Colors.redAccent,
            color: Colors.indigoAccent,
            elevation: 0,
            padding: EdgeInsets.only(top: 15, bottom: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Center(
                child: Text(
              "Enroll",
              style: TextStyle(fontSize: 21, color: Colors.white),
            )),
          ),
          SizedBox(
            height: 15,
          ),
          Text("The processing time is 1-2 minutes on average!",
              style: TextStyle(fontSize: 14))
        ],
      ),
    );
  }


  Widget _buildAnswerButton(String docId, int index) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        disabledColor: Colors.grey,
        onPressed: !supportAnswerControllerList[index - 1].text.isEmpty
            ? () async {
                await InformationQuestion.updateQuestion(
                    docId, supportAnswerControllerList[index - 1].text);

                CoolAlert.show(
                    context: context,
                    type: CoolAlertType.success,
                    backgroundColor: Theme.of(context).backgroundColor,
                    confirmBtnColor: Colors.indigoAccent,
                    confirmBtnText: "Dismiss",
                    title: "Answer was submitted!",
                    text: "Thank you for taking care of user problems!",
                    onConfirmBtnTap: () {
                      Navigator.pop(context);
                    });
                setState(() {});
              }
            : null,
        color: Colors.indigoAccent,
        elevation: 0,
        padding: EdgeInsets.only(top: 15, bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Center(
            child: Text(
          "Answer",
          style: TextStyle(
              fontSize: 21,
              color: !supportAnswerControllerList[index - 1].text.isEmpty
                  ? Colors.white
                  : Colors.white),
        )),
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        disabledColor: Colors.grey,
        onPressed: !questionController.text.isEmpty
            ? () {
          InformationQuestion.addQuestion(FirebaseAuth.instance.currentUser.displayName,
                    questionController.text.toString(), context);
                questionController.clear();
                CoolAlert.show(
                    context: context,
                    type: CoolAlertType.success,
                    backgroundColor: Theme.of(context).backgroundColor,
                    confirmBtnColor: Colors.indigoAccent,
                    confirmBtnText: "Dismiss",
                    title: "Question was submitted!",
                    text:
                        "A supporter will shortly take care of the processing!",
                    onConfirmBtnTap: () async {
                      Navigator.pop(context);
                    });
              }
            : null,
        color: Colors.indigoAccent,
        elevation: 0,
        padding: EdgeInsets.only(top: 15, bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Center(
            child: Text(
          "Ask!",
          style: TextStyle(fontSize: 21, color: Colors.white),
        )),
      ),
    );
  }
}
