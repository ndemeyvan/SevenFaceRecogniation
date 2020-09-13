import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:async/async.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:camera/camera.dart';
import 'package:face_recognition/style.dart';
import 'package:face_recognition/utils/global.dart';
import 'package:face_recognition/widgets/circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/Constant.dart' as constant;
import 'landing.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key key,
    this.size = 80.0,
    this.color = Colors.red,
    this.onPressed,
    @required this.child,
  }) : super(key: key);
  final double size;
  final Color color;
  final Widget child;
  final VoidCallback onPressed;
  static final String id = 'LoginPage';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  /* ********************* Variables **************************** */
  bool nextCanBeCliked = true;
  bool backCanBeCliked = false;
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

  // For animation pakages.
  SharedAxisTransitionType _transitionType =
      SharedAxisTransitionType.horizontal;
  Future<void> _initializeControllerFuture;
  CameraController _cameraController;

  CameraLensDirection _direction = CameraLensDirection.front;
  AnimationController _controller;

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
            timeTosend = false;
            isTimeToSee = true;
            timer.cancel();
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
  upload(context, File imageFile) async {
    // open a bytestream
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();
    // string to uri
    var uri = Uri.parse("$baseUrl/verify");
    // create multipart request
    var request = new http.MultipartRequest("POST", uri);
    // multipart that takes file
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: basename(imageFile.path));
    // add file to multipart
    request.files.add(multipartFile);

    // send
    try {
      setState(() {
        isLoading = true;
      });
      constant.progressHub("Processing ... ", context);
      var response = await request.send();
      if (response.statusCode == 200) {
        constant.closeDialog(context);
        setState(() {
          isLoading = false;
        });
        response.stream.transform(utf8.decoder).listen((value) {
          bool status = json.decode(value)['status'];
          String name = json.decode(value)['name'];
          if (status == false) {
            ErrorDialog("${json.decode(value)['message']}", "Error", context);
          } else {
            constant.succesDialog(
                "Hi Welcome Mr(s) ${name} , nice to meet you , Your are SuccessFul Authenticated",
                "Auth Succesful",
                context);
          }
          print('200 RESPONSE : $value');
        });
      } else {
        ErrorDialog("Processing Error please retry", "Error", context);
        print("OTHER  response : ${response}");
        response.stream.transform(utf8.decoder).listen((value) {
          print('OTHER RESPONSE : $value');
          constant.closeDialog(context);
        });
      }
    } catch (e) {
      print('ERROR RESPONSE : $e');
    } finally {
      constant.closeDialog(context);
    }
  }

//  /// [context] : is the actual context of the application
//  /// [msg] : is the message to display
//  /// [title] : is the title of the dialog box
//  succesDialog(String msg, String title, BuildContext context) {
//    AwesomeDialog(
//        dismissOnBackKeyPress: false,
//        dismissOnTouchOutside: false,
//        context: context,
//        dialogType: DialogType.SUCCES,
//        animType: AnimType.BOTTOMSLIDE,
//        title: title,
//        desc: msg,
//        btnCancelColor: Colors.orange,
//        btnCancelText: "Go to Home",
//        btnCancelOnPress: () {
//          Navigator.of(context).pushNamedAndRemoveUntil(
//              LandingPage.id, (Route<dynamic> route) => false);
//        })
//      ..show();
//  }

  void getImg(context) async {
    try {
      // Ensure that the camera is initialized.
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
        print("*********************imagefile**********");
        print(_imageFile);
        print("*********************imagefile**********");
        upload(context, _imageFile);
      });
    } catch (e) {
      print(e);
    }
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
          });
        })
      ..show();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

//  @override
//  void dispose() {
//    _cameraController?.dispose();
////    _timer.cancel();
//    super.dispose();
//  }

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
              'Authenticate',
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
                    child: _isNameValid ? getUserImg() : userDirective(),
                    //child: Container()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        onPressed: backCanBeCliked == true
                            ? () {
                                _timer.cancel();
                                setState(() {
                                  _isNameValid = !_isNameValid;
                                  nextCanBeCliked = true;
                                });
                              }
                            : null,
                        textColor: greenColor,
                        child: const Text('BACK'),
                      ),
                      FlatButton(
                        onPressed: nextCanBeCliked == true
                            ? () {
                                startTimer(context);
                                setState(() {
                                  _isNameValid = !_isNameValid;
                                  isLoading = true;
                                  nextCanBeCliked = false;
                                });
                              }
                            : null,
                        //color: greenColor,
                        textColor: greenColor,
                        //disabledColor: Colors.black12,
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

  LayoutBuilder userDirective() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final double maxHeight = constraints.maxHeight;
      return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Color(0xFF1A9E8E),
//          image: DecorationImage(
//            image: AssetImage("assets/img/bg.jpg"),
//            fit: BoxFit.cover,
//          ),
        ),
        child: Stack(
          //alignment: AlignmentDirectional.centerEnd,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topRight,
                    child: CustomPaint(
                      painter: CircleTop(),
                    ),
                  ),

                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
//          Padding(padding: EdgeInsets.symmetric(vertical: maxHeight / 50)),
                  SizedBox(
                    height: 60,
                  ),
                  Image.asset(
                    'assets/img/faceId.jpg',
                    height: 150,
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Keep the phone a distance between 20cm and 50 cm with the face , and align your face within the circle.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Expanded(
                      child: Container(
                    child: Image.asset(
                      "assets/img/logo.png",
                      width: 300,
                    ),
                  )),
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
                                    aspectRatio:
                                        _cameraController.value.aspectRatio,
                                    child: CameraPreview(_cameraController),
                                  ),
                                ),
                              ),
                              Visibility(
                                child: Center(
                                  child: Container(
                                      child: SpinKitDualRing(
                                    color: greenColor,
                                    size: 195.0,
                                  )),
                                ),
                                visible: _start < 1 ? isLoading : false,
                              ),
                              Visibility(
                                child: Center(
                                  child: Container(
                                      child: SpinKitDualRing(
                                    color: greenColor,
                                    size: 170.0,
                                  )),
                                ),
                                visible: _start < 1 ? isLoading : false,
                              ),
                              Visibility(
                                child: Center(
                                  child: Container(
                                      child: SpinKitDualRing(
                                    color: greenColor,
                                    size: 120.0,
                                  )),
                                ),
                                visible: _start < 1 ? isLoading : false,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Keep the phone a distance between 20cm and 50 cm with the face , and align your face within the circle ",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 18),
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
