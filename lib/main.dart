import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:photo_editor/gallery.dart';

 FirebaseApp mapp;
void main() => runApp(MyApp());


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    configureApp(mapp);

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Gallery(),
    );
  }

}
void configureApp(app) async {
  app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions(
      googleAppID: '',
      gcmSenderID: '',
      databaseURL: '',
    )
        : const FirebaseOptions(
      googleAppID: '',
      apiKey: '',
      databaseURL: '',
    ),
  );
}

