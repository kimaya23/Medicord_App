import 'package:flutter/material.dart';
import 'package:src/views/scanner/camera_screen.dart';
import 'package:src/shared/custom_style.dart';
import 'package:src/shared/custom_components.dart';


class Scanner extends StatefulWidget {
  static const routeName = '/scan';

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        title: Text('Medicord'),
        centerTitle: true,
      ),
      drawer: Drawer(child: CustomGuestDrawer()),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20.0,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Scan Your printed prescriptions", style: TextStyle(color: butcolor, fontFamily: 'SourceSansPro',fontSize: 20.0),),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(butcolor),
                ),
                onPressed: () {

                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('Scan',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),),
                ),
              ),
              SizedBox(height: 50.0,)

            ],
          ),
        ),
      ),
    );
  }
}

