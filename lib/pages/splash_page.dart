import 'package:flutter/material.dart';

/// build splash screen
/// @author : surendra
/// @creationDate :13-Dec-2019
class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: null,
      body: Center(
        child: new Image.asset(
          'assets/splash.png',
          width: size.width,
          height: size.height,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
