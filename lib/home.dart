import 'package:face_id/buttonface.dart';
import 'package:face_id/face.dart';
import 'package:face_id/qr_code_scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// Import the FaceDetectionPage


class HomePage extends StatelessWidget {
  final List<CameraDescription> cameras;

  HomePage({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Home Page',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))
              ),
              onPressed: () {
                // Navigate to the FaceDetectionPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRViewExample()
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Go to  QR Scanner',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
              ),
            ),
SizedBox(height: 50,),
               ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))
              ),
              onPressed: () {
                // Navigate to the FaceDetectionPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => buttonface(faceId: '3v3vs94g6lus',)
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Go to  Face Scanner',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
