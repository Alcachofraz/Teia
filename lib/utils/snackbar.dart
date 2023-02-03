import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

dynamic snackBar(BuildContext context, String message, {bool bultin = false, Color textColor = Colors.black}) async {
  /*ScaffoldMessenger.of(context).clearSnackBars();
  final snackBar = SnackBar(
    content: Text(message, style: TextStyle(color: textColor)),
    backgroundColor: Colors.white,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
  Fluttertoast.cancel();
  return await Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 3,
    backgroundColor: Colors.white,
    textColor: textColor,
    fontSize: 16.0,
  );
}

dynamic snackBarWithAction(BuildContext context, String message, SnackBarAction action, {textColor = Colors.black}) {
  final snackBar = SnackBar(
    content: Text(message, style: TextStyle(color: textColor)),
    action: action,
    backgroundColor: Colors.white,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

dynamic snackBarWithContent(BuildContext context, Widget content) {
  final snackBar = SnackBar(
    content: content,
    backgroundColor: Colors.white,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
