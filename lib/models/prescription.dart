import 'dart:convert';

import 'package:http/http.dart' as http;

class Prescription {
  String baseUrl = "http://192.168.112.2:8000/drugs/drug/";
  Future<List> getAllPres() async{
    try{
      var response = await http.get(Uri.parse(baseUrl));
      if(response.statusCode == 200){
        return jsonDecode(response.body);
      }else{
        return Future.error('Server error');
      }
    }catch(e){
      Future.error(e);
    }
  }
  // final String eid;
  // final String eemail;
  // final String ename;
  //
  //
  // Employee({this.eid, this.eemail, this.ename});
  //
  // factory Employee.fromJson(Map<String, dynamic> json) {
  //   return Employee(
  //     eid: json['eid'],
  //     ename: json['ename'],
  //     eemail: json['eemail'],
  //   );
  // }
  //
  // Map<String, dynamic> toJson() => {
  //   'eid' : eid,
  //   'ename': ename,
  //   'eemail': eemail,
  // };
}