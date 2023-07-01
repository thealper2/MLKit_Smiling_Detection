import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MLKit Smile Detection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  String result = "";
  late ImagePicker imagePicker;
  late List<Face> faces;
  FaceDetector? faceDetector;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    var options = FaceDetectorOptions(
        enableClassification: true,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.fast);
    faceDetector = GoogleMlKit.vision.faceDetector(options);
  }

  pickImage(bool fromGallery) async {
    XFile? pickedFile = await imagePicker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera);
    File image = File(pickedFile!.path);
    setState(() {
      _image = image;
      if (_image != null) {
        smileDetection();
      }
    });
  }

  smileDetection() async {
    final inputImage = InputImage.fromFile(_image!);
    faces = (await faceDetector?.processImage(inputImage))!;
    setState(() {
      if (faces.length > 0) {
        if (faces[0].smilingProbability! > 0.5) {
          result = "Smiling";
        } else {
          result = "Not Smiling";
        }
      } else {
        result = "No face detected.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null
                ? Image.file(_image!)
                : Icon(
                    Icons.image,
                    size: 150,
                  ),
            ElevatedButton(
              onPressed: () {
                pickImage(true);
              },
              onLongPress: () {
                pickImage(false);
              },
              child: Text("Choose"),
            ),
            SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              child: Text(
                '$result',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'solway',
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
