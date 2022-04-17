import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:src/shared/custom_style.dart';
import 'package:src/shared/custom_components.dart';
import '/views/api/firebase_api.dart';
import '/views/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class Upload extends StatefulWidget {
  static const routeName = '/upload';
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  UploadTask task;
  File file;

  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? basename(file.path) : 'No File Selected';

    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: butcolor,
        title: Text('Medicord',style: TextStyle(color: bgcolor),),
        centerTitle: true,
      ),
      drawer: Drawer(child: CustomGuestDrawer(),),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('Select File'),
                //icon: Icons.attach_file,
                onPressed: selectFile,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(butcolor),
                ),
              ),
              SizedBox(height: 8),
              Text(
                fileName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: Colors.white),
              ),
              SizedBox(height: 48),
              ElevatedButton(
                child: Text('Upload File',style: TextStyle(color: Colors.white),),
                //icon: Icons.cloud_upload_outlined,
                onPressed: uploadFile,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(butcolor),
                ),
              ),
              SizedBox(height: 20),
              task != null ? buildUploadStatus(task) : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.custom, allowedExtensions: ['pdf']);

    if (result == null) return;
    final path = result.files.single.path;

    setState(() => file = File(path));
  }

  Future uploadFile() async {
    if (file == null) return;

    final fileName = basename(file.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, file);
    setState(() {});

    if (task == null) return;

    final snapshot = await task.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download-Link: $urlDownload');
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
    stream: task.snapshotEvents,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final snap = snapshot.data;
        final progress = snap.bytesTransferred / snap.totalBytes;
        final percentage = (progress * 100).toStringAsFixed(2);

        return Text(
          '$percentage %',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
        );
      } else {
        return Container();
      }
    },
  );
}