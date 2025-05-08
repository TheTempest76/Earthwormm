import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class BuyerQualityCheckPage extends StatefulWidget {
  const BuyerQualityCheckPage({Key? key}) : super(key: key);

  @override
  _BuyerQualityCheckPageState createState() => _BuyerQualityCheckPageState();
}

class _BuyerQualityCheckPageState extends State<BuyerQualityCheckPage> {
  final TextEditingController _userIdController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? orderData;

  // States for image analysis
  int currentImageIndex = 0;
  List<String> cloudinaryUrls = [];
  List<Map<String, dynamic>> analysisResults = [];
  Map<String, dynamic>? comparisonResults;

  // Step 1: Fetch order data using user ID
  Future<void> fetchOrderData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userId = _userIdController.text.trim();
      print('Attempting to fetch order for userId: $userId'); // Debug print

      // Try to fetch from orders collection
      final orderQuery = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      print(
          'Query completed. Found ${orderQuery.docs.length} documents'); // Debug print

      if (orderQuery.docs.isEmpty) {
        // If not found in orders, try crop_sales collection
        final cropSalesQuery = await FirebaseFirestore.instance
            .collection('crop_sales')
            .where('userId', isEqualTo: userId)
            .get();

        print(
            'Checking crop_sales: Found ${cropSalesQuery.docs.length} documents'); // Debug print

        if (cropSalesQuery.docs.isEmpty) {
          throw 'No orders found for this User ID. Please verify the ID and try again.';
        }

        // Use the most recent document from crop_sales
        final docs = cropSalesQuery.docs
          ..sort((a, b) {
            final aDate = a.data()['orderDate'] as Timestamp;
            final bDate = b.data()['orderDate'] as Timestamp;
            return bDate.compareTo(aDate);
          });

        setState(() {
          orderData = docs.first.data();
          isLoading = false;
        });

        print('Found order data: ${orderData!.keys.join(', ')}'); // Debug print
        return;
      }

      // Use the most recent document from orders
      final docs = orderQuery.docs
        ..sort((a, b) {
          final aDate = a.data()['orderDate'] as Timestamp;
          final bDate = b.data()['orderDate'] as Timestamp;
          return bDate.compareTo(aDate);
        });

      setState(() {
        orderData = docs.first.data();
        isLoading = false;
      });

      print('Found order data: ${orderData!.keys.join(', ')}'); // Debug print
    } catch (e) {
      print('Error occurred while fetching order: $e'); // Debug print
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Step 2: Process new images
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

      // Upload to Cloudinary
      final cloudinaryUrl = await uploadToCloudinary(File(image.path));
      cloudinaryUrls.add(cloudinaryUrl);

      // Analyze the image
      final analysis = await analyzeImage(image.path);
      analysisResults.add(analysis);

      setState(() {
        currentImageIndex++;
        isLoading = false;
      });

      // Compare results after 3 images
      if (currentImageIndex == 3) {
        compareResults();
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<String> uploadToCloudinary(File imageFile) async {
    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/des6gx3es/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'xy1q3pre'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body)['secure_url'];
  }

  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    final url = Uri.parse(
        'https://crop-analysis-440160446921.us-central1.run.app/predict');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  void compareResults() {
    final buyerAnalysis = calculateAverageResults();
    final sellerAnalysis = orderData!['analysisDetails']['results'];

    setState(() {
      comparisonResults = {
        'buyer': buyerAnalysis,
        'seller': sellerAnalysis,
        'differences': calculateDifferences(buyerAnalysis, sellerAnalysis),
      };
    });
  }

  Map<String, double> calculateAverageResults() {
    Map<String, double> averages = {};
    final parameters = [
      'Batch_Consistency',
      'Color',
      'Firmness',
      'Shape_and_Size',
      'Texture'
    ];

    for (var param in parameters) {
      double sum = 0;
      for (var result in analysisResults) {
        sum += (result[param] ?? 0) * 10 + 1;
      }
      averages[param] = sum / analysisResults.length;
    }

    // Calculate damaged score
    double damagedSum = 0;
    for (var result in analysisResults) {
      damagedSum += (result['Damaged'] ?? 0) * 10 + 1;
    }
    averages['Damaged'] = damagedSum / analysisResults.length;

    // Calculate overall quality
    double totalSum =
        parameters.fold(0.0, (sum, param) => sum + averages[param]!);
    averages['Overall_Quality'] = totalSum / parameters.length;

    return averages;
  }

  Map<String, double> calculateDifferences(
    Map<String, double> buyerResults,
    Map<String, dynamic> sellerResults,
  ) {
    Map<String, double> differences = {};

    buyerResults.forEach((key, buyerValue) {
      final sellerValue = sellerResults[key] is num
          ? (sellerResults[key] as num).toDouble()
          : 0.0;
      differences[key] = buyerValue - sellerValue;
    });

    return differences;
  }

  Future<void> submitFeedback() async {
    if (comparisonResults == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete quality analysis first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Feedback'),
        content: TextField(
          controller: feedbackController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter your feedback about the quality...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('farmer_feedback')
                    .add({
                  'userId': orderData!['userId'],
                  'cropType': orderData!['cropType'],
                  'feedback': feedbackController.text,
                  'buyerImages': cloudinaryUrls,
                  'sellerImages': orderData!['imageUrls'],
                  'buyerAnalysis': comparisonResults!['buyer'],
                  'sellerAnalysis': comparisonResults!['seller'],
                  'qualityDifferences': comparisonResults!['differences'],
                  'timestamp': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Feedback submitted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> reportIssue() async {
    if (comparisonResults == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete quality analysis first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String selectedReason = 'Quality Misrepresentation';
    final TextEditingController detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedReason,
              decoration: const InputDecoration(
                labelText: 'Issue Type',
                border: OutlineInputBorder(),
              ),
              items: [
                'Quality Misrepresentation',
                'Significant Quality Difference',
                'Product Damage',
                'Other',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedReason = value;
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: detailsController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the issue in detail...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('farmer_reports')
                    .add({
                  'userId': orderData!['userId'],
                  'cropType': orderData!['cropType'],
                  'reason': selectedReason,
                  'details': detailsController.text,
                  'buyerImages': cloudinaryUrls,
                  'sellerImages': orderData!['imageUrls'],
                  'buyerAnalysis': comparisonResults!['buyer'],
                  'sellerAnalysis': comparisonResults!['seller'],
                  'qualityDifferences': comparisonResults!['differences'],
                  'timestamp': FieldValue.serverTimestamp(),
                  'status': 'pending',
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Report submitted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Check'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step 1: User ID Input
            if (orderData == null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Enter Order ID',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _userIdController,
                        decoration: InputDecoration(
                          labelText: 'order ID',
                          border: const OutlineInputBorder(),
                          errorText: errorMessage,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isLoading ? null : fetchOrderData,
                        child: Text(isLoading ? 'Verifying...' : 'Verify'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Step 2: Order Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crop: ${orderData!['cropType']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Quantity: ${orderData!['quantity']} quintals',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Status: ${orderData!['status']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Step 3: Original Images
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Original Images',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: orderData!['imageUrls'].length,
                          itemBuilder: (context, index) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              orderData!['imageUrls'][index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Step 4: New Image Upload
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Take New Photos (${currentImageIndex}/3)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!isLoading && currentImageIndex < 3) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    processImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Take Photo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    processImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('From Gallery'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      if (cloudinaryUrls.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: cloudinaryUrls.length,
                            itemBuilder: (context, index) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 120,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.network(
                                cloudinaryUrls[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Step 5: Quality Comparison
              if (comparisonResults != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quality Comparison',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...[
                          'Overall_Quality',
                          'Batch_Consistency',
                          'Color',
                          'Firmness',
                          'Shape_and_Size',
                          'Texture',
                          'Damaged'
                        ].map((parameter) {
                          final buyerValue = (comparisonResults!['buyer']
                                  as Map<String, double>)[parameter] ??
                              0.0;
                          final sellerValue =
                              (comparisonResults!['seller'][parameter] as num)
                                  .toDouble();
                          final difference = (comparisonResults!['differences']
                                  as Map<String, double>)[parameter] ??
                              0.0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                parameter.replaceAll('_', ' '),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Text('Original'),
                                        LinearProgressIndicator(
                                          value: sellerValue / 10,
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            _getQualityColor(sellerValue),
                                          ),
                                          minHeight: 8,
                                        ),
                                        Text(
                                            '${sellerValue.toStringAsFixed(1)}/10'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Text('Current'),
                                        LinearProgressIndicator(
                                          value: buyerValue / 10,
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            _getQualityColor(buyerValue),
                                          ),
                                          minHeight: 8,
                                        ),
                                        Text(
                                            '${buyerValue.toStringAsFixed(1)}/10'),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 60,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: _getDifferenceColor(difference),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      difference >= 0
                                          ? '+${difference.toStringAsFixed(1)}'
                                          : difference.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

              // Step 6: Action Buttons
              if (comparisonResults != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: submitFeedback,
                  icon: const Icon(Icons.feedback),
                  label: const Text('Submit Feedback'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: reportIssue,
                  icon: const Icon(Icons.report_problem, color: Colors.red),
                  label: const Text(
                    'Report Issue',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _getQualityColor(double value) {
    if (value >= 7) return Colors.green;
    if (value >= 5) return Colors.orange;
    return Colors.red;
  }

  Color _getDifferenceColor(double difference) {
    if (difference.abs() < 1) return Colors.grey;
    if (difference > 0) return Colors.green;
    return Colors.red;
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }
}
