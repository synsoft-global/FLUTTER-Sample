import 'package:blog_app/models/user_model.dart';
import 'package:blog_app/utils/const.dart';
import 'package:blog_app/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// function used to getUser
/// @author : surendra
/// @creationDate :13-Dec-2019
Future<UserModel> getUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  UserModel userModel = new UserModel();
  userModel.id = prefs.getString(USER_ID) ?? '';
  userModel.auth_id = prefs.getString(AUTH_ID) ?? '';
  userModel.name = prefs.getString(USER_NAME) ?? '';
  userModel.email = prefs.getString(USER_EMAIL) ?? '';
  userModel.image = prefs.getString(USER_IMAGE) ?? '';
  userModel.about = prefs.getString(USER_ABOUT) ?? '';
  return userModel;
}

/// function used to get screenWidth
/// @author : surendra
/// @creationDate :13-Dec-2019
double screenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

/// function used to get screenHeight
double screenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

/// function used to show alert dialog
showAlertDialog(BuildContext context, String contentMsg) {
  // flutter defined function
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: new Text("Alert"),
        content: new Text(contentMsg),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text(
              "OK",
              style: TextStyle(color: themeColor),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

/// function used to show progress
showProgress(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(themeColor),
      ),
    ),
  );
}

/// function used to hieght progress
hideProgress(BuildContext context) {
  Navigator.pop(context);
}

/// function used to get getCircularProgress
Widget getCircularProgress(bool _isLoading) {
  if (_isLoading) {
    return new Stack(
      children: [
        new Opacity(
          opacity: 0.3,
          child: const ModalBarrier(dismissible: false, color: Colors.grey),
        ),
        new Center(
          child: new CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
          ),
        ),
      ],
    );
  }
  return Container();
}

/// function used to validate password
String validatePassword(String value) {
  if (value == null || value.trim().isEmpty)
    return MSG_ENTER_PASSWORD;
  else if (value.trim().length < 6)
    return MSG_INVALID_PASSWORD;
  else
    return null;
}

/// function used to validate Email
String validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (value == null || value.trim().isEmpty)
    return ERR_MSG_EMPTY_EMAIL;
  else if (!regex.hasMatch(value.trim()))
    return MSG_ENTER_VALID_EMAIL;
  else
    return null;
}

/// function used to validate empty text
String validateEmptyText(String value) {
  if (value == null || value.trim().isEmpty)
    return MSG_ENTER_NAME;
  else
    return null;
}

/// function used to formate date time
String getFormattedDateTime(String dateTime) {
  DateTime todayDate = DateTime.parse(dateTime);
  print(todayDate);
  String formattedDateTime = DateFormat('dd MMM hh:mm a').format(todayDate);
  print(formattedDateTime);
  return formattedDateTime;
}
