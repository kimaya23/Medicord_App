import 'dart:async';
import 'package:src/blocs/auth/auth.bloc.dart';
import 'package:src/shared/custom_components.dart';
import 'package:src/shared/custom_style.dart';
import 'package:src/models/datamodel.dart';
import 'package:src/blocs/validators.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Rx extends StatefulWidget {
  static const routeName = '/rx';
  @override
  RxState createState() => RxState();
}

class RxState extends State<Rx> {
  bool spinnerVisible = false;
  bool messageVisible = false;
  bool isAdmin = false;
  String messageTxt = "";
  String messageType = "";
  final _formKey = GlobalKey<FormState>();
  RxDataModel formData = RxDataModel();
  bool _btnEnabled = false;
  String displayPage = "DataEntry";
  TextEditingController _rxDate = new TextEditingController();
  TextEditingController _from = new TextEditingController();
  TextEditingController _status = new TextEditingController();
  TextEditingController _rx = new TextEditingController();
  TextEditingController _results = new TextEditingController();
  TextEditingController _descr = new TextEditingController();
  TextEditingController _comments = new TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => this.setPatientID());
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

  setPatientID() {
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;
    formData.patientId = args.patientID;
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

  Future setData(AuthBloc authBloc) async {
    toggleSpinner();
    messageVisible = true;
    await authBloc
        .setRxData(formData)
        .then((res) => {
              showMessage(true, "success",
                  "Data is saved. DO NOT click on SAVE Again. Rx Record is added. click on appointments now.")
            })
        .catchError((error) => {showMessage(true, "error", error.toString())});
    toggleSpinner();
  }

  Future<void> _deleteDoc(String patientId, String collID, String docId) async {
    toggleSpinner();
    messageVisible = true;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to mark this record? Record #: $docId')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                authBloc.person
                    .doc(patientId)
                    .collection(collID)
                    .doc(docId)
                    .delete()
                    .then((res) =>
                        {showMessage(true, "success", "Record Deleted.")})
                    .catchError((error) =>
                        {showMessage(true, "error", error.toString())});
                Navigator.of(context).pop();
                toggleSpinner();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                toggleSpinner();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;
    AuthBloc authBloc = AuthBloc();
    return new Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(title: const Text(cRxTitle,style: TextStyle(color: bgcolor),),backgroundColor: butcolor,iconTheme: IconThemeData(color: bgcolor),),
      drawer: Drawer(child: CustomAdminDrawer()),
      body: ListView(
        children: [
          Center(
            child: Container(
                width: 600,
                height: 800,
                margin: EdgeInsets.all(20.0),
                child: authBloc.isSignedIn()
                    ? displayPage == "DataEntry"
                        ? settings(authBloc, args.patientID)
                        : displayPage == "Vaccine"
                            ? showVaccineHistory(context, authBloc)
                            : (displayPage == "Person")
                                ? showPersonHistory(context, authBloc)
                                : (displayPage == "OPD")
                                    ? showOPDHistory(context, authBloc)
                                    : (displayPage == "Rx")
                                        ? showRxHistory(context, authBloc)
                                        : (displayPage == "Lab")
                                            ? showLabHistory(context, authBloc)
                                            : showMessagesHistory(
                                                context, authBloc)
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

  Widget settings(AuthBloc authBloc, String patientID) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () =>
          setState(() => _btnEnabled = _formKey.currentState.validate()),
      child: Center(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 25.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon: Icon(Icons.hot_tub, color: Colors.red),
                    onPressed: null),
                Text("Update Rx Data", style: cHeaderDarkText),
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
            SizedBox(width: 10, height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                signinSubmitBtn(context, authBloc),
                SizedBox(
                  width: 10,
                  height: 10,
                ),
                ElevatedButton(
                  child: Text('Back',style: TextStyle(color: bgcolor),),
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(butcolor)),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/appointments');
                  },
                ),
              ],
            ),
            SizedBox(
              width: 10,
              height: 10,
            ),
            CustomSpinner(toggleSpinner: spinnerVisible),
            CustomMessage(
                toggleMessage: messageVisible,
                toggleMessageType: messageType,
                toggleMessageTxt: messageTxt),
            Container(
                width: 300.0,
                margin: EdgeInsets.only(top: 25.0),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _from,
                  cursorColor: Colors.blueAccent,
                  keyboardType: TextInputType.name,
                  maxLength: 50,
                  obscureText: false,
                  onChanged: (value) => formData.from = value,
                  validator: evalName,
                  decoration: InputDecoration(
                    icon: Icon(Icons.dashboard,color: Colors.white,),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    hintText: 'From',
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    hintStyle: TextStyle(color: Colors.white24),
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: 'From *',
                    // errorText: snapshot.error,
                  ),
                )),
            Container(
                width: 300.0,
                margin: EdgeInsets.only(top: 25.0),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _status,
                  cursorColor: Colors.blueAccent,
                  keyboardType: TextInputType.name,
                  maxLength: 50,
                  obscureText: false,
                  onChanged: (value) => formData.status = value,
                  validator: evalName,
                  decoration: InputDecoration(
                    icon: Icon(Icons.dashboard,color: Colors.white,),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    hintText: 'Status',
                    labelText: 'Status *',
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    hintStyle: TextStyle(color: Colors.white24),
                    labelStyle: TextStyle(color: Colors.white),
                    // errorText: snapshot.error,
                  ),
                )),
            Container(
                width: 300.0,
                margin: EdgeInsets.only(top: 25.0),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _rx,
                  cursorColor: Colors.blueAccent,
                  keyboardType: TextInputType.name,
                  maxLength: 50,
                  obscureText: false,
                  onChanged: (value) => formData.rx = value,
                  validator: evalName,
                  decoration: InputDecoration(
                    icon: Icon(Icons.dashboard,color: Colors.white,),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    hintText: 'Pharmacy',
                    labelText: 'Pharmacy *',
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    hintStyle: TextStyle(color: Colors.white24),
                    labelStyle: TextStyle(color: Colors.white),
                    // errorText: snapshot.error,
                  ),
                )),
            Container(
                width: 300.0,
                margin: EdgeInsets.only(top: 25.0),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _results,
                  cursorColor: Colors.blueAccent,
                  keyboardType: TextInputType.name,
                  maxLength: 50,
                  obscureText: false,
                  onChanged: (value) => formData.results = value,
                  validator: evalName,
                  decoration: InputDecoration(
                    icon: Icon(Icons.dashboard,color: Colors.white,),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    hintText: 'Results',
                    labelText: 'Results *',
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    hintStyle: TextStyle(color: Colors.white24),
                    labelStyle: TextStyle(color: Colors.white),
                    // errorText: snapshot.error,
                  ),
                )),
            Container(
                width: 300.0,
                margin: EdgeInsets.only(top: 25.0),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _descr,
                  cursorColor: Colors.blueAccent,
                  keyboardType: TextInputType.name,
                  maxLength: 50,
                  obscureText: false,
                  onChanged: (value) => formData.descr = value,
                  validator: evalName,
                  decoration: InputDecoration(
                    icon: Icon(Icons.dashboard,color: Colors.white,),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    hintText: 'Description',
                    labelText: 'Description *',
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    hintStyle: TextStyle(color: Colors.white24),
                    labelStyle: TextStyle(color: Colors.white),
                    // errorText: snapshot.error,
                  ),
                )),
            Container(
                width: 300.0,
                margin: EdgeInsets.only(top: 25.0),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _comments,
                  cursorColor: Colors.blueAccent,
                  keyboardType: TextInputType.name,
                  maxLength: 50,
                  obscureText: false,
                  onChanged: (value) => formData.comments = value,
                  validator: evalName,
                  decoration: InputDecoration(
                    icon: Icon(Icons.dashboard,color: Colors.white,),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    hintText: 'Comments',
                    labelText: 'Comments *',
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    hintStyle: TextStyle(color: Colors.white24),
                    labelStyle: TextStyle(color: Colors.white),
                    // errorText: snapshot.error,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget showVaccineHistory(BuildContext context, AuthBloc authBloc) {
    return StreamBuilder<QuerySnapshot>(
        stream: getData("Vaccine", formData.patientId),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            // return Text('Something went wrong');
            return showMessage(true, "error", "An un-known error has occured.");
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
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.green),
                      onPressed: () {
                        togglePage("DataEntry");
                      },
                    ),
                    SizedBox(width: 20, height: 50),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteDoc(formData.patientId, "Vaccine", document.id);
                      },
                    )
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
        stream: getData("Person", formData.patientId),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            // return Text('Something went wrong');
            return showMessage(true, "error", "An un-known error has occured.");
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
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.green),
                      onPressed: () {
                        togglePage("DataEntry");
                      },
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

  Widget signinSubmitBtn(context, authBloc) {
    return ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(butcolor)),
      child: Text('Save',style: TextStyle(color: bgcolor),),
      onPressed: _btnEnabled == true ? () => setData(authBloc) : null,
    );
  }

  Widget showOPDHistory(BuildContext context, AuthBloc authBloc) {
    return StreamBuilder<QuerySnapshot>(
        stream: getData("OPD", formData.patientId),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            // return Text('Something went wrong');
            return showMessage(true, "error", "An un-known error has occured.");
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
                      "Past OPD Record:",
                      style: cNavRightText,
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.green),
                      onPressed: () {
                        togglePage("DataEntry");
                      },
                    ),
                    SizedBox(width: 20, height: 50),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteDoc(formData.patientId, "OPD", document.id);
                      },
                    )
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
        stream: getData("Rx", formData.patientId),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            // return Text('Something went wrong');
            return showMessage(true, "error", "An un-known error has occured.");
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
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.green),
                      onPressed: () {
                        togglePage("DataEntry");
                      },
                    ),
                    SizedBox(width: 20, height: 50),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteDoc(formData.patientId, "Rx", document.id);
                      },
                    )
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
        stream: getData("Lab", formData.patientId),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            // return Text('Something went wrong');
            return showMessage(true, "error", "An un-known error has occured.");
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
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.green),
                      onPressed: () {
                        togglePage("DataEntry");
                      },
                    ),
                    SizedBox(width: 20, height: 50),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteDoc(formData.patientId, "Lab", document.id);
                      },
                    )
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
                            new Text(" Pathology: ",style: TextStyle(color: Colors.white),),
                            new Text(document.get('lab'),style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            new Text(" Results: ",style: TextStyle(color: Colors.white),),
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
        stream: getData("Vaccine", formData.patientId),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            // return Text('Something went wrong');
            return showMessage(true, "error", "An un-known error has occured.");
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
                      "Message Record:",
                      style: cNavRightText,
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.green),
                      onPressed: () {
                        togglePage("DataEntry");
                      },
                    ),
                    SizedBox(width: 20, height: 50),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteDoc(formData.patientId, "Messages", document.id);
                      },
                    )
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
