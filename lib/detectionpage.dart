// import 'dart:io';
// import 'dart:convert'; // For jsonEncode
// import 'package:face_id/qr_code_scanner_page.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:camera/camera.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;
// import 'package:http/http.dart' as http;
// import 'dart:async';

// class buttonface extends StatefulWidget {
//   final String faceId;

//   buttonface({required this.faceId, super.key});

//   @override
//   _buttonfaceState createState() => _buttonfaceState();
// }

// class _buttonfaceState extends State<buttonface> {
//   late FaceDetector _faceDetector;
//   late CameraController _cameraController;
//   bool _isDetecting = false;
//   bool _isCameraInitialized = false;
//   String? _detectedImageId;
//   Timer? _timer;
//   Timer? _countdownTimer;
//   int _countdownTime = 10; // Time in seconds for the countdown
//   int _captureTime = 0; // Time elapsed during capturing
//   String serverResponse = ''; // Store server response
//   bool _faceDetected = false; // Track if a face has been detected
//   String _statusMessage = 'Please Put Your Face'; // Status message for the user
//   String message1='';

//   @override
//   void initState() {
//     super.initState();
//     Firebase.initializeApp().then((_) {
//       _initializeCamera();
//       _initializeFaceDetector();
//     });
//   }

//   void _initializeFaceDetector() {
//     _faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//         enableContours: true,
//         enableClassification: true,
//         enableTracking: true,
//       ),
//     );
//   }

  
  
  
//   Future<void> _initializeCamera() async {
//   try {
//     final cameras = await availableCameras();
//     final frontCamera = cameras.firstWhere(
//       (camera) => camera.lensDirection == CameraLensDirection.front,
//       orElse: () => cameras.first,
//     );
//     _cameraController = CameraController(
//       frontCamera,
//       ResolutionPreset.high,
//     );
//     await _cameraController.initialize();
//     setState(() {
//       _isCameraInitialized = true;
//     });
//     _startAutoCapture();
//     _startCaptureTimer();
//   } catch (e) {
//     print('Error initializing camera: $e');
//   }
// }

  
  
  
  
  
  
  
  
  
  
  
  

//   void _startAutoCapture() {
//     _timer?.cancel();
//     _timer = Timer.periodic(Duration(seconds: 5), (timer) {
//       _captureAndProcessImage();
//     });
//   }

//   void _startCaptureTimer() {
//     _countdownTimer?.cancel();
//     _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       setState(() {
//         _captureTime++;
//       });
//     });
//   }

//   Future<void> _captureAndProcessImage() async {
//     if (!_isCameraInitialized || _isDetecting) return;
//     _isDetecting = true;

//     try {
//       final image = await _cameraController.takePicture();
//       final inputImage = InputImage.fromFilePath(image.path);

//       final faces = await _faceDetector.processImage(inputImage);

//       if (faces.isNotEmpty) {
//         _faceDetected = true;
//         _statusMessage = 'Face detected, processing...';
//         final detectedImageId = await _checkAndSaveFaceImage(File(image.path), faces);
//         setState(() {
//           _detectedImageId = detectedImageId;
//         });
//         _showFaceDetectionResultDialog(detectedImageId);
//       } else {
//         _faceDetected = false;
//         setState(() {
//           _statusMessage = 'Please Put Your Face';
//         });
//       }
//     } catch (e) {
//       print('Error processing image: $e');
//     } finally {
//       _isDetecting = false;
//     }
//   }

//   Future<String> _checkAndSaveFaceImage(File image, List<Face> faces) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final existingImages = await FirebaseFirestore.instance.collection('faces').get();
//     for (var doc in existingImages.docs) {
//       final existingImageUrl = doc['url'];
//       final existingImageFile = await _downloadFile(existingImageUrl);
//       final existingInputImage = InputImage.fromFilePath(existingImageFile.path);

//       final existingFaces = await _faceDetector.processImage(existingInputImage);
//       if (existingFaces.isNotEmpty && _compareFaces(faces.first, existingFaces.first)) {
//         await _sendIdToApi(doc.id, false);
//         return doc.id;
//       }
//     }

//     final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final ref = FirebaseStorage.instance.ref().child('faces/$fileName');
//     await ref.putFile(image);
//     final imageUrl = await ref.getDownloadURL();
//     final docRef = await FirebaseFirestore.instance.collection('faces').add({'url': imageUrl});
//     await _sendIdToApi(docRef.id, true);

//     return docRef.id;
//   }

//   Future<void> _sendIdToApi(String id, bool isNew) async {
//     final apiUrl = isNew
//         ? 'https://api.northstar.mv/api/gym-access/fid-teach'
//         : 'https://api.northstar.mv/api/gym-access/fid';

//     Map<String, dynamic> body = {'FID': id};
//     if (isNew) {
//       body.addAll({"QR": widget.faceId, "STS": "test"});
//     }

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         body: jsonEncode(body),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer aBcDeFgHiJkLmNoP',
//         },
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         setState(() {
//           if (responseData["FID"].toString()=="true") {

                   
//                    if (responseData['STS'].toString()=="Added") {

//                     message1="Welcome new Fresher Face Added";
//   Future.delayed(Duration(seconds: 10), () {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => QRViewExample(),
//     ),
//   );
// });
                    

//                    } else if(responseData['QR'].toString()=='true') {
//                       message1="Face Identified , Welcome to GYM , Door can be Accessed";

//                         Future.delayed(Duration(seconds: 10), () {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => QRViewExample(),
//     ),
//   );
// });
                        
//                    }

            
//           } else {
//             message1="Cannot Access";

//               Future.delayed(Duration(seconds: 10), () {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => QRViewExample(),
//     ),
//   );
// });
//           }
//         });
//       } else {
//         setState(() {
//           message1 = 'Failed to validate Face';
//             Future.delayed(Duration(seconds: 10), () {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => QRViewExample(),
//     ),
//   );
// });
//         });
//       }
//     } catch (e) {
//       setState(() {
//         message1 = 'Error';
//           Future.delayed(Duration(seconds: 10), () {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => QRViewExample(),
//     ),
//   );
// });
//       });
//     }
//   }

//   Future<File> _downloadFile(String url) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final filePath = path.join(directory.path, path.basename(url));
//     final file = File(filePath);

//     if (!await file.exists()) {
//       final response = await HttpClient().getUrl(Uri.parse(url));
//       final bytes = await consolidateHttpClientResponseBytes(await response.close());
//       await file.writeAsBytes(bytes);
//     }

//     return file;
//   }

//   bool _compareFaces(Face face1, Face face2) {
//     final Rect boundingBox1 = face1.boundingBox;
//     final Rect boundingBox2 = face2.boundingBox;

//     final double headEulerAngleY1 = face1.headEulerAngleY ?? 0.0;
//     final double headEulerAngleY2 = face2.headEulerAngleY ?? 0.0;
//     final double headEulerAngleZ1 = face1.headEulerAngleZ ?? 0.0;
//     final double headEulerAngleZ2 = face2.headEulerAngleZ ?? 0.0;
//     return boundingBox1.overlaps(boundingBox2) &&
//            (headEulerAngleY1 - headEulerAngleY2).abs() < 10 &&
//            (headEulerAngleZ1 - headEulerAngleZ2).abs() < 10;
//   }

//   void _stopCaptureTimer() {
//     _countdownTimer?.cancel();
//     setState(() {
//       _captureTime = 0;
//     });
//   }

//   void _showFaceDetectionResultDialog(String detectedImageId) {
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     _faceDetector.close();
//     _timer?.cancel();
//     _countdownTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Face Detection'),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           if (_isCameraInitialized)
//             Expanded(
//               child: CameraPreview(_cameraController),
//             )
//           else
//             Center(child: CircularProgressIndicator()),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               message1,
//               style: TextStyle(color: Colors.black,fontSize: 20),
//             ),
//           ),
        
        
        
        
        
        
        
//         ],
//       ),
//     );
//   }
// }