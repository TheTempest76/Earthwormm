import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'dart:async';  // Add this for Completer and StreamSubscription


enum Language { English, Kannada, Hindi }

class CropAnalysisScreen extends StatefulWidget {
  @override
  _CropAnalysisScreenState createState() => _CropAnalysisScreenState();
}

class _CropAnalysisScreenState extends State<CropAnalysisScreen> {
  Language _selectedLanguage = Language.English;
  String _aiCropSuggestion = '';
  String _seedVarietyDetails = '';
  String _geminiResponseForCrop = '';
  String _geminiResponseForVariety = '';
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingCrop = false;
  bool _isPlayingVariety = false;

  // Define translations for the texts
  final Map<Language, Map<String, String>> _localizedStrings = {
    Language.English: {
      'ai_crop_suggestion': 'AI Crop Suggestion',
      'n_label': 'Nitrogen (N)',
      'p_label': 'Phosphorus (P)',
      'k_label': 'Potassium (K)',
      'temperature_label': 'Temperature (°C)',
      'humidity_label': 'Humidity (%)',
      'ph_label': 'pH',
      'rainfall_label': 'Rainfall (mm)',
      'get_suggestion': 'Get Suggestion',
      'seed_variety_analyzer': 'Seed Variety Analyzer',
      'crop_name': 'Crop Name',
      'state': 'State',
      'search': 'Search',
      'description': 'Description',
      'features': 'Features',
      'states': 'States',
      'translator': 'Select Language',
      'gemini_explanation': 'Gemini API Explanation',
    },
    Language.Kannada: {
      'ai_crop_suggestion': 'ಎಐ ಬೆಳೆ ಸಲಹೆ',
      'n_label': 'ನೈಟ್ರೋಜನ್ (N)',
      'p_label': 'ಫಾಸ್ಪರಸ್ (P)',
      'k_label': 'ಪೊಟ್ಯಾಸಿಯಮ್ (K)',
      'temperature_label': 'ತಾಪಮಾನ (°C)',
      'humidity_label': 'ಆರ್ದ್ರತೆ (%)',
      'ph_label': 'pH',
      'rainfall_label': 'ಮಳೆ (mm)',
      'get_suggestion': 'ಸಲಹೆ ಪಡೆಯಿರಿ',
      'seed_variety_analyzer': 'ಬೀಜ ವೈವಿಧ್ಯತೆಗಳು ವಿಶ್ಲೇಷಣೆ',
      'crop_name': 'ಬೆಳೆ ಹೆಸರು',
      'state': 'ರಾಜ್ಯ',
      'search': 'ಹುಡುಕು',
      'description': 'ವಿವರಣೆ',
      'features': 'ಲಕ್ಷಣಗಳು',
      'states': 'ರಾಜ್ಯಗಳು',
      'translator': 'ಭಾಷೆಯನ್ನು ಆಯ್ಕೆ ಮಾಡಿ',
      'gemini_explanation': 'ಜೆಮಿನಿ ಎಪಿಐ ವಿವರಣೆ',
    },
    Language.Hindi: {
      'ai_crop_suggestion': 'एआई फसल सुझाव',
      'n_label': 'नाइट्रोजन (N)',
      'p_label': 'फॉस्फोरस (P)',
      'k_label': 'पोटाशियम (K)',
      'temperature_label': 'तापमान (°C)',
      'humidity_label': 'नमी (%)',
      'ph_label': 'pH',
      'rainfall_label': 'वर्षा (mm)',
      'get_suggestion': 'सुझाव प्राप्त करें',
      'seed_variety_analyzer': 'बीज वैराइटी विश्लेषिका',
      'crop_name': 'फसल का नाम',
      'state': 'राज्य',
      'search': 'खोज',
      'description': 'विवरण',
      'features': 'विशेषताएँ',
      'states': 'राज्य',
      'translator': 'भाषा चुनें',
      'gemini_explanation': 'जेमिनी एपीआई विवरण',
    },
  };

  final TextEditingController _nController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  final TextEditingController _kController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();

  String _selectedCrop = 'Rice';
  String _selectedState = 'Punjab';

  @override
  void dispose() {
    _audioPlayer.dispose();
    _nController.dispose();
    _pController.dispose();
    _kController.dispose();
    _temperatureController.dispose();
    _humidityController.dispose();
    _phController.dispose();
    _rainfallController.dispose();
    super.dispose();
  }

  Future<void> _textToSpeech(String text, bool isForCrop) async {
    // Split text into chunks of approximately 4800 bytes (leaving buffer for encoding)
    List<String> chunks = _splitTextIntoChunks(text);
    
    try {
      setState(() {
        if (isForCrop) {
          _isPlayingCrop = true;
        } else {
          _isPlayingVariety = true;
        }
      });

      // Play each chunk sequentially
      for (String chunk in chunks) {
        if (!(isForCrop ? _isPlayingCrop : _isPlayingVariety)) {
          break; // Stop if play state has changed
        }

        final response = await http.post(
          Uri.parse('https://texttospeech.googleapis.com/v1/text:synthesize?key=AIzaSyDBXE3N7aHSOfpxgV9qVNXsy0F20MfsXIg'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'input': {'text': chunk},
            'voice': {
              'languageCode': _selectedLanguage == Language.Hindi ? 'hi-IN' :
                            _selectedLanguage == Language.Kannada ? 'kn-IN' : 'en-US',
              'name': _selectedLanguage == Language.Hindi ? 'hi-IN-Wavenet-C' :
                      _selectedLanguage == Language.Kannada ? 'kn-IN-Wavenet-A' : 'en-US-Wavenet-D',
            },
            'audioConfig': {
              'audioEncoding': 'MP3',
              'pitch': 0,
              'speakingRate': 1,
            },
          }),
        );

        if (response.statusCode == 200) {
          final audioContent = json.decode(response.body)['audioContent'];
          final audioBytes = base64.decode(audioContent);
          final audioUrl = Uri.dataFromBytes(audioBytes, mimeType: 'audio/mp3').toString();

          await _audioPlayer.setUrl(audioUrl);
          await _audioPlayer.play();
          
          // Wait for the current chunk to finish playing
          await _waitForCompletion();
        } else {
          print('Failed to convert chunk to speech: ${response.body}');
          break;
        }
      }
    } catch (e) {
      print('Error in text to speech: $e');
    } finally {
      setState(() {
        if (isForCrop) {
          _isPlayingCrop = false;
        } else {
          _isPlayingVariety = false;
        }
      });
    }
  }

  Future<void> _waitForCompletion() async {
    Completer<void> completer = Completer<void>();
    
    StreamSubscription? subscription;
    subscription = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    await completer.future;
  }

  List<String> _splitTextIntoChunks(String text) {
    List<String> chunks = [];
    const int maxBytes = 4800; // Buffer for encoding overhead
    
    while (text.isNotEmpty) {
      String chunk = text;
      
      // If text is longer than max bytes, find a good breaking point
      if (text.length > maxBytes) {
        chunk = text.substring(0, maxBytes);
        
        // Try to break at sentence end
        int lastPeriod = chunk.lastIndexOf('. ');
        if (lastPeriod != -1) {
          chunk = text.substring(0, lastPeriod + 1);
        } else {
          // If no sentence break, try to break at comma
          int lastComma = chunk.lastIndexOf(', ');
          if (lastComma != -1) {
            chunk = text.substring(0, lastComma + 1);
          } else {
            // If no comma, break at last space
            int lastSpace = chunk.lastIndexOf(' ');
            if (lastSpace != -1) {
              chunk = text.substring(0, lastSpace);
            }
          }
        }
      }
      
      chunks.add(chunk);
      text = text.substring(chunk.length).trim();
    }
    
    return chunks;
  }
  Future<void> _fetchAICropSuggestion() async {
    try {
      final response = await http.post(
        Uri.parse("https://crop-prediction-apij.onrender.com/predict"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "N": int.tryParse(_nController.text) ?? 0,
          "P": int.tryParse(_pController.text) ?? 0,
          "K": int.tryParse(_kController.text) ?? 0,
          "temperature": double.tryParse(_temperatureController.text) ?? 0,
          "humidity": double.tryParse(_humidityController.text) ?? 0,
          "ph": double.tryParse(_phController.text) ?? 0,
          "rainfall": double.tryParse(_rainfallController.text) ?? 0,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          final prediction = responseData['prediction'];
          final confidence = responseData['confidence'];
          _aiCropSuggestion = "Suggested Crop: $prediction with confidence: $confidence.";
          _fetchGeminiResponseForCrop(prediction);
        });
      } else {
        setState(() {
          _aiCropSuggestion = "Failed to fetch suggestion. Status code: ${response.statusCode}, Body: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _aiCropSuggestion = "Error fetching suggestion: $e";
      });
    }
  }

  Future<void> _fetchGeminiResponseForCrop(String cropPrediction) async {
    String prompt = "Give me detailed information about $cropPrediction as a crop including its benefits, growing conditions, and best practices.";
    await _fetchGeminiResponse(prompt, true);
  }

  Future<void> _fetchSeedVarietyDetails() async {
    try {
      final response = await http.get(
        Uri.parse("https://seed-varities.onrender.com/advanced-search?crop_type=$_selectedCrop&state=$_selectedState"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          if (data.isNotEmpty) {
            final variety = data[0];
            _seedVarietyDetails = "Name: ${variety['Name of Variety']}, "
                "Features: ${variety['Salient Features']}, "
                "States: ${variety['States']}";
            _fetchGeminiResponseForVariety(variety['Name of Variety']);
          } else {
            _seedVarietyDetails = "No varieties found.";
          }
        });
      } else {
        setState(() {
          _seedVarietyDetails = "Failed to fetch seed variety details. Status code: ${response.statusCode}, Body: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _seedVarietyDetails = "Error fetching seed varieties: $e";
      });
    }
  }

  Future<void> _fetchGeminiResponseForVariety(String varietyName) async {
    String prompt = "Provide detailed information about the seed variety: $varietyName including its benefits and cultivation practices.";
    await _fetchGeminiResponse(prompt, false);
  }

  Future<void> _fetchGeminiResponse(String prompt, bool isForCrop) async {
    try {
      final response = await http.post(
        Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyCAGtWDRBB3dQf9eqiJLqAsjrUHpQB3seI"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          String geminiResponse = responseData['candidates']?[0]['content']?['parts']?[0]['text'] ?? "No additional information found.";
          if (isForCrop) {
            _geminiResponseForCrop = geminiResponse;
          } else {
            _geminiResponseForVariety = geminiResponse;
          }
        });
      } else {
        setState(() {
          if (isForCrop) {
            _geminiResponseForCrop = "Failed to fetch Gemini response. Status code: ${response.statusCode}, Body: ${response.body}";
          } else {
            _geminiResponseForVariety = "Failed to fetch Gemini response. Status code: ${response.statusCode}, Body: ${response.body}";
          }
        });
      }
    } catch (e) {
      setState(() {
        if (isForCrop) {
          _geminiResponseForCrop = "Error fetching Gemini response: $e";
        } else {
          _geminiResponseForVariety = "Error fetching Gemini response: $e";
        }
      });
    }
  }

  void _switchLanguage(Language? newLanguage) {
    if (newLanguage != null) {
      setState(() {
        _selectedLanguage = newLanguage;
      });
    }
  }

  Widget _buildGeminiResponse(String response, bool isForCrop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          response.isEmpty ? 
            "No details from Gemini." : 
            response,
          style: TextStyle(fontSize: 16),
        ),
        if (response.isNotEmpty)
          ElevatedButton.icon(
            onPressed: isForCrop && _isPlayingCrop || !isForCrop && _isPlayingVariety ?
              () => _audioPlayer.stop() :
              () => _textToSpeech(response, isForCrop),
            icon: Icon(
              isForCrop && _isPlayingCrop || !isForCrop && _isPlayingVariety ?
                Icons.stop : Icons.play_arrow
            ),
            label: Text(
              isForCrop && _isPlayingCrop || !isForCrop && _isPlayingVariety ?
                'Stop' : 'Listen'
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF66BB6A),
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }
@override
  Widget build(BuildContext context) {
    final Color primaryGreen = Color(0xFF66BB6A);
    final Color secondaryGreen = Color(0xFF1B5E20);
    final Color backgroundColor = Color(0xFFF1F8E9);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Crop Analysis'),
        backgroundColor: primaryGreen,
        actions: [
          DropdownButton<Language>(
            value: _selectedLanguage,
            items: Language.values.map((Language language) {
              return DropdownMenuItem<Language>(
                value: language,
                child: Text(
                  language.toString().split('.').last,
                  style: TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
            onChanged: _switchLanguage,
            dropdownColor: Colors.white,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              // AI Crop Suggestion Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _localizedStrings[_selectedLanguage]!['ai_crop_suggestion']!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: secondaryGreen,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _nController,
                      decoration: InputDecoration(
                        labelText: _localizedStrings[_selectedLanguage]!['n_label'],
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _pController,
                      decoration: InputDecoration(
                        labelText: _localizedStrings[_selectedLanguage]!['p_label'],
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _kController,
                      decoration: InputDecoration(
                        labelText: _localizedStrings[_selectedLanguage]!['k_label'],
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _temperatureController,
                      decoration: InputDecoration(
                        labelText: _localizedStrings[_selectedLanguage]!['temperature_label'],
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _humidityController,
                      decoration: InputDecoration(
                        labelText: _localizedStrings[_selectedLanguage]!['humidity_label'],
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _phController,
                      decoration: InputDecoration(
                        labelText: _localizedStrings[_selectedLanguage]!['ph_label'],
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _rainfallController,
                      decoration: InputDecoration(
                        labelText: _localizedStrings[_selectedLanguage]!['rainfall_label'],
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchAICropSuggestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        _localizedStrings[_selectedLanguage]!['get_suggestion']!,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      _aiCropSuggestion.isEmpty ? "No suggestions available." : _aiCropSuggestion,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    _buildGeminiResponse(_geminiResponseForCrop, true),
                  ],
                ),
              ),
              SizedBox(height: 32),
              // Seed Variety Analyzer Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _localizedStrings[_selectedLanguage]!['seed_variety_analyzer']!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: secondaryGreen,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCrop,
                        isExpanded: true,
                        items: ['Rice', 'Maize', 'Wheat', 'Groundnut', 'Cotton', 'Sugar-Cane']
                            .map((String crop) {
                          return DropdownMenuItem<String>(
                            value: crop,
                            child: Text(crop),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCrop = newValue!;
                          });
                        },
                        hint: Text(_localizedStrings[_selectedLanguage]!['crop_name']!),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedState,
                        isExpanded: true,
                        items: ['Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal']
                            .map((String state) {
                          return DropdownMenuItem<String>(
                            value: state,
                            child: Text(state),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedState = newValue!;
                          });
                        },
                        hint: Text(_localizedStrings[_selectedLanguage]!['state']!),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchSeedVarietyDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        _localizedStrings[_selectedLanguage]!['search']!,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      _seedVarietyDetails.isEmpty ? "No details available." : _seedVarietyDetails,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    _buildGeminiResponse(_geminiResponseForVariety, false),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }}