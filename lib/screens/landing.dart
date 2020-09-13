import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:face_recognition/screens/%20login.dart';
import 'package:face_recognition/screens/register.dart';
import 'package:face_recognition/widget/CustomButton.dart';
import 'package:face_recognition/widgets/circle.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  static final String id = 'LandingPage';

  //Displays a dialog
// box to inform the user...
  /// [context] : is the actual context of the application
  /// [msg] : is the message to display
  /// [title] : is the title of the dialog box
  startTimerDialog(String msg, String title, BuildContext context) {
    AwesomeDialog(
        dismissOnBackKeyPress: false,
        dismissOnTouchOutside: false,
        context: context,
        dialogType: DialogType.INFO,
        animType: AnimType.BOTTOMSLIDE,
        title: title,
        desc: msg,
        btnOkText: "Got it",
        btnOkColor: Colors.orange,
        btnOkOnPress: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              LoginPage.id, (Route<dynamic> route) => false);
        },
        btnCancelColor: Colors.red,
        btnCancelText: "Cancel",
        btnCancelOnPress: () {
          Navigator.of(context).pop();
        })
      ..show();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Color(0xFF1A9E8E),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  alignment: Alignment.topRight,
                  child: CustomPaint(
                    painter: CircleTop(),
                  ),
                ),
                Expanded(
                    child: Container(
                  child: Image.asset(
                    "assets/img/logo.png",
                    width: 300,
                  ),
                )),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: CustomButton(
                    pressEvent: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          LoginPage.id, (Route<dynamic> route) => false);
                    },
                    text: "LOGIN",
                    color: Colors.orange,
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: CustomButton(
                    pressEvent: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          RegisterPage.id, (Route<dynamic> route) => false);
                    },
                    text: "REGISTER",
                    color: Colors.orange,
                  ),
                ),
                SizedBox(
                  height: 100.0,
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  child: CustomPaint(
                    painter: CircleBottom(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
