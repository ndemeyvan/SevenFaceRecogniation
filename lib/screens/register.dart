import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:face_recognition/screens/landing.dart';
import 'package:face_recognition/style.dart';
import 'package:face_recognition/utils/global.dart';
import 'package:face_recognition/widget/CirclePainter.dart';
import 'package:face_recognition/widgets/circle.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/Constant.dart' as constant;

class RegisterPage extends StatefulWidget {
  static final String id = 'RegisterPage';
  const RegisterPage({
    Key key,
    this.size = 80.0,
//    this.color = Colors.grey,
    this.onPressed,
    @required this.child,
  }) : super(key: key);

  final double size;
//   Color color;
  final Widget child;
  final VoidCallback onPressed;
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  AnimationController _controller;
  /* ********************* Variables **************************** */
  bool isRetryed = false;
  File _imageFile;
  Object data;
  String name = "";
  Timer _timer;
  int _start = 5;
  bool isTimeToSee = false;
  bool timeTosend = true;
  bool isLoading = false;
  bool _isNameValid = false;
  bool isCameraReady = false;
  bool showCapturedPhoto = false;
  Future<void> _initializeControllerFuture;
  Color color = Colors.grey;

  /* ********************* Controller **************************** */
  CameraController _cameraController;

  CameraLensDirection _direction = CameraLensDirection.front;

  // For animation pakages.
  SharedAxisTransitionType _transitionType =
      SharedAxisTransitionType.horizontal;

  /* ********************* Methodes **************************** */

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  Future<void> _initializeCamera() async {
    // Create the CameraController
    _cameraController =
        CameraController(await _getCamera(_direction), ResolutionPreset.high);
    // Initialize the CameraController
    _initializeControllerFuture = _cameraController.initialize();
    if (!mounted) {
      return;
    }
    setState(() {
      isCameraReady = true;
    });
  }

  // Get list of cameras of the device
  Future<CameraDescription> _getCamera(CameraLensDirection dir) async {
    return await availableCameras().then(
      (List<CameraDescription> cameras) => cameras.firstWhere(
        (CameraDescription camera) => camera.lensDirection == dir,
      ),
    );
  }

  void startTimer(context) {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();

            setState(() {
              timeTosend = false;
              isTimeToSee = true;
              isLoading = false;
            });

            getImg(context);
          } else {
            setState(() {
              _start = _start - 1;
            });
          }
        },
      ),
    );
  }

  // Send user data to api.
  uploadImage(File imageFile, name, context) async {
    FormData data = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        imageFile.path,
      ),
      "username": name,
    });

    try {
      Dio dio = new Dio();
      dio.post(
        "$baseUrl/register",
        data: data,
        onSendProgress: (int sent, int total) {
          print("on progress : $sent $total");
        },
      ).then((response) {
        if (response.statusCode == 200) {
          constant.closeDialog(context);
          setState(() {
            isLoading = false;
//          color = Colors.red;
          });
          if (response.data.status == false) {
            ErrorDialog("${response.data.message}", "Error", context);
            setState(() {
              color = Colors.red;
            });
          } else {
            setState(() {
              color = Colors.orange;
            });
            constant.succesDialog(
                "Registration successful , please try to login", "", context);
          }
          print("STATUS : ${response.data.status}");
          print('200 RESPONSE : ${response.data}');
        } else {
          setState(() {
            color = Colors.red;
          });
          ErrorDialog("Processing Error please retry", "Error", context);
          print("OTHER  response : ${response.data}");
          constant.closeDialog(context);
        }
      }).catchError((error) {
        setState(() {
          color = Colors.red;
        });
        print("other Error : $error");
        ErrorDialog("${error.toString()}", "Error", context);
      });
    } catch (e) {
      setState(() {
        color = Colors.red;
      });
      print('ERROR RESPONSE : $e');
      ErrorDialog("${e.toString()}", "Error", context);
    } finally {
      constant.closeDialog(context);
    }
  }

  // Send user data to api.
//  upload(context, File imageFile) async {
//    // open a bytestream
//    var stream =
//        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
//    // get file length
//    var length = await imageFile.length();
//
//    // string to uri
//    var uri = Uri.parse("$baseUrl/register");
//
//    // create multipart request
//    var request = new http.MultipartRequest("POST", uri);
//    // multipart that takes file
//    var multipartFile = new http.MultipartFile('image', stream, length,
//        filename: basename(imageFile.path));
//    // add file to multipart
//    request.files.add(multipartFile);
//    var data = {"username": name};
//    // request.fields.addAll(data);
//    request.headers.addAll(data);
//    request.fields['username'] = name;
//    setState(() {
//      isLoading = false;
//      color = Colors.blue;
//    });
//    // send
//    try {
//      constant.progressHub("Processing ... ", context);
//      var response = await request.send();
//      if (response.statusCode == 200) {
//        constant.closeDialog(context);
//        setState(() {
//          isLoading = false;
////          color = Colors.red;
//        });
//        response.stream.transform(utf8.decoder).listen((value) {
//          bool status = json.decode(value)['status'];
//          if (status == false) {
//            ErrorDialog("${json.decode(value)['message']}", "Error", context);
//            setState(() {
//              color = Colors.red;
//            });
//          } else {
//            setState(() {
//              color = Colors.orange;
//            });
//            constant.succesDialog(
//                "Registration successful , please try to login", "", context);
//          }
//          print("STATUS : ${status}");
//          print('200 RESPONSE : $value');
//        });
//      } else {
//        setState(() {
//          color = Colors.red;
//        });
//        ErrorDialog("Processing Error please retry", "Error", context);
//        print("OTHER  response : ${response}");
//        response.stream.transform(utf8.decoder).listen((value) {
//          print('OTHER RESPONSE : $value');
//          constant.closeDialog(context);
//        });
//      }
//    } catch (e) {
//      setState(() {
//        color = Colors.red;
//      });
//      print('ERROR RESPONSE : $e');
//      ErrorDialog("${e.toString()}", "Error", context);
//    } finally {
//      constant.closeDialog(context);
//    }
//  }

  FocusNode myFocusNode = new FocusNode();

  void getImg(context) async {
    try {
      await _initializeControllerFuture;
      // Store the picture in the temp directory.
      // Find the temp directory using the `path_provider` plugin.
      final path = join(
        (await getTemporaryDirectory()).path,
        'img${DateTime.now()}.png',
      );

      await _cameraController.takePicture(path); //take photo
      setState(() {
        _imageFile = File(path);
        showCapturedPhoto = true;
        uploadImage(_imageFile, name, context);
      });
    } catch (e) {
      print(e);
      constant.closeDialog(context);
    }
  }

  void _toggleLoginStatus() {
    setState(() {
      _isNameValid = !_isNameValid;
    });
  }

  // box to inform the user...
  /// [context] : is the actual context of the application
  /// [msg] : is the message to display
  /// [title] : is the title of the dialog box
  ErrorDialog(String msg, String title, BuildContext context) {
    AwesomeDialog(
        dismissOnBackKeyPress: false,
        dismissOnTouchOutside: false,
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.BOTTOMSLIDE,
        title: title,
        desc: msg,
        btnCancelColor: Colors.orange,
        btnCancelText: "Retry",
        btnCancelOnPress: () {
          setState(() {
            startTimer(context);
            _start = 5;
            isRetryed = true;
            isLoading = true;
            color = Colors.grey;
          });
        })
      ..show();
  }

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
        btnCancelColor: Colors.orange,
        btnCancelText: "OK",
        btnCancelOnPress: () {
          startTimer(context);
          isLoading = true;
          color = Colors.grey;
        })
      ..show();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Widget myCamera() {
    return Center(
        child: Container(
      height: 200,
      width: 200,
      child: ClipOval(
        child: CircleAvatar(
          child: Stack(
            children: [
              Transform.scale(
                scale: 1 / _cameraController.value.aspectRatio,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _cameraController.value.aspectRatio,
                    child: CameraPreview(_cameraController),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

//////////////////////////////////////////////////SCREEN
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: greenColor,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // J'ajoute ceci pour lutter contre les memory Leaks
                  if (_timer != null) {
                    _timer.cancel();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        LandingPage.id, (Route<dynamic> route) => false);
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        LandingPage.id, (Route<dynamic> route) => false);
                  }
                }),
            title: Text(
              'Register',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 300),
                    reverse: !_isNameValid,
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                    ) {
                      return SharedAxisTransition(
                        child: child,
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: _transitionType,
                      );
                    },
                    child: _isNameValid ? getUserImg() : getUserName(),
                    //child: Container()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        onPressed: _isNameValid
                            ? () {
                                _toggleLoginStatus();
                                _timer.cancel();
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            : null,
                        textColor: greenColor,
                        child: const Text('BACK'),
                      ),
                      FlatButton(
                        onPressed: _isNameValid
                            ? null
                            : name.isEmpty
                                ? null
                                : () {
                                    if (name.isNotEmpty) {
                                      _toggleLoginStatus();
                                      startTimerDialog(
                                          "Focus on the camera for 5 seconds .",
                                          "Info",
                                          context);
                                    } else {
                                      startTimerDialog("Enter a valid name",
                                          "Error", context);
                                    }
                                    if (_timer != null) {
                                      _timer.cancel();
                                    }
                                    setState(() {
                                      _start = 5;
                                      isLoading = true;
                                    });
                                  },
                        textColor: greenColor,
                        child: const Text('NEXT'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              LandingPage.id, (Route<dynamic> route) => false);
        });
  }

  LayoutBuilder getUserName() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final double maxHeight = constraints.maxHeight;
      return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Color(0xFF1A9E8E),
        ),
        child: Stack(
          //alignment: AlignmentDirectional.centerEnd,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: CustomPaint(
                      painter: CircleTop(),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: maxHeight / 10)),
                  Text(
                    'Welcome',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: maxHeight / 50)),
                  const Text(
                    'Please enter your name to continue',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 40.0,
                      left: 15.0,
                      right: 15.0,
                      bottom: 10.0,
                    ),
                    child: TextFormField(
                      initialValue: name,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                            color: myFocusNode.hasFocus
                                ? Colors.blue
                                : Colors.white),
                        isDense: true,
                        labelText: 'Enter your name',
                        border: new UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          name = value;
                          print(name);
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Keep the phone a distance between 20cm and 50 cm with the face , and align your face within the circle.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    child: Image.asset(
                      "assets/img/logo.png",
                      width: 300,
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Container getUserImg() {
    return Container(
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Stack(
            children: [
              Container(
                alignment: Alignment.topRight,
                child: CustomPaint(
                  painter: CircleTop(),
                ),
              ),
              Column(
                children: [
                  Center(
                    child: CustomPaint(
                      painter: CirclePainter(
                        _controller,
                        color: color,
                      ),
                      child: SizedBox(
                        width: widget.size * 4.125,
                        height: widget.size * 4.125,
                        child: myCamera(),
                      ),
                    ),
                  ),
//                  Center(
//                    child: Container(
//                      height: 200,
//                      width: 200,
//                      child: ClipOval(
//                        child: CircleAvatar(
//                          child: Stack(
//                            children: [
//                              Transform.scale(
//                                scale: 1 / _cameraController.value.aspectRatio,
//                                child: Center(
//                                  child: AspectRatio(
//                                    aspectRatio:
//                                        _cameraController.value.aspectRatio,
//                                    child: CameraPreview(_cameraController),
//                                  ),
//                                ),
//                              ),
//                              Visibility(
//                                child: Center(
//                                  child: Container(
//                                      child: SpinKitDualRing(
//                                    color: greenColor,
//                                    size: 195.0,
//                                  )),
//                                ),
//                                visible: _start < 1 ? isLoading : false,
//                              ),
//                              Visibility(
//                                child: Center(
//                                  child: Container(
//                                      child: SpinKitDualRing(
//                                    color: greenColor,
//                                    size: 170.0,
//                                  )),
//                                ),
//                                visible: _start < 1 ? isLoading : false,
//                              ),
//                              Visibility(
//                                child: Center(
//                                  child: Container(
//                                      child: SpinKitDualRing(
//                                    color: greenColor,
//                                    size: 120.0,
//                                  )),
//                                ),
//                                visible: _start < 1 ? isLoading : false,
//                              )
//                            ],
//                          ),
//                        ),
//                      ),
//                    ),
//                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Keep the phone a distance between 20cm and 50 cm with the face , and align your face within the circle ",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Visibility(
                    visible:
                        (_start > 0 || isRetryed == true) ? isLoading : false,
                    child: RichText(
                      text: TextSpan(
                        text: 'Registration in: $_start (s)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: greenColor,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.bottomLeft,
                child: CustomPaint(
                  painter: CircleBottom(),
                ),
              ),
            ],
          )),
    );
  }
}
