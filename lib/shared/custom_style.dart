import 'package:flutter/material.dart';

const cAppTitle = "Medicord";
const cAboutusTitle = "About us";
const cSignupTitle = "Create new account";
const cSettingsTitle = "Settings";
const cRxTitle = "Pharmacy";
const cVaccineTitle = "Vaccine";
const cOPDIPDTitle = "OPD/IPD";
const cMessagesTitle = "Messages";
const cPathologysTitle = "Pathology";
const cAppointment = "Appointments";
const cAdmin = "Admin";
const cPerson = "Personal Data";
const cPRecords = "Records";
const cReports = "Reports";
const cSCM = "Supply Chain";
const cAddressBookTitle = "Address Book";
const cAddressBookAddTitle = "Add Address Book";
const cAddressBookEditTitle = "Edit Address Book";
const cSignUpTitle = "Sign up";

enum cMessageType { error, success }

const cNavText = TextStyle(
    color: Colors.white,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal);
const cNavRightText = TextStyle(
    color: butcolor,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal);

const cEmailID = "info@elishconsulting.com";
const cLabel = "Navigation Menu";
const cSampleImage =
    "images/medicord.jpeg";

const cBodyText = TextStyle(
  fontWeight: FontWeight.w400,
  color: Colors.blueGrey,
);
const cErrorText = TextStyle(
  fontWeight: FontWeight.w400,
  color: Colors.red,
);
const cWarnText = TextStyle(
  fontWeight: FontWeight.w400,
  color: Colors.yellow,
);
const cSuccessText = TextStyle(
  fontWeight: FontWeight.w400,
  color: Colors.green,
);

const cHeaderText = TextStyle(
    color: Colors.blueAccent,
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal);

const cHeaderWhiteText = TextStyle(
    color: Colors.white,
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal);

const cHeaderDarkText = TextStyle(
    color: butcolor,
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal);

var cThemeData = ThemeData(
  primaryColor: Colors.blue,
  brightness: Brightness.dark,
  //primarySwatch: Colors.white,
  buttonColor: butcolor,
  backgroundColor: bgcolor,
  buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary,),
);
const bgcolor = const Color(0xff121212);
const contcolor = const Color(0xff3c4043);
const butcolor = const Color(0xff4db6ac);
