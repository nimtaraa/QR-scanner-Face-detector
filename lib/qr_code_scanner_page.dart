import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:face_id/face.dart'; // Ensure this is the correct import for your face detection page
import 'dart:convert';
import 'dart:async';

class QRViewExample extends StatefulWidget {
  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  String qrText = '';
  String serverResponse = '';
  String responsetext = '';
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    requestCameraPermission();
    _startScanning();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Code Scanner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Scan result: $responsetext',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            if (isScanning)
              CircularProgressIndicator()
            else
              Text(
                'Ready to scan',
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  void _startScanning() async {
    setState(() {
      isScanning = true;
    });

    while (true) {
      final scanResult = await _scanQR();
      if (scanResult == '-1') {
        break; // Stop scanning if the user cancels
      }

      if (scanResult.isNotEmpty) {
        await sendQRResultToAPI(scanResult);
        if (serverResponse.contains('Valid QR code')) {
          break; // Stop scanning on successful validation
        }
      }

      await Future.delayed(Duration(seconds: 2)); // Delay before next scan
    }

    setState(() {
      isScanning = false;
    });
  }

  Future<String> _scanQR() async {
    try {
      return await FlutterBarcodeScanner.scanBarcode(
        '#FF0000',
        'Cancel',
        true,
        ScanMode.QR,
      );
    } catch (e) {
      print('Error scanning QR code: $e');
      return '';
    }
  }

  Future<void> sendQRResultToAPI(String qrCode) async {
    final url = Uri.parse('https://api.northstar.mv/api/gym-access/qr');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer aBcDeFgHiJkLmNoP', // Ensure your token is correct
        },
        body: jsonEncode({
          'QR': qrCode,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['QR'] == true) {
          serverResponse = 'Valid QR code';
          await fetchFID(qrCode);
        } else {
          serverResponse = 'Invalid QR code';
          _showInvalidQRDialog();
        }
      } else {
        serverResponse = 'Failed to validate QR code: ${response.statusCode}';
        _showInvalidQRDialog();
      }
    } catch (e) {
      serverResponse = 'Error sending QR code: $e';
      _showInvalidQRDialog();
    }
  }

  Future<void> fetchFID(String qrCode) async {
    final url = Uri.parse('https://api.northstar.mv/api/gym-access/qr');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer aBcDeFgHiJkLmNoP', // Ensure your token is correct
        },
        body: jsonEncode({
          'QR': qrCode,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['FID'] == null) {
          responsetext = "Welcome Fresher : WAITING FOR Getting Face ";
     

          Future.delayed(Duration(seconds: 10), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FaceDetectionPage(faceId: qrCode),
              ),
            );
          });
        } else {
          responsetext = "QR valid, Welcome to GYM, Door can be Accessed";
        }
      } else {
        print('Failed to fetch FID: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching FID: $e');
    }
  }

  void _showInvalidQRDialog() {
    setState(() {
      responsetext = "QR ID Not Valid Please Scan Again";
    });
  }

  void requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }
}

