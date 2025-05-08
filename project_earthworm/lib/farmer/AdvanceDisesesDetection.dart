import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AdvanceDiseasesDetection extends StatefulWidget {
  @override
  _AdvanceDiseasesDetectionState createState() => _AdvanceDiseasesDetectionState();
}

class _AdvanceDiseasesDetectionState extends State<AdvanceDiseasesDetection> {
  String _imageUrl = '';
  String _diseaseDetails = '';
  String _remedyDetails = '';
  Language _selectedLanguage = Language.English;

  final picker = ImagePicker();
  final String cropHealthApiKey = "02FB5GJe3fyNonD9DLB84rQ4AP5nIwrJOQKtZLInOMZZpW30RU"; // Replace with your actual API key
  final String cropHealthApiUrl = "https://crop.kindwise.com/api/v1/identification";
  final String geminiApiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyCAGtWDRBB3dQf9eqiJLqAsjrUHpQB3seI"; // Replace with your Gemini API key

  Future<void> _pickImage(bool fromCamera) async {
    final pickedFile = await picker.pickImage(source: fromCamera ? ImageSource.camera : ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _diseaseDetails = ''; // Clear previous results
        _imageUrl = pickedFile.path; // Use file path for displaying image
      });
      String imagePath = pickedFile.path;
      await _detectPlantDiseases(imagePath);
    }
  }

  Future<void> _detectPlantDiseases(String imagePath) async {
    String base64Image = base64Encode(await File(imagePath).readAsBytes());
    final url = Uri.parse(cropHealthApiUrl);
    final headers = {
      "Api-Key": cropHealthApiKey,
      "Content-Type": "application/json"
    };

    final body = json.encode({
      "images": [base64Image],
      "latitude": 0.0,
      "longitude": 0.0,
      "similar_images": true,
      "custom_id": DateTime.now().millisecondsSinceEpoch,
      "datetime": DateTime.now().toIso8601String(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        String accessToken = data['access_token'];
        await _checkDiseaseResults(accessToken); // Check results with access token
      } else {
        _diseaseDetails = "Failed to detect diseases. Status code: ${response.statusCode}, Body: ${response.body}";
      }
    } catch (e) {
      _diseaseDetails = "Error detecting diseases: $e";
    } finally {
      setState(() {});
    }
  }

  Future<void> _checkDiseaseResults(String accessToken) async {
    final resultsUrl = Uri.parse('https://crop.kindwise.com/api/v1/identification/$accessToken');
    final headers = {
      "Api-Key": cropHealthApiKey,
      "Content-Type": "application/json"
    };

    try {
      final response = await http.get(resultsUrl, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final diseaseSuggestions = data['result']['disease']['suggestions'];
        if (diseaseSuggestions.isNotEmpty) {
          final disease = diseaseSuggestions[0]; // Assume at least one suggestion
          _diseaseDetails = _formatDiseaseDetails(disease);
          await _fetchRemedyDetails(disease['name']); // Fetch remedies based on the disease name
        } else {
          _diseaseDetails = "No disease detected.";
        }
      } else {
        _diseaseDetails = "Failed to retrieve results. Status code: ${response.statusCode}, Body: ${response.body}";
      }
    } catch (e) {
      _diseaseDetails = "Error checking results: $e";
    } finally {
      setState(() {});
    }
  }

  Future<void> _fetchRemedyDetails(String diseaseName) async {
    final headers = {"Content-Type": "application/json"};
    String prompt = '';

    if (_selectedLanguage == Language.English) {
      prompt = "Explain the remedy for $diseaseName in English.";
    } else if (_selectedLanguage == Language.Kannada) {
      prompt = "ರೋಗದ ಹೆಸರು $diseaseName ಕನ್ನಡದಲ್ಲಿ ಚಿಕಿತ್ಸೆ ವಿವರಿಸಿ.";
    } else if (_selectedLanguage == Language.Hindi) {
      prompt = "रोग का नाम $diseaseName हिंदी में उपचार की व्याख्या करें।";
    }

    final payload = {
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    };

    try {
      final response = await http.post(Uri.parse(geminiApiUrl), headers: headers, body: json.encode(payload));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _remedyDetails = data['candidates']?[0]['content']?['parts']?[0]['text'] ?? "No remedy details found.";
      } else {
        _remedyDetails = "Failed to fetch remedies. Status code: ${response.statusCode}, Body: ${response.body}";
      }
    } catch (e) {
      _remedyDetails = "Error fetching remedies: $e";
    } finally {
      setState(() {});
    }
  }

  String _formatDiseaseDetails(Map<String, dynamic> disease) {
    String details = '';
    details += "Name: ${disease['name'] ?? 'N/A'}\n";
    details += "Type: ${disease['type'] ?? 'N/A'}\n";
    details += "Common Names: ${disease['common_names']?.join(', ') ?? 'N/A'}\n";
    details += "Probability: ${disease['probability'] ?? 'N/A'}\n";
    return details;
  }

  @override
  Widget build(BuildContext context) {
    final translations = {
      Language.English: 'This model can detect over 320 diseases in plants. You can upload an image or use the camera to identify plant diseases.\nDetailed information will be provided in English, Kannada, and Hindi.',
      Language.Kannada: 'ಈ ಮಾದರಿಯು ೩೨೦ ಕ್ಕೂ ಹೆಚ್ಚು ಸಸ್ಯಗಳಲ್ಲಿ ಕಾಯಿಲೆಗಳನ್ನು ಪತ್ತೆಮಾಡಬಲ್ಲದು. ನೀವು ಚಿತ್ರವನ್ನು ಅಪ್ಲೋಡ್ ಮಾಡುವುದಾಗಿ ಅಥವಾ ಕ್ಯಾಮೆರಾದ ಉಪಯೋಗಿಸಲು ಬಳಸಬಹುದು.\nಹೆಚ್ಚಿನ ಮಾಹಿತಿಯನ್ನು ಇಂಗ್ಲೀಷ್, ಕನ್ನಡ ಮತ್ತು ಹಿಂದಿಯಲ್ಲಿ ಒದಗಿಸಲಾಗುತ್ತದೆ.',
      Language.Hindi: 'यह मॉडल 320 से अधिक पौधों में बीमारियों का पता लगा सकता है। आप एक छवि अपलोड कर सकते हैं या पौधों की बीमारियों की पहचान के लिए कैमरा का उपयोग कर सकते हैं।\nविस्तृत जानकारी अंग्रेजी, कन्नड़ और हिंदी में प्रदान की जाएगी.',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Disease Detection'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Plant Disease Detection',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              translations[_selectedLanguage]!,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),
            DropdownButton<Language>(
              value: _selectedLanguage,
              onChanged: (Language? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                }
              },
              items: Language.values.map<DropdownMenuItem<Language>>((Language lang) {
                return DropdownMenuItem<Language>(
                  value: lang,
                  child: Text(lang.name),
                );
              }).toList(),
              isExpanded: true,
            ),
            SizedBox(height: 20),
            if (_imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_imageUrl),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(false),
                  icon: Icon(Icons.photo),
                  label: Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 232, 236, 39),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(true),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 166, 215, 166),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_diseaseDetails.isNotEmpty)
              Card(
                color: Colors.grey[200],
                elevation: 4,
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Disease Details:\n\n$_diseaseDetails',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            if (_remedyDetails.isNotEmpty)
              Card(
                color: Colors.lightGreen[50],
                elevation: 4,
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'AI Remedy Details:\n\n$_remedyDetails',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum Language { English, Kannada, Hindi }

extension LanguageExtension on Language {
  String get name {
    switch (this) {
      case Language.English:
        return 'English';
      case Language.Kannada:
        return 'ಕನ್ನಡ';
      case Language.Hindi:
        return 'हिन्दी';
      default:
        return '';
    }
  }
}