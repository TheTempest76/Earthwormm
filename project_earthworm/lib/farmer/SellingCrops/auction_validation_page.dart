import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'former_auction_status.dart';
import 'dart:async';

class AuctionValidationPage extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Map<String, double> qualityScores;
  final List<String> imageUrls;
  final bool isDirectSale;

  const AuctionValidationPage({
    Key? key,
    required this.formData,
    required this.qualityScores,
    required this.imageUrls,
    required this.isDirectSale,
  }) : super(key: key);

  @override
  _AuctionValidationPageState createState() => _AuctionValidationPageState();
}

class _AuctionValidationPageState extends State<AuctionValidationPage> {
  final _durationController = TextEditingController();
  bool isEligible = false;

  @override
  void initState() {
    super.initState();
    _checkEligibility();
  }

  void _checkEligibility() {
    final quantity = widget.formData['cropDetails']['weight'] as double;
    setState(() {
      isEligible = quantity >= 50;
    });
  }

  Future<void> _createAuction() async {
    if (!isEligible) return;

    try {
      final duration = int.parse(_durationController.text);
      if (duration <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid duration'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final endTime = DateTime.now().add(Duration(minutes: duration));

      final docRef =
          await FirebaseFirestore.instance.collection('auctions').add({
        'cropDetails': {
          'type': widget.formData['cropDetails']['cropType'],
          'quantity': widget.formData['cropDetails']['weight'],
          'basePrice': widget.formData['cropDetails']['expectedPrice'],
        },
        'farmerDetails': {
          'id': widget.formData['farmerDetails']['farmerId'],
          'name': widget.formData['farmerDetails']['name'],
          'phone': widget.formData['farmerDetails']['phone'],
        },
        'location': widget.formData['location'],
        'qualityScore': widget.qualityScores['Overall_Quality'],
        'imageUrls': widget.imageUrls,
        'startTime': FieldValue.serverTimestamp(),
        'endTime': Timestamp.fromDate(endTime),
        'status': 'active',
        'currentBid': widget.formData['cropDetails']['expectedPrice'],
        'currentBidder': null,
        'bids': [],
        'isGroupFarming': widget.formData['groupFarming']['isGroupFarming'],
        'groupMembers': widget.formData['groupFarming']['members'],
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FarmerAuctionStatusPage(auctionId: docRef.id),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Auction Setup',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade600,
              Colors.green.shade50,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: isEligible
                          ? [Colors.green.shade50, Colors.green.shade100]
                          : [Colors.red.shade50, Colors.red.shade100],
                    ),
                  ),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isEligible
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                        ),
                        child: Icon(
                          isEligible ? Icons.check_circle : Icons.error,
                          color: isEligible
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          size: 56,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isEligible
                            ? 'Your crop is eligible for auction!'
                            : 'Minimum 50 quintals required for auction',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isEligible
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      if (!isEligible) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Go Back'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isEligible) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.green.shade50],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer,
                              color: Colors.green.shade700,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Set Auction Duration',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Duration (in minutes)',
                            labelStyle: TextStyle(color: Colors.green.shade700),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.green.shade700,
                                width: 2,
                              ),
                            ),
                            helperText:
                                'Enter how long the auction should last',
                            helperStyle: TextStyle(color: Colors.grey.shade600),
                            prefixIcon: Icon(
                              Icons.access_time,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _createAuction,
                          icon: const Icon(Icons.gavel),
                          label: const Text(
                            'Start Auction',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ],
                    ),
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
