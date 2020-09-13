import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Camera extends StatefulWidget {
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool isCameraReady = false;
  bool showCapturedPhoto = false;
  File imageFile;

  var data;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    getImg();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
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

  upload(File imageFile) async {
    // open a bytestream
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();
    // string to uri
    var uri = Uri.parse("http://2352a82c3edc.ngrok.io/api/verify");
    // create multipart request
    var request = new http.MultipartRequest("POST", uri);
    // multipart that takes file
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: basename(imageFile.path));
    // add file to multipart
    request.files.add(multipartFile);
    // send
    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {}
    print("*************hey*******************");
    // listen for response
    print("this is my response " + "$response");
    response.stream.transform(utf8.decoder).listen(
      (value) {
        print("value" + value.toString());
        setState(() {
          data = value;
          //name = data
        });
      },
    );
  }

  void onCaptureButtonPressed() async {
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Store the picture in the temp directory.
      // Find the temp directory using the `path_provider` plugin.
      final path = join(
        (await getTemporaryDirectory()).path,
        'img${DateTime.now()}.png',
      );
      print("*********************image path*********");
      print(path);
      print("*********************image path**********");
      imageFile = File(path);
      await _controller.takePicture(path); //take photo
    } catch (e) {
      print("ERROR IMAGE : ${e}");
    }
  }

  // Take pic after 10ms.
  getImg() {
    Timer(Duration(milliseconds: 20), onCaptureButtonPressed);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
      ),
      body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, spnashot) {
            if (spnashot.connectionState == ConnectionState.done) {
              return Transform.scale(
                scale: _controller.value.aspectRatio / deviceRatio,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller),
                  ),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              ); // Otherwise, display a loading indicator.
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Take photo',
        child: Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
