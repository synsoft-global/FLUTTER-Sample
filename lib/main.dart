import 'package:blog_app/pages/root_page.dart';
import 'package:blog_app/services/authentication.dart';
import 'package:blog_app/utils/const.dart' as constant;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  final Firestore firestore = Firestore();
  await firestore.settings(timestampsInSnapshotsEnabled: true);
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bounce',
      theme: new ThemeData(
        primaryColor: constant.themeColor,
        accentColor: constant.themeColor,
        fontFamily: 'OpenSans',
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),
          title: TextStyle(
            fontSize: 18.0,
            color: Colors.black,
          ),
          subtitle: TextStyle(
            fontSize: 15.0,
            color: Colors.black,
            fontWeight: FontWeight.w300,
          ),
          body1: TextStyle(
            fontSize: 14.0,
            color: Colors.black54,
          ),
          overline: TextStyle(
            color: Colors.grey,
            fontSize: 12.0,
          ),
          display2: TextStyle(
            fontSize: 25.0,
          ),
          button: TextStyle(
            fontSize: 19.0,
            color: Colors.white,
          ),
          caption: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w300,
            fontSize: 18.0,
          ),
        ),
      ),
      home: new RootPage(
        auth: new Auth(),
      ),
    );
  }
}
