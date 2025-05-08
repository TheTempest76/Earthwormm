import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_earthworm/farmer/SellingCrops/orderSummay.dart';

class AICropAnalysisPage extends StatefulWidget {
  final Map<String, dynamic> formData;

  const AICropAnalysisPage({Key? key, required this.formData}) : super(key: key);

  @override
  _AICropAnalysisPageState createState() => _AICropAnalysisPageState();
}

class _AICropAnalysisPageState extends State<AICropAnalysisPage> {
  int currentImageIndex = 0;
  List<String> cloudinaryUrls = [];
  List<Map<String, dynamic>> analysisResults = [];
  bool isLoading = false;
  String selectedLanguage = 'English';
  
  final Map<String, Map<String, String>> translations = {
    'English': {
      'title': 'AI Quality Analysis',
      'instruction': 'Please take 3 clear photos of your crop from different angles',
      'photo': 'Take Photo',
      'gallery': 'Choose from Gallery',
      'progress': 'Photo of 3',
      'analyzing': 'Analyzing image...',
      'upload': 'Uploading image...',
      'next': 'Next Photo',
      'complete': 'Complete Analysis',
    },
    'हिंदी': {
      'title': 'एआई गुणवत्ता विश्लेषण',
      'instruction': 'कृपया अपनी फसल की 3 स्पष्ट तस्वीरें अलग-अलग कोणों से लें',
      'photo': 'फोटो लें',
      'gallery': 'गैलरी से चुनें',
      'progress': 'फोटो  में से 3',
      'analyzing': 'छवि का विश्लेषण किया जा रहा है...',
      'upload': 'छवि अपलोड की जा रही है...',
      'next': 'अगली फोटो',
      'complete': 'विश्लेषण पूरा करें',
    },
    'ಕನ್ನಡ': {
      'title': 'AI ಗುಣಮಟ್ಟ ವಿಶ್ಲೇಷಣೆ',
      'instruction': 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಬೆಳೆಯ 3 ಸ್ಪಷ್ಟ ಫೋಟೋಗಳನ್ನು ವಿಭಿನ್ನ ಕೋನಗಳಿಂದ ತೆಗೆದುಕೊಳ್ಳಿ',
      'photo': 'ಫೋಟೋ ತೆಗೆಯಿರಿ',
      'gallery': 'ಗ್ಯಾಲರಿಯಿಂದ ಆಯ್ಕೆಮಾಡಿ',
      'progress': 'ಫೋಟೋ / 3',
      'analyzing': 'ಚಿತ್ರವನ್ನು ವಿಶ್ಲೇಷಿಸಲಾಗುತ್ತಿದೆ...',
      'upload': 'ಚಿತ್ರವನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಲಾಗುತ್ತಿದೆ...',
      'next': 'ಮುಂದಿನ ಫೋಟೋ',
      'complete': 'ವಿಶ್ಲೇಷಣೆ ಪೂರ್ಣಗೊಳಿಸಿ',
    },
  };

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

  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    final url = Uri.parse('https://crop-analysis-440160446921.us-central1.run.app/predict');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  Map<String, double> calculateAverageResults() {
    Map<String, double> averages = {};
    // Parameters to consider for average (excluding Damaged)
    final parameters = [
      'Batch_Consistency', 'Color', 'Firmness',
      'Shape_and_Size', 'Texture'
    ];

    // Calculate individual parameter averages
    for (var param in parameters) {
      double sum = 0;
      for (var result in analysisResults) {
        sum += (result[param] ?? 0) * 10 + 1;
      }
      averages[param] = sum / analysisResults.length;
    }

    // Add damaged score separately (not included in overall average)
    double damagedSum = 0;
    for (var result in analysisResults) {
      damagedSum += (result['Damaged'] ?? 0) * 10+ 1;
    }
    averages['Damaged'] = damagedSum / analysisResults.length;

    // Calculate overall quality as average of parameters (excluding Damaged)
    double totalSum = parameters.fold(0.0, (sum, param) => sum + averages[param]!);
    averages['Overall_Quality'] = totalSum / parameters.length;

    return averages;
  }

  Future<void> processImage(ImageSource source) async {
    try {
      setState(() => isLoading = true);
      
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      
      if (image == null) {
        setState(() => isLoading = false);
        return;
      }

      // Show uploading status
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translations[selectedLanguage]!['upload']!)),
      );

      // Upload to Cloudinary
      final cloudinaryUrl = await uploadToCloudinary(File(image.path));
      cloudinaryUrls.add(cloudinaryUrl);

      // Show analyzing status
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translations[selectedLanguage]!['analyzing']!)),
      );

      // Analyze image
      final analysis = await analyzeImage(image.path);
      analysisResults.add(analysis);

      // Update progress
      setState(() {
        currentImageIndex++;
        isLoading = false;
      });

      // If all images are processed, save to Firebase and show results
      if (currentImageIndex == 3) {
        await saveToFirebase();
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

    Future<void> saveToFirebase() async {
    try {
      final averageResults = calculateAverageResults();
      final mspDetails = widget.formData['cropDetails']['mspCompliance'];
      final expectedPrice = widget.formData['cropDetails']['expectedPrice'] as double;

      final cropSaleRef = await FirebaseFirestore.instance
          .collection('crop_analysis')
          .add({
            'userId': widget.formData['farmerDetails']['farmerId'],
            'farmerName': widget.formData['farmerDetails']['name'],
            'farmerPhone': widget.formData['farmerDetails']['phone'],
            'cropType': widget.formData['cropDetails']['cropType'],
            'quantity': widget.formData['cropDetails']['weight'],
            'expectedPrice': expectedPrice,
            'location': {
              'state': widget.formData['location']['state'],
              'district': widget.formData['location']['district'],
              'apmcMarket': widget.formData['location']['apmcMarket'],
            },
            // Add MSP details
            'mspDetails': {
              'mspPrice': mspDetails['mspPrice'],
              'isAboveMSP': mspDetails['isAboveMSP'],
              'mspDifference': expectedPrice - (mspDetails['mspPrice'] as num),
              'percentageAboveMSP': ((expectedPrice - (mspDetails['mspPrice'] as num)) / (mspDetails['mspPrice'] as num) * 100).toStringAsFixed(2) + '%'
            },
            'imageUrls': cloudinaryUrls,
            'analysisResults': analysisResults,
            'averageResults': averageResults,
            'isGroupFarming': widget.formData['groupFarming']['isGroupFarming'],
            'groupMembers': widget.formData['groupFarming']['members'],
            'address': widget.formData['address'],
            'description': widget.formData['description'],
            'status': 'pending',
            'timestamp': FieldValue.serverTimestamp(),
          });

      // Create a new Map to avoid modifying widget.formData directly
    final updatedFormData = Map<String, dynamic>.from(widget.formData);
      updatedFormData['analysisResults'] = {
        'imageUrls': cloudinaryUrls,
        'results': averageResults,
        'analysisId': cropSaleRef.id
      };

      // Navigate to results
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(
            averages: averageResults,
            cropType: widget.formData['cropDetails']['cropType'],
            imageUrls: cloudinaryUrls,
            formData: updatedFormData,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving analysis: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translations[selectedLanguage]!['title']!),
        backgroundColor: Colors.green,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<String>(
              value: selectedLanguage,
              dropdownColor: Colors.green,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              icon: const Icon(Icons.language, color: Colors.white),
              underline: Container(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => selectedLanguage = newValue);
                }
              },
              items: ['English', 'हिंदी', 'ಕನ್ನಡ'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: selectedLanguage == value ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LinearProgressIndicator(
                value: currentImageIndex / 3,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 20),
              
              Text(
                translations[selectedLanguage]!['instruction']!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Text(
                translations[selectedLanguage]!['progress']!
                    .replaceAll('{}', (currentImageIndex + 1).toString()),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),

              if (!isLoading && currentImageIndex < 3) ...[
                ElevatedButton.icon(
                  onPressed: () => processImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: Text(translations[selectedLanguage]!['photo']!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => processImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: Text(translations[selectedLanguage]!['gallery']!),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],

              if (isLoading)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      translations[selectedLanguage]!['analyzing']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),

              if (cloudinaryUrls.isNotEmpty) ...[
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: cloudinaryUrls
                        .map((url) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),))
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


class ResultsPage extends StatelessWidget {
  final Map<String, double> averages;
  final String cropType;
  final List<String> imageUrls;
  final Map<String, dynamic> formData;

  const ResultsPage({
    Key? key,
    required this.averages,
    required this.cropType,
    required this.imageUrls,
    required this.formData,
  }) : super(key: key);

   Future<void> _saveSaleDetails(BuildContext context, bool isDirectSale) async {
    try {
      final cropWeight = formData['cropDetails']['weight'] as double;
      if (cropWeight < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Minimum quantity of 1 quintal required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final expectedPrice = formData['cropDetails']['expectedPrice'] as double;
      final mspDetails = formData['cropDetails']['mspCompliance'];

      final docRef = await FirebaseFirestore.instance.collection('crop_sales').add({
        'userId': formData['farmerDetails']['farmerId'],
        'farmerName': formData['farmerDetails']['name'],
        'farmerPhone': formData['farmerDetails']['phone'],
        'cropType': cropType,
        'quantity': cropWeight,
        'expectedPrice': expectedPrice,
        'location': formData['location'],
        // Add MSP details
        'mspDetails': {
          'mspPrice': mspDetails['mspPrice'],
          'isAboveMSP': mspDetails['isAboveMSP'],
          'mspDifference': expectedPrice - (mspDetails['mspPrice'] as num),
          'percentageAboveMSP': ((expectedPrice - (mspDetails['mspPrice'] as num)) / (mspDetails['mspPrice'] as num) * 100).toStringAsFixed(2) + '%'
        },
        'isDirectSale': isDirectSale,
        'qualityScore': averages['Overall_Quality'],
        'analysisDetails': formData['analysisResults'],
        'isGroupFarming': formData['groupFarming']['isGroupFarming'],
        'groupMembers': formData['groupFarming']['members'],
        'address': formData['address'],
        'description': formData['description'],
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrls': imageUrls,
        'orderNumber': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      });

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSummaryPage(
              formData: formData,
              qualityScores: averages,
              imageUrls: imageUrls,
              isDirectSale: isDirectSale,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Carousel
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Overall Score Card
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Overall Quality Score',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                       FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: averages['Overall_Quality']! >= 7 ? Colors.green : 
                               averages['Overall_Quality']! >= 5 ? Colors.orange : Colors.red,
                      ),
                      child: Center(
                        child: Text(
                          '${averages['Overall_Quality']!.toStringAsFixed(1)}/10',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Detailed Analysis Card
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detailed Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...averages.entries
                        .where((e) => e.key != 'Overall_Quality')
                        .map((e) => Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      e.key.replaceAll('_', ' '),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '${e.value.toStringAsFixed(1)}/10',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: e.value / 10,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      e.value >= 7 ? Colors.green :
                                      e.value >= 5 ? Colors.orange : Colors.red,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            )).toList(),
                  ],
                ),
              ),
            ),
        // Recommended Price Card
        Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              'Recommended Price',
              style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
         
            Text(
              'Based on the analysis, the recommended price for your crop is:( formula used : rating * 10% of max price * scaling factor(1.05))',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
               ((formData['cropDetails']['marketPrice']['max'] as double) *((averages['Overall_Quality'] as double)/10 )* 1.05).toStringAsFixed(2),
              style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
              ),
            ),
            ],
          ),
          ),
        ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _saveSaleDetails(context, true),
                    icon: const Icon(Icons.sell),
                    label: const Text('Place for Direct Sale'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _saveSaleDetails(context, false),
                    icon: const Icon(Icons.gavel),
                    label: const Text('Place for Bidding'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}