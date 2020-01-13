import 'package:blog_app/pages/home_page.dart';
import 'package:blog_app/pages/splash_page.dart';
import 'package:blog_app/services/authentication.dart';
import 'package:flutter/material.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus {
  NOT_DETERMINED,
  LOGIN_PAGE,
  HOME_PAGE,
  PROFILE_PAGE,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (widget.auth.getCurrentUser() != null) {
        widget.auth.getCurrentUser().then((user) {
          setState(() {
            if (user != null) {
              _userId = user?.uid;
            }
            authStatus = user?.uid == null
                ? AuthStatus.LOGIN_PAGE
                : AuthStatus.HOME_PAGE;

            print('authStatus ' + authStatus.toString());
          });
        });
      } else {
        authStatus = AuthStatus.LOGIN_PAGE;
      }
    });
  }

  /// function used to navigate on home screen
  /// @author : surendra
  /// @creationDate :13-Dec-2019
  void _onGoToHomePage() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.HOME_PAGE;
    });
  }


  /// function used to open waiting splash screen
  /// @author : surendra
  /// @creationDate :13-Dec-2019
  Widget _buildWaitingScreen() {
    return new SplashPage();
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.HOME_PAGE:
        if (_userId.length > 0 && _userId != null) {
          return new HomePage(
            userId: _userId,
            auth: widget.auth,
          );
        } else
          return _buildWaitingScreen();
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}
