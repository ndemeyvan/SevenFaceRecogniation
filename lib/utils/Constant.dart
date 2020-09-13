import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:face_recognition/screens/landing.dart';
import 'package:flutter/material.dart';
import 'package:native_progress_hud/native_progress_hud.dart';

//Displays a dialog
// box to inform the user...
/// [context] : is the actual context of the application
/// [msg] : is the message to display
/// [title] : is the title of the dialog box
succesDialog(String msg, String title, BuildContext context) {
  AwesomeDialog(
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      context: context,
      dialogType: DialogType.SUCCES,
      animType: AnimType.BOTTOMSLIDE,
      title: title,
      desc: msg,
      btnCancelColor: Colors.orange,
      btnCancelText: "Go to Home",
      btnCancelOnPress: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
            LandingPage.id, (Route<dynamic> route) => false);
      })
    ..show();
}

// Allows you to show
// the loading animation.
/// [context] : is the actual context of the application
/// [msg] : is the message to display
progressHub(msg, context) {
  NativeProgressHud.showWaitingWithText(msg);
}

// Allows you to close
// the loading animation.
/// [context] : is the actual context of the application
closeDialog(context) {
  NativeProgressHud.hideWaiting();
}
