import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'buyer_bidding_page.dart';

class AuctionDetailPage extends StatelessWidget {
  final String auctionId;
  final double currentBid;
  final Map<String, dynamic> auctionData;

  const AuctionDetailPage({
    Key? key,
    required this.auctionId,
    required this.currentBid,
    required this.auctionData,
  }) : super(key: key);

  Widget _buildImageCarousel() {
    final imageUrls = auctionData['imageUrls'];
    return Container(
      height: 300,
      child: Stack(
        children: [
          if (imageUrls == null ||
              (imageUrls is List && imageUrls.isEmpty) ||
              (imageUrls is String && imageUrls.isEmpty))
            Container(
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No images available',
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          else if (imageUrls is String)
            Image.network(
              imageUrls,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(Icons.error_outline, size: 64, color: Colors.red),
              ),
            )
          else if (imageUrls is List)
            PageView.builder(
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(
                  imageUrls[index].toString(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child:
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                  ),
                );
              },
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    imageUrls is List
                        ? '${imageUrls.length} Photos'
                        : '1 Photo',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon,
      {Color? color}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1) ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color ?? Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerDetails(Map<String, dynamic> farmerDetails) {
    // Get the farmer ID from farmerDetails
    final farmerId = farmerDetails['id'];

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('farmers')
          .doc(farmerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
        }

        // Merge the Firestore farmer data with existing farmerDetails
        final firestoreFarmerData =
            snapshot.data!.data() as Map<String, dynamic>? ?? {};

        // Convert GeoPoint to string if it exists
        String locationStr = '';
        if (firestoreFarmerData['location'] is GeoPoint) {
          final location = firestoreFarmerData['location'] as GeoPoint;
          locationStr =
              '${location.latitude.toStringAsFixed(6)}° N, ${location.longitude.toStringAsFixed(6)}° E';
        }

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green[100],
                    child: farmerDetails['photoUrl'] != null
                        ? ClipOval(
                            child: Image.network(
                              farmerDetails['photoUrl'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.person,
                                      size: 30, color: Colors.green),
                            ),
                          )
                        : Icon(Icons.person, size: 30, color: Colors.green),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firestoreFarmerData['name'] ??
                              farmerDetails['name'] ??
                              'Unknown Farmer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (farmerDetails['experience'] != null)
                          Text(
                            '${farmerDetails['experience']} years of farming experience',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildFarmerInfoRow(Icons.agriculture, 'Farming Method',
                  firestoreFarmerData['farmingMethod'] ?? 'Not specified'),
              _buildFarmerInfoRow(
                  Icons.landscape,
                  'Land Size',
                  firestoreFarmerData['landSize'] != null
                      ? '${firestoreFarmerData['landSize']} acres'
                      : 'Not specified'),
              _buildFarmerInfoRow(Icons.location_on, 'Location',
                  locationStr.isNotEmpty ? locationStr : 'Not specified'),
              _buildFarmerInfoRow(Icons.phone, 'Phone', farmerDetails['phone']),
              _buildFarmerInfoRow(Icons.location_on, 'Address',
                  '${farmerDetails['address'] ?? ''}, ${farmerDetails['district'] ?? ''}, ${farmerDetails['state'] ?? ''}'),
              if (farmerDetails['certifications'] != null)
                _buildFarmerInfoRow(Icons.verified, 'Certifications',
                    farmerDetails['certifications'].join(', ')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFarmerInfoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return SizedBox();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green[700]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, Map<String, dynamic> auctionData) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final status = auctionData['status'] ?? 'active';
    final winnerId = auctionData['winner'] is Map
        ? auctionData['winner']['id']
        : auctionData['winner'];

    // Calculate total amount
    final quantity = (auctionData['cropDetails']?['quantity'] ?? 0) as num;
    final totalAmount = currentBid * quantity;

    if (status == 'completed' && winnerId == currentUserId) {
      if (auctionData['paymentStatus'] == 'completed') {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text(
                'Payment Completed',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price per Quintal:',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '₹${NumberFormat('#,##,###').format(currentBid)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity:',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$quantity quintals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${NumberFormat('#,##,###').format(totalAmount)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  bool confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm Payment'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Price per Quintal: ₹${NumberFormat('#,##,###').format(currentBid)}'),
                              Text('Quantity: $quantity quintals'),
                              Divider(height: 24),
                              Text(
                                'Total Amount: ₹${NumberFormat('#,##,###').format(totalAmount)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              Text('Proceed with the payment?'),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Proceed'),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (confirm) {
                    await FirebaseFirestore.instance
                        .collection('auctions')
                        .doc(auctionId)
                        .update({
                      'paymentStatus': 'completed',
                      'paymentTimestamp': FieldValue.serverTimestamp(),
                      'totalAmountPaid': totalAmount,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Payment successful!'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Payment failed. Please try again.'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 54),
              ),
              child: Text(
                'Make Payment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (status == 'active') {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BuyerBiddingPage(
                auctionId: auctionId,
                currentBid: currentBid,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: Size(double.infinity, 54),
        ),
        child: Text(
          'Place Bid',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_off, color: Colors.grey[600], size: 24),
            SizedBox(width: 8),
            Text(
              'Auction Ended',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auction Details'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('auctions')
            .doc(auctionId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }

          final latestAuctionData =
              snapshot.data!.data() as Map<String, dynamic>;
          final cropDetails = latestAuctionData['cropDetails'] ?? {};
          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          final winnerId = latestAuctionData['winner'] is Map
              ? latestAuctionData['winner']['id']
              : latestAuctionData['winner'];
          final showFarmerDetails = winnerId == currentUserId &&
              latestAuctionData['status'] == 'completed';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImageCarousel(),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cropDetails['type'] ?? 'Unknown Crop',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${cropDetails['quantity'] ?? 0} quintals',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              'Base Price',
                              '₹${NumberFormat('#,##,###').format(cropDetails['basePrice'] ?? 0)}',
                              Icons.currency_rupee,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              'Current Bid',
                              '₹${NumberFormat('#,##,###').format(currentBid)}',
                              Icons.gavel,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              'Quality Score',
                              '${(latestAuctionData['qualityScore'] ?? 0.0).toStringAsFixed(1)}/10',
                              Icons.star,
                              color: Colors.orange[700],
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              'Location',
                              '${latestAuctionData['location']?['district'] ?? 'Unknown'}',
                              Icons.location_on,
                            ),
                          ),
                        ],
                      ),
                      if (showFarmerDetails) ...[
                        SizedBox(height: 24),
                        Text(
                          'Farmer Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildFarmerDetails(
                            latestAuctionData['farmerDetails'] ?? {}),
                      ],
                      SizedBox(height: 24),
                      _buildActionButton(context, latestAuctionData),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
