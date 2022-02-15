import 'dart:async';
import 'package:src/blocs/auth/auth.bloc.dart';
import 'package:src/shared/custom_components.dart';
import 'package:src/shared/custom_style.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Records extends StatefulWidget {
  static const routeName = '/records';
  @override
  RecordsState createState() => RecordsState();
}

class RecordsState extends State<Records> {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool spinnerVisible = false;
  bool messageVisible = false;
  bool isAdmin = false;
  String messageTxt = "";
  String messageType = "";
  String displayPage = "Vaccine";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    authBloc.dispose();
    super.dispose();
  }

  toggleSpinner() {
    setState(() => spinnerVisible = !spinnerVisible);
  }

  togglePage(String filter) {
    setState(() => displayPage = filter);
  }

  showMessage(bool msgVisible, msgType, message) {
    messageVisible = msgVisible;
    setState(() {
      messageType = msgType == "error"
          ? cMessageType.error.toString()
          : cMessageType.success.toString();
      messageTxt = message;
    });
  }

  getData(filter, docId) {
    Query qry;

    if (filter == "Vaccine")
      qry = authBloc.person.doc(docId).collection("Vaccine");
    if (filter == "OPD") qry = authBloc.person.doc(docId).collection("OPD");
    if (filter == "Rx") qry = authBloc.person.doc(docId).collection("Rx");
    if (filter == "Lab") qry = authBloc.person.doc(docId).collection("Lab");
    if (filter == "Messages")
      qry = authBloc.person.doc(docId).collection("Messages");
    if (filter == "Person")
      qry = authBloc.person.where("author", isEqualTo: docId);

    return qry.limit(10).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(title: const Text(cPRecords,style: TextStyle(color: bgcolor),),backgroundColor: butcolor,iconTheme: IconThemeData(color: bgcolor),),
      drawer: Drawer(child: CustomGuestDrawer()),
      body: ListView(
        children: [
          Center(
            child: Container(
                width: 600,
                height: 600,
                margin: EdgeInsets.all(20.0),
                child: authBloc.isSignedIn()
                    ? settings(authBloc)
                    : loginPage(authBloc)),
          )
        ],
      ),
    );
  }

  Widget loginPage(AuthBloc authBloc) {
    return Column(
      children: [
        SizedBox(width: 10, height: 50),
        ElevatedButton(
          child: Text('Click here to go to Login page'),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              '/login',
            );
          },
        )
      ],
    );
  }

  Widget settings(AuthBloc authBloc) {
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 25.0),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: Icon(Icons.settings, color: Colors.blue),
                  onPressed: null),
              Text("Past Visit Records", style: cHeaderDarkText),
              SizedBox(
                width: 5,
                height: 5,
              ),
              IconButton(
                  icon: Icon(Icons.healing_rounded, color: Colors.green),
                  onPressed: () {
                    togglePage("Vaccine");
                  }),
              IconButton(
                  icon: Icon(Icons.person, color: Colors.blueGrey),
                  onPressed: () {
                    togglePage("Person");
                  }),
              IconButton(
                  icon: Icon(Icons.view_headline, color: Colors.greenAccent),
                  onPressed: () {
                    togglePage("OPD");
                  }),
              IconButton(
                  icon: Icon(Icons.hot_tub, color: Colors.red),
                  onPressed: () {
                    togglePage("Rx");
                  }),
              IconButton(
                  icon: Icon(Icons.sanitizer, color: Colors.orangeAccent),
                  onPressed: () {
                    togglePage("Lab");
                  }),
              IconButton(
                  icon: Icon(Icons.sms, color: Colors.deepPurple),
                  onPressed: () {
                    togglePage("Messages");
                  }),
            ],
          ),
          SizedBox(
            width: 10,
            height: 20,
          ),
          Container(
              width: 600,
              height: 400,
              child: displayPage == "Vaccine"
                  ? showVaccineHistory(context, authBloc)
                  : (displayPage == "Person")
                      ? showPersonHistory(context, authBloc)
                      : (displayPage == "OPD")
                          ? showOPDHistory(context, authBloc)
                          : (displayPage == "Rx")
                              ? showRxHistory(context, authBloc)
                              : (displayPage == "Lab")
                                  ? showLabHistory(context, authBloc)
                                  : showMessagesHistory(context, authBloc)),
        ],
      ),
    );
  }

  Widget showVaccineHistory(BuildContext context, AuthBloc authBloc) {
    return StreamBuilder<QuerySnapshot>(
        stream: getData("Vaccine", auth.currentUser.uid),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(
              'no past Records available.',
              style: cErrorText,
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return new ListTile(
                title: Row(
                  children: [
                    Text(
                      "Past Vaccine Record:",
                      style: cNavRightText,
                    ),
                  ],
                ),
                subtitle: Column(
                  children: [
                    const Divider(
                      color: Colors.white,
                      height: 5,
                      thickness: 2,
                    ),
                    Row(
                      children: [
                        new Text("Appointment Date: ",style: TextStyle(color: Colors.white),),
                        new Text(document.get('appointmentDate'),style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("Next Appointment: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('newAppointmentDate'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        });
  }

  Widget showPersonHistory(BuildContext context, AuthBloc authBloc) {
    return StreamBuilder<QuerySnapshot>(
        stream: getData("Person", auth.currentUser.uid),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(
              'no past Records available.',
              style: cErrorText,
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return new ListTile(
                title: Row(
                  children: [
                    Text(
                      "Person Record:",
                      style: cNavRightText,
                    ),
                  ],
                ),
                subtitle: Column(
                  children: [
                    const Divider(
                      color: Colors.white,
                      height: 5,
                      thickness: 2,
                      // indent: 20,
                      // endIndent: 0,
                    ),
                    Row(
                      children: [
                        new Text("Name: ",style: TextStyle(color: Colors.white),),
                        new Text(document.get('name'),style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("Address: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('address'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("Id: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('id'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("ID Type: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('idType'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("DOB: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('dob'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("Medical History: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('medicalHistory'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        });
  }

  Widget showOPDHistory(BuildContext context, AuthBloc authBloc) {
    return StreamBuilder<QuerySnapshot>(
        stream: getData("OPD", auth.currentUser.uid),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(
              'no past Records available.',
              style: cErrorText,
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading",style: TextStyle(color: Colors.white),);
          }

          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return new ListTile(
                title: Row(
                  children: [
                    Text(
                      "Past OPD Record:",
                      style: cNavRightText,
                    ),
                  ],
                ),
                subtitle: Column(
                  children: [
                    new Text(document.get('opdDate').toDate().toString(),style: TextStyle(color: Colors.tealAccent),),
                    const Divider(
                      color: Colors.white,
                      height: 5,
                      thickness: 2,
                      // indent: 20,
                      // endIndent: 0,
                    ),
                    Row(
                      children: [
                        new Text("Symptoms: ",style: TextStyle(color: Colors.white),),
                        new Text(document.get('symptoms'),style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("Diagnosis: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('diagnosis'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("Rx: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('rx'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("Lab: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('lab'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("Treatment: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('treatment'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        });
  }

  Widget showRxHistory(BuildContext context, AuthBloc authBloc) {
    return StreamBuilder<QuerySnapshot>(
        stream: getData("Rx", auth.currentUser.uid),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(
              'no past Records available.',
              style: cErrorText,
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return new ListTile(
                title: Row(
                  children: [
                    Text(
                      "Past Rx Record:",
                      style: cNavRightText,
                    ),
                  ],
                ),
                subtitle: Column(
                  children: [
                    new Text(document.get('rxDate').toDate().toString(),style: TextStyle(color: Colors.tealAccent),),
                    const Divider(
                      color: Colors.white,
                      height: 5,
                      thickness: 2,
                      // indent: 20,
                      // endIndent: 0,
                    ),
                    Row(
                      children: [
                        new Text("From: ",style: TextStyle(color: Colors.white),),
                        new Text(document.get('from'),style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("Status: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('status'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("Pharmacy: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('rx'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("Results: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('results'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        });
  }

  Widget showLabHistory(BuildContext context, AuthBloc authBloc) {
    return StreamBuilder<QuerySnapshot>(
        stream: getData("Lab", auth.currentUser.uid),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(
              'no past Records available.',
              style: cErrorText,
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return new ListTile(
                title: Row(
                  children: [
                    Text(
                      "Past Lab Record:",
                      style: cNavRightText,
                    ),
                  ],
                ),
                subtitle: Column(
                  children: [
                    new Text(document.get('labDate').toDate().toString(),style: TextStyle(color: Colors.tealAccent),),
                    const Divider(
                      color: Colors.white,
                      height: 5,
                      thickness: 2,
                      // indent: 20,
                      // endIndent: 0,
                    ),
                    Row(
                      children: [
                        new Text("From: ",style: TextStyle(color: Colors.white),),
                        new Text(document.get('from'),style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("Status: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('status'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("Pathology: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('lab'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("Results: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('results'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        });
  }

  Widget showMessagesHistory(BuildContext context, AuthBloc authBloc) {
    return StreamBuilder<QuerySnapshot>(
        stream: getData("Vaccine", auth.currentUser.uid),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(
              'no past Records available.',
              style: cErrorText,
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading",style: TextStyle(color: Colors.white),);
          }

          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return new ListTile(
                title: Row(
                  children: [
                    Text(
                      "Message Record:",
                      style: cNavRightText,
                    ),
                  ],
                ),
                subtitle: Column(
                  children: [
                    const Divider(
                      color: Colors.white,
                      height: 5,
                      thickness: 2,
                      // indent: 20,
                      // endIndent: 0,
                    ),
                    Row(
                      children: [
                        new Text("Appointment Date: ",style: TextStyle(color: Colors.white),),
                        new Text(document.get('appointmentDate'),style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text("Next Appointment: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('newAppointmentDate'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        });
  }
}
