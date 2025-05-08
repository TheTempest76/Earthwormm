import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_earthworm/farmer/SellingCrops/orderSummay.dart';

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
                        fontWeight: FontWeight.bold,
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
                      ((formData['cropDetails']['marketPrice']['max'] as double) * 
                       (averages['Overall_Quality']! / 10) * 1.05).toStringAsFixed(2),
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
