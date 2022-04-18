import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:src/models/prescription.dart';
import 'package:src/shared/custom_style.dart';
import 'package:src/shared/custom_components.dart';
import 'package:src/views/scanner/detail_screen.dart';


class DetailMeds extends StatelessWidget {
  static const routeName = '/detail_two';
  final List<String> inpu;
  DetailMeds({ this.inpu });

  String baseUrl = "http://192.168.29.5:8000/drugs/drug/Chymapra Tablet";


  String _returninp(){
    String medname = inpu[0];
    List<String> splistring= inpu[0].split(' 1-');
    return splistring[0];
  }

  void getDrugDetails() async {
    try{
      var response = await get(Uri.parse(baseUrl));
      var responseData = json.decode(response.body);

      if(response.statusCode == 200){


        return jsonDecode(response.body);
      }else{
        return Future.error('Server error');
      }
    }catch(e){
      Future.error(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        title: Text('Medicord',style: TextStyle(color: bgcolor),),
        centerTitle: true,
        backgroundColor: butcolor,
        iconTheme: IconThemeData(color: bgcolor),

      ),
      drawer: CustomGuestDrawer(),
      body: Container(
        color: bgcolor,
        child: ListView(children: <Widget>[
          SizedBox(height: 20.0,),
          Center(
              child: Text(
                'Prescription Details',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: Colors.white),
              )),
          DataTable(
            columns: [
              DataColumn(label: Text(
                  '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)
              )),
              DataColumn(label: Text(
                  '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)
              )),
              // DataColumn(label: Text(
              //     'Profession',
              //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              // )),
            ],
            rows: [
              DataRow(cells: [
                DataCell(Text('Medicine name',style: TextStyle(color: Colors.white),)),
                DataCell(Text(_returninp(),style: TextStyle(color: Colors.white),)),
                //DataCell(Text('Actor')),
              ]),
              DataRow(cells: [
                DataCell(Text('Brand',style: TextStyle(color: Colors.white),)),
                DataCell(Text('John',style: TextStyle(color: Colors.white),)),
                //DataCell(Text('Student')),
              ]),
              DataRow(cells: [
                DataCell(Text('Alternate Medicine',style: TextStyle(color: Colors.white),)),
                DataCell(Text('Harry',style: TextStyle(color: Colors.white),)),
                //DataCell(Text('Leader')),
              ]),
              DataRow(cells: [
                DataCell(Text('Side Effects',style: TextStyle(color: Colors.white),)),
                DataCell(Text('Peter',style: TextStyle(color: Colors.white),)),
                //DataCell(Text('Scientist')),
              ]),

            ],
          ),
        ])  ,
        // child: Column(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: <Widget>[
        //     Row(
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       children: <Widget>[
        //         Text('Medicine:',style: TextStyle(color: Colors.white),),
        //         SizedBox(width: 20.0,),
        //         Text('Medicinedata',style: TextStyle(color: Colors.white),),
        //       ],
        //     ),
        //   ],
        //
        // ),
      ),

    ));
  }
}
