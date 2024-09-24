import 'dart:io';
import 'package:face_id/face.dart';
import 'package:face_id/firebase_options.dart';
import 'package:face_id/home.dart';
import 'package:face_id/qr_code_scanner_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:DefaultFirebaseOptions.currentPlatform);

  final cameras = await availableCameras();
  final frontCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
  runApp(MyApp(frontCamera: frontCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription frontCamera;

  MyApp({required this.frontCamera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(cameras: [],),
    );
  }
}

class CameraView extends StatefulWidget {
  final CameraDescription frontCamera;

  CameraView({required this.frontCamera});

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  bool _faceDetected = false;
  bool _qrDetected = false;
  bool _isTakingPicture = false;  // Flag to prevent overlapping requests
  String _qrCode = '';
  String _imagePath = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        enableClassification: true,
      ),
    );
    _startDetection();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraController = CameraController(widget.frontCamera, ResolutionPreset.high);
      await _cameraController.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _startDetection() async {
    while (mounted) {
      if (_cameraController.value.isInitialized) {
        await _detectFaces();
        await _scanQRCode();
      }
      await Future.delayed(Duration(milliseconds: 500)); // Adjust the interval as needed
    }
  }

  Future<void> _detectFaces() async {
    if (!_cameraController.value.isInitialized || _isTakingPicture) return;

    final filePath = (await getTemporaryDirectory()).path + '/temp.jpg';
    try {
      await _cameraController.takePicture().then((XFile file) {
        final imageFile = File(file.path);
        _processImage(imageFile);
      });
    } catch (e) {
      print('Error capturing face detection image: $e');
    }
  }

  Future<void> _processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);

    try {
      final faces = await _faceDetector.processImage(inputImage);
      setState(() {
        _faceDetected = faces.isNotEmpty;
      });

      if (_faceDetected) {
        _navigateToFaceDetection();
      }
    } catch (e) {
      print('Error processing image for face detection: $e');
    }
  }

  Future<void> _scanQRCode() async {
    if (_isTakingPicture) return;

    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 
        'Cancel', 
        true, 
        ScanMode.BARCODE,
      );
      if (qrCode.isNotEmpty && qrCode != '-1') {
        setState(() {
          _qrCode = qrCode;
          _qrDetected = true;
        });
        _navigateToQRCodePage();
      }
    } catch (e) {
      print('Error scanning QR code: $e');
    }
  }

  void _navigateToFaceDetection() {
    _isTakingPicture = true;  // Prevent further actions
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FaceDetectionPage(faceId: '94:3v3vs94g6lus')),
    ).then((_) {
      _isTakingPicture = false;  // Reset after navigation
    });
  }

  void _navigateToQRCodePage() {
    _isTakingPicture = true;  // Prevent further actions
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRViewExample()),
    ).then((_) {
      _isTakingPicture = false;  // Reset after navigation
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('QR & Face Detection'),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          if (_faceDetected)
            Center(
              child: Container(
                color: Colors.black54,
                padding: EdgeInsets.all(20),
                child: Text(
                  'Face Detected!',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          if (_qrDetected)
            Center(
              child: Container(
                color: Colors.black54,
                padding: EdgeInsets.all(20),
                child: Text(
                  'QR Code Detected: $_qrCode',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
