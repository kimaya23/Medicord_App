import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/app.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

List<CameraDescription> cameras = [];





Future main() async {
  try {

    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    cameras = await availableCameras();
    //await _configureLocalTimeZone();
    //await NotificationApi.init();
  } on CameraException catch (e) {
    debugPrint('CameraError: ${e.description}');
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(App());
}
