import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class TextRecognitionScreen extends StatefulWidget {
  @override
  _TextRecognitionScreenState createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  XFile? pickedImage;
  String mytext = '';
  bool scanning = false;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> getImage(ImageSource source) async {
    XFile? result = await _imagePicker.pickImage(source: source);

    if (result != null) {
      setState(() {
        pickedImage = result;
      });
      performTextRecognition();
    }
  }

  Future<void> performTextRecognition() async {
    setState(() {
      scanning = true;
      mytext = '';
    });

    try {
      final inputImage = InputImage.fromFilePath(pickedImage!.path);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        mytext = recognizedText.text;
        scanning = false;
      });

      textRecognizer.close();
    } catch (e) {
      print('Error: $e');
    }
  }

  void copyTextToClipboard(String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Text copied to clipboard!"),
        ),
      );
    }
  }

  void reset() {
    setState(() {
      pickedImage = null;
      mytext = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Text Recognition',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          if (mytext.isNotEmpty || pickedImage != null) // Conditionally show reset icon
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Reset',
              onPressed: reset,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display Image or Placeholder
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: pickedImage == null
                  ? Center(
                child: Text(
                  'No Image Selected',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(pickedImage!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => getImage(ImageSource.gallery),
                  icon: Icon(Icons.photo, color: Colors.white),
                  label: Text("Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => getImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  label: Text("Camera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Recognized Text Header and Copy Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recognized Text",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: Colors.blueAccent),
                  tooltip: "Copy all text",
                  onPressed: () => copyTextToClipboard(mytext),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Scanning Animation or Text Display
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: scanning
                  ? SpinKitThreeBounce(
                color: Colors.blueAccent,
                size: 24,
              )
                  : mytext.isNotEmpty
                  ? SelectableText(
                mytext,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87),
                textAlign: TextAlign.start,
              )
                  : Text(
                "No text recognized yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}