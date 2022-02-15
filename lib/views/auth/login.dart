import 'dart:async';
import 'package:src/blocs/auth/auth.bloc.dart';
import 'package:src/shared/custom_components.dart';
// import 'package:src/shared/custom_forms.dart';
import 'package:src/shared/custom_style.dart';
import 'package:src/models/datamodel.dart';
import 'package:src/blocs/validators.dart';
import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  static const routeName = '/login';
  @override
  LogInState createState() => LogInState();
}

class LogInState extends State<LogIn> {
  bool spinnerVisible = false;
  bool messageVisible = false;
  String messageTxt = "";
  String messageType = "";
  final _formKey = GlobalKey<FormState>();
  final model = LoginDataModel();
  bool _btnEnabled = false;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  toggleSpinner() {
    setState(() => spinnerVisible = !spinnerVisible);
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

  fetchData(AuthBloc authBloc, String loginType) async {
    toggleSpinner();
    var userAuth;
    if (loginType == "Google") {
      userAuth = await authBloc.signInWithGoogle();
    } else {
      userAuth = await authBloc.signInWithEmail(model);
    }

    if (userAuth == "") {
      showMessage(true, "success", "Login Successful");
    } else {
      showMessage(
          true,
          "error",
          (userAuth == 'user-not-found')
              ? "No user found for that email."
              : ((userAuth == 'wrong-password')
                  ? "Wrong password provided for that user."
                  : "An un-known error has occured."));
    }
    toggleSpinner();
  }

  Future logout(AuthBloc authBloc) async {
    setState(() {
      model.password = "";
      _passwordController.clear();
      _btnEnabled = false;
    });
    toggleSpinner();
    authBloc
        .logout()
        .then((res) =>
            showMessage(true, "success", "Successfully logout from system."))
        .catchError((error) => {showMessage(true, "error", error.toString())});
    toggleSpinner();
  }

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = AuthBloc();
    return Material(
      color: bgcolor,
        child: Container(
            margin: EdgeInsets.all(20.0),
            child: authBloc.isSignedIn()
                ? settingsPage(authBloc)
                : userForm(authBloc)));
  }

  Widget userForm(AuthBloc authBloc) {
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

            SizedBox(
              width: 10,
              height: 10,
            ),
            Text("Sign In", style: cHeaderDarkText),
            Container(
                width: 300.0,
                margin: EdgeInsets.only(top: 25.0),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _emailController,
                  cursorColor: Colors.blueAccent,
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 50,
                  obscureText: false,
                  onChanged: (value) => model.email = value,
                  validator: evalEmail,
                  // onSaved: (value) => _email = value,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    icon: Icon(Icons.email,color: Colors.white,),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(16.0)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    hintText: 'username@domain.com',
                    hintStyle: TextStyle(color: Colors.white24),
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: 'EmailID *',

                    // errorText: snapshot.error,
                  ),
                )),
            Container(
              margin: EdgeInsets.only(top: 5.0),
            ),
            Container(
                width: 300.0,
                margin: EdgeInsets.only(top: 25.0),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _passwordController,
                  cursorColor: Colors.blueAccent,
                  keyboardType: TextInputType.visiblePassword,
                  maxLength: 50,
                  obscureText: true,
                  onChanged: (value) => model.password = value,
                  validator: evalPassword,
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock_outline,color: Colors.white,),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    hintText: 'enter password',
                    hintStyle: TextStyle(color: Colors.white24),
                    labelText: 'Password *',
                    labelStyle: TextStyle(color: Colors.white)
                  ),
                )),
            Container(
              margin: EdgeInsets.only(top: 25.0),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
            ),
            CustomSpinner(toggleSpinner: spinnerVisible),
            CustomMessage(
                toggleMessage: messageVisible,
                toggleMessageType: messageType,
                toggleMessageTxt: messageTxt),
            Container(
              margin: EdgeInsets.only(top: 15.0),
            ),
            signinSubmitBtn(context, authBloc),
            Container(
              margin: EdgeInsets.only(top: 15.0),
            ),
            // Chip(
            //     label: Text("login with Google", style: cErrorText),
            //     avatar: CircleAvatar(
            //       backgroundColor: Colors.red,
            //       child: ElevatedButton(
            //         child: Text('G'),
            //         onPressed: () => fetchData(authBloc, "Google"),
            //       ),
            //     )),
            Container(
              margin: EdgeInsets.only(top: 15.0),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/signup',
                );
              },
              child: Chip(
                backgroundColor: butcolor,
                  avatar: CircleAvatar(
                    backgroundColor: butcolor,
                    child: Icon(Icons.add,color: bgcolor,),
                  ),
                  label: Text("Create new Account", style: TextStyle(
                      color: bgcolor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal))),
            )
          ],
        ),
      ),
    );
  }

  Widget signinSubmitBtn(context, authBloc) {
    return ElevatedButton(
      child: Text('SignIn',style: TextStyle(color: bgcolor),),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(butcolor)),

      // color: Colors.blue,
      onPressed:
          _btnEnabled == true ? () => fetchData(authBloc, "email") : null,
    );
  }

  Widget settingsPage(AuthBloc authBloc) {
    return Column(
      children: [
        Container(

          child: Text("Welcome to Medicord!",style: TextStyle(color: butcolor,fontSize: 20.0),),
        ),
        // Chip(
        //     avatar: CircleAvatar(
        //       backgroundColor: Colors.grey,
        //       child: Icon(Icons.add),
        //     ),
        //     label: Text("Welcome to Medicord", style: cNavText)),
        SizedBox(width: 20, height: 50),
        ElevatedButton(
          child: Text('Logout',style: TextStyle(color: bgcolor),),
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(butcolor),),
          // color: Colors.blue,
          onPressed: () {
            return logout(authBloc);
          },
        ),
        SizedBox(width: 20, height: 50),
        ElevatedButton(
          child: Text('click here to go to Settings',style: TextStyle(color: bgcolor),),
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(butcolor),),
          // color: Colors.blue,
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              '/settings',
            );
          },
        )
      ],
    );
  }
}
