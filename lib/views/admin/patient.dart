import 'package:src/blocs/auth/auth.bloc.dart';
import 'package:src/shared/custom_components.dart';
import 'package:src/shared/custom_style.dart';
import 'package:src/models/datamodel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Patient extends StatefulWidget {
  static const routeName = '/patient';
  @override
  PatientState createState() => PatientState();
}

class PatientState extends State<Patient> {
  bool spinnerVisible = false;
  bool messageVisible = false;
  bool isAdmin = false;
  String messageTxt = "";
  String messageType = "";
  CollectionReference vaccineRecords =
      FirebaseFirestore.instance.collection('vaccine');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    authBloc.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final ScreenPatientArguments args =
        ModalRoute.of(context).settings.arguments;
    AuthBloc authBloc = AuthBloc();
    return new Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(title: const Text(cPRecords,style: TextStyle(color: bgcolor),),backgroundColor: butcolor,iconTheme: IconThemeData(color: bgcolor),),
      drawer: Drawer(child: CustomAdminDrawer()),
      body: ListView(
        children: [
          Center(
            child: Container(
                margin: EdgeInsets.all(20.0),
                child: authBloc.isSignedIn()
                    ? settings(authBloc, args)
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

  Widget settings(AuthBloc authBloc, args) {
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 25.0),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(butcolor)),
                child: Text('Back',style: TextStyle(color: bgcolor),),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          SizedBox(width: 10, height: 50),
          Text(args.reportType, style: cHeaderDarkText),
          SizedBox(width: 10, height: 50),
          Container(
              width: 500,
              height: 500,
              child: showRecords(context, args.patientID))
        ],
      ),
    );
  }

  Widget showRecords(BuildContext context, patientID) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vaccine')
            .where('author', isEqualTo: patientID)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return showMessage(true, "error", "An un-known error has occured.");
          }
          if (snapshot.data.docs.isEmpty) {
            return Text('Patient has no history records.', style: cErrorText);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return new ListTile(
                title: new Text(document.get('appointmentDate'),style: TextStyle(color: Colors.white),),
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
                        new Text("DOB: ",style: TextStyle(color: Colors.white),),
                        new Text(document.get('dob'),style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    Row(
                      children: [
                        new Text("ID Type: ",style: TextStyle(color: Colors.white),),
                        new Text(document.get('idType'),style: TextStyle(color: Colors.white),),
                        new Text(" ID: ",style: TextStyle(color: Colors.white),),
                        new Text(document.get('id'),style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    Row(
                      children: [
                        new Text("Next Appt. Dt: ",style: TextStyle(color: Colors.white),),
                        new Text(document.get('newAppointmentDate'),style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    Row(
                      children: [
                        new Text("Occupation: ",style: TextStyle(color: Colors.white),),
                        new Text(document.get('occupation'),style: TextStyle(color: Colors.white),),
                      ],
                    )
                  ],
                ),
              );
            }).toList(),
          );
        });
  }
}
