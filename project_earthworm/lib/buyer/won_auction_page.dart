import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'auction_detail_page.dart';

class WonAuctionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Won Auctions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('auctions')
            .where('status', isEqualTo: 'completed')
            .where('currentBidder.id', isEqualTo: userId) // Updated this line
            .orderBy('endTime', descending: true) // Updated to use completedAt
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Query error: ${snapshot.error}');
            return _buildErrorState();
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }

          final auctions = snapshot.data!.docs;

          if (auctions.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: auctions.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final auction = auctions[index].data() as Map<String, dynamic>;
              print(
                  'Auction data: ${auction['cropDetails']['type']} - Status: ${auction['status']} - Bidder: ${auction['currentBidder']['id']}');
              return _WonAuctionCard(
                auctionId: auctions[index].id,
                auction: auction,
              );
            },
          );
        },
      ),
    );
  }

  static void _updateAuctionStatus(
    Transaction transaction,
    DocumentReference auctionRef,
    Map<String, dynamic> auctionData,
  ) {
    final winnerDetails = auctionData['currentBidder'];

    // Ensure consistent data structure
    transaction.update(auctionRef, {
      'status': 'completed',
      'winningBid': auctionData['currentBid'],
      'winner': winnerDetails['id'],
      'winnerDetails': {
        'id': winnerDetails['id'],
        'name': winnerDetails['name'] ?? '',
        'phone': winnerDetails['phone'] ?? '',
        // Add any other relevant winner details
      },
      'completedAt': FieldValue.serverTimestamp(),
    });

    // Create notification for the winner
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          SizedBox(height: 16),
          Text(
            'Error Loading Auctions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            'No Won Auctions Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Start bidding on auctions to see your winning bids here!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

class _WonAuctionCard extends StatelessWidget {
  final String auctionId;
  final Map<String, dynamic> auction;

  const _WonAuctionCard({
    Key? key,
    required this.auctionId,
    required this.auction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final endTime = (auction['endTime'] as Timestamp).toDate();
    final cropDetails = auction['cropDetails'] as Map<String, dynamic>? ?? {};
    final farmerDetails =
        auction['farmerDetails'] as Map<String, dynamic>? ?? {};
    final winningBid = auction['winningBid'] ?? auction['currentBid'] ?? 0.0;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AuctionDetailPage(
                auctionId: auctionId,
                currentBid: (winningBid as num).toDouble(),
                auctionData: auction,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Winning Amount
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Winning Bid',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₹${NumberFormat('#,##,###').format(winningBid)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Won',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Crop Details Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cropDetails['type'] ?? 'Unknown Crop',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.inventory,
                        '${cropDetails['quantity'] ?? 0} quintals',
                      ),
                      SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.calendar_today,
                        DateFormat('MMM d, yyyy').format(endTime),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Farmer Details Section
                  if (farmerDetails.isNotEmpty) ...[
                    Divider(),
                    SizedBox(height: 8),
                    Text(
                      'Farmer Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey[200],
                          child: Icon(Icons.person, color: Colors.grey[400]),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                farmerDetails['name'] ?? 'Unknown Farmer',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              if (farmerDetails['phone'] != null)
                                Row(
                                  children: [
                                    Icon(Icons.phone,
                                        size: 14, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(
                                      farmerDetails['phone'],
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
