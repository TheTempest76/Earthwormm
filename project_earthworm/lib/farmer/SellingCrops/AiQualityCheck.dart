import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AICropAnalysisPage extends StatefulWidget {
  final Map<String, dynamic> formData;

  const AICropAnalysisPage({super.key, required this.formData});

  @override
  State<AICropAnalysisPage> createState() => _AICropAnalysisPageState();
}

class _AICropAnalysisPageState extends State<AICropAnalysisPage> {
  bool _isLoading = false;
  String _geminiResponse = '';
  File? _image;
  bool _analysisDone = false;
  String? _cloudinaryImageUrl;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _geminiResponse = '';
        _analysisDone = false;
        _cloudinaryImageUrl = null;
      });
    }
  }

  Future<String> uploadToCloudinary(File imageFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/des6gx3es/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'xy1q3pre'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final jsonData = jsonDecode(response.body);
    return jsonData['secure_url'];
  }

  Future<void> _analyzeImageWithGemini() async {
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
      // Upload image to Cloudinary first
      final cloudinaryUrl = await uploadToCloudinary(_image!);
      _cloudinaryImageUrl = cloudinaryUrl;

      // Then analyze with Gemini
      final base64Image = base64Encode(_image!.readAsBytesSync());

      final promptText = '''
You are a demo crop quality and health analyzer, based on the image and the parameters evaluate and give a score out of 10 be strict.Be very short.

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

reply with just one character the number i.e the score out of 10
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
        final String score = responseData['candidates'][0]['content']['parts'][0]['text'].trim();

        setState(() {
          _geminiResponse = score;
          _analysisDone = true;
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

  Future<void> _submitToFirestore() async {
    if (!_analysisDone || _geminiResponse.isEmpty || _cloudinaryImageUrl == null) return;

    try {
      final dataToSave = {
        'timestamp': FieldValue.serverTimestamp(),
        'location': widget.formData['location'],
        'cropDetails': widget.formData['cropDetails'],
        'score': _geminiResponse,
        'imageUrl': _cloudinaryImageUrl,
      };

      await FirebaseFirestore.instance.collection('crop_analysis').add(dataToSave);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crop analysis submitted successfully!')),
      );

      setState(() {
        _analysisDone = false;
        _image = null;
        _geminiResponse = '';
        _cloudinaryImageUrl = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving to Firestore: $e')),
      );
    }
  }

  Widget _buildScoreCard(String score) {
    int? scoreValue = int.tryParse(score.trim());

    if (scoreValue == null || scoreValue < 0 || scoreValue > 10) {
      return Text(
        'Invalid score received: $score',
        style: const TextStyle(color: Colors.red),
      );
    }

    Color cardColor;
    String label;

    if (scoreValue >= 8) {
      cardColor = Colors.green.shade600;
      label = "Excellent Crop Quality";
    } else if (scoreValue >= 5) {
      cardColor = Colors.amber.shade700;
      label = "Moderate Quality";
    } else {
      cardColor = Colors.red.shade600;
      label = "Poor Quality";
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Text(
                scoreValue.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: cardColor,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              _buildScoreCard(_geminiResponse),
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
            if (!_analysisDone)
              ElevatedButton(
                onPressed: _analyzeImageWithGemini,
                child: const Text('Analyze Crop Health'),
              ),
            if (_analysisDone)
              ElevatedButton(
                onPressed: _submitToFirestore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Submit Analysis'),
              ),
          ],
        ),
      ),
    );
  }
}
