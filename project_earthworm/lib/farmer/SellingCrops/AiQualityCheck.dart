import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AICropAnalysisPage extends StatefulWidget {
  final Map<String, dynamic> formData;

  const AICropAnalysisPage({super.key, required this.formData});

  @override
  State<AICropAnalysisPage> createState() => _AICropAnalysisPageState();
}

class _AICropAnalysisPageState extends State<AICropAnalysisPage> {
  bool _isLoading = false;
  String _geminiResponse = '';
  File? _image; // Variable to hold the selected image

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Store the picked image
      });
    }
  }

  Future<void> _sendToGemini() async {
    if (_image == null) {
      setState(() {
        _geminiResponse = 'Please upload a crop image before submitting.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final base64Image = base64Encode(_image!.readAsBytesSync()); // Convert the image to base64

      final promptText = '''
Analyze the uploaded crop image and provide a health score out of 10. If not a crop give zero.
Evaluate based on the data provided below be strict and analyze the qulity of the crop health not the image:

Location Details:
- State: ${widget.formData['location']['state']}
- District: ${widget.formData['location']['district']}
- APMC Market: ${widget.formData['location']['apmcMarket']}

Crop Details:
- Crop Type: ${widget.formData['cropDetails']['cropType']}
- Weight: ${widget.formData['cropDetails']['weight']} quintals
- Market Price Range: ₹${widget.formData['cropDetails']['marketPrice']['min']} - ₹${widget.formData['cropDetails']['marketPrice']['max']}/quintal
- Expected Price: ₹${widget.formData['cropDetails']['expectedPrice']}/quintal
- MSP Status: ${widget.formData['cropDetails']['mspCompliance']['isAboveMSP'] ? 'Above MSP' : 'Below MSP'}

Provide the crop's health score along with a short analysis, including any suggestions for improvement.
''';

      final response = await http.post(
        Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyDVgJvXxHMTzH7Jd2IXuOcGMGNp_R8_uX0"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "contents": [
            {
              "parts": [
                {
                  "inlineData": {
                    "mimeType": "image/jpeg",
                    "data": base64Image,
                  }
                },
                {
                  "text": promptText,
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _geminiResponse = responseData['candidates'][0]['content']['parts'][0]['text'];
        });
      } else {
        setState(() {
          _geminiResponse = 'Failed to fetch analysis. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _geminiResponse = 'Error fetching analysis: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Health Analysis'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_geminiResponse.isNotEmpty && !_isLoading)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _geminiResponse,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select Crop Image'),
            ),
            const SizedBox(height: 16),
            if (_image != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(_image!),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendToGemini,
              child: const Text('Analyze Crop Health'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(String title, List<String> details) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...details.map((detail) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                detail,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
