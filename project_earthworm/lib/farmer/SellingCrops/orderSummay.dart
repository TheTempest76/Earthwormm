// order_summary_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'auction_validation_page.dart';

class OrderSummaryPage extends StatelessWidget {
  final Map<String, dynamic> formData;
  final Map<String, double> qualityScores;
  final List<String> imageUrls;
  final bool isDirectSale;

  const OrderSummaryPage({
    Key? key,
    required this.formData,
    required this.qualityScores,
    required this.imageUrls,
    required this.isDirectSale,
  }) : super(key: key);

  Future<void> _placeOrder(BuildContext context) async {
    try {
      final quantity = formData['cropDetails']['weight'] as double;

      // Add this check at the beginning of the method
      if (!isDirectSale && quantity >= 50) {
        // Navigate to auction setup instead of direct placement
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuctionValidationPage(
              formData: formData,
              qualityScores: qualityScores,
              imageUrls: imageUrls,
              isDirectSale: isDirectSale,
            ),
          ),
        );
        return;
      }
final mspDetails = formData['cropDetails']['mspCompliance'];
      final expectedPrice = formData['cropDetails']['expectedPrice'] as double;
      // Add order to Firestore
     await FirebaseFirestore.instance.collection('orders').add({
        'userId': formData['farmerDetails']['farmerId'],
        'farmerName': formData['farmerDetails']['name'],
        'farmerPhone': formData['farmerDetails']['phone'],
        'cropType': formData['cropDetails']['cropType'],
        'quantity': formData['cropDetails']['weight'],
        'pricePerQuintal': expectedPrice,
        'totalPrice': expectedPrice * formData['cropDetails']['weight'],
        'location': formData['location'],
        'qualityScore': qualityScores['Overall_Quality'],
        'analysisDetails': formData['analysisResults'],
        'imageUrls': imageUrls,
        'isGroupFarming': formData['groupFarming']['isGroupFarming'],
        'groupMembers': formData['groupFarming']['members'],
        'address': formData['address'],
        'description': formData['description'],
        'isDirectSale': isDirectSale,
        'status': 'pending',
        'orderDate': FieldValue.serverTimestamp(),
        // Added MSP related fields
        'mspDetails': {
          'mspPrice': mspDetails['mspPrice'],
          'isAboveMSP': mspDetails['isAboveMSP'],
          'mspDifference': expectedPrice - (mspDetails['mspPrice'] as num),
          'percentageAboveMSP': ((expectedPrice - (mspDetails['mspPrice'] as num)) / (mspDetails['mspPrice'] as num) * 100).toStringAsFixed(2) + '%'
        },
      });
      // Navigate back to home and show success message
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final totalPrice = formData['cropDetails']['expectedPrice'] *
        formData['cropDetails']['weight'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green.shade700, Colors.green.shade500],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Amount: ${currencyFormat.format(totalPrice)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Order Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Crop Details'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                              'Crop Type', formData['cropDetails']['cropType']),
                          _buildDetailRow('Quantity',
                              '${formData['cropDetails']['weight']} quintals'),
                          _buildDetailRow(
                              'Price per Quintal',
                              currencyFormat.format(
                                  formData['cropDetails']['expectedPrice'])),
                          const Divider(),
                          _buildDetailRow('Quality Score',
                              '${qualityScores['Overall_Quality']!.toStringAsFixed(1)}/10',
                              valueColor: _getScoreColor(
                                  qualityScores['Overall_Quality']!)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Farmer Details'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                              'Name', formData['farmerDetails']['name']),
                          _buildDetailRow(
                              'Phone', formData['farmerDetails']['phone']),
                          _buildDetailRow('Address', formData['address']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Location Details'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                              'State', formData['location']['state']),
                          _buildDetailRow(
                              'District', formData['location']['district']),
                          _buildDetailRow('APMC Market',
                              formData['location']['apmcMarket']),
                        ],
                      ),
                    ),
                  ),
                  if (formData['groupFarming']['isGroupFarming']) ...[
                    const SizedBox(height: 16),
                    _buildSectionTitle('Group Farming Details'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildDetailRow(
                                'Number of Members',
                                formData['groupFarming']['members']
                                    .length
                                    .toString()),
                            const Divider(),
                            ...List.generate(
                              formData['groupFarming']['members'].length,
                              (index) => _buildDetailRow('Member ${index + 1}',
                                  '${formData['groupFarming']['members'][index]['name']} - ${formData['groupFarming']['members'][index]['phone']}'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Place Order Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _placeOrder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirm Order',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 7) return Colors.green;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }
}
