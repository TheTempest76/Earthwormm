import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_earthworm/services/auction_service.dart';

class FarmerAuctionStatusPage extends StatelessWidget {
  final String auctionId;

  const FarmerAuctionStatusPage({
    Key? key,
    required this.auctionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Auction Status',
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
            colors: [Colors.green.shade600, Colors.green.shade50],
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('auctions')
              .doc(auctionId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.green.shade700,
                  strokeWidth: 3,
                ),
              );
            }

            final auction = snapshot.data!.data() as Map<String, dynamic>;
            final endTime = (auction['endTime'] as Timestamp).toDate();
            final remainingTime = endTime.difference(DateTime.now());
            final currentBidder =
                auction['currentBidder'] as Map<String, dynamic>?;
            final bids = auction['bids'] as List?;

            if (auction['status'] == 'active' &&
                DateTime.now().isAfter(endTime)) {
              AuctionService.checkAndEndExpiredAuction(auctionId);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: remainingTime.isNegative
                              ? [Colors.red.shade50, Colors.white]
                              : [Colors.green.shade50, Colors.white],
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildTimerWidget(remainingTime),
                          const SizedBox(height: 24),
                          _buildCurrentBidWidget(auction, currentBidder),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.history,
                                color: Colors.green.shade700,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Bid History',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (bids == null || bids.isEmpty)
                            _buildEmptyBidsWidget()
                          else
                            _buildBidsList(bids),
                        ],
                      ),
                    ),
                  ),
                  if (remainingTime.isNegative && currentBidder != null)
                    _buildAuctionCompleteCard(auction, currentBidder),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimerWidget(Duration remainingTime) {
    return Column(
      children: [
        Icon(
          remainingTime.isNegative ? Icons.timer_off : Icons.timer,
          size: 48,
          color: remainingTime.isNegative
              ? Colors.red.shade700
              : Colors.green.shade700,
        ),
        const SizedBox(height: 12),
        Text(
          remainingTime.isNegative ? 'Auction Ended' : 'Time Remaining',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: remainingTime.isNegative
                ? Colors.red.shade700
                : Colors.green.shade700,
          ),
        ),
        if (!remainingTime.isNegative) ...[
          const SizedBox(height: 8),
          Text(
            '${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCurrentBidWidget(
      Map<String, dynamic> auction, Map<String, dynamic>? currentBidder) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '₹${auction['currentBid'] ?? 0}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Current Highest Bid',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          if (currentBidder != null && currentBidder['name'] != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Icon(
                    Icons.person,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  currentBidder['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyBidsWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.gavel,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No bids yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidsList(List bids) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bids.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey.shade200,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final bid = bids[index] as Map<String, dynamic>;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.green.shade100,
            child: Icon(
              Icons.person,
              color: Colors.green.shade700,
            ),
          ),
          title: Text(
            '₹${bid['amount'] ?? 0}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            bid['bidderName'] ?? 'Unknown Bidder',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatTime(bid['timestamp']),
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBuyerDetailsCard(String buyerId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('buyers')
          .doc(buyerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.green.shade700,
              ),
            ),
          );
        }

        if (!snapshot.data!.exists) {
          return Container();
        }

        final buyerData = snapshot.data!.data() as Map<String, dynamic>;

        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(
                        Icons.business,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buyer Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            buyerData['company'] ??
                                'Company Name Not Available',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildBuyerInfoSection(
                  'Contact Information',
                  Icons.contact_phone,
                  [
                    _buildBuyerInfoItem(
                      'Phone',
                      buyerData['phone'] ?? 'Not Available',
                      Icons.phone,
                    ),
                    _buildBuyerInfoItem(
                      'Email',
                      buyerData['email'] ?? 'Not Available',
                      Icons.email,
                    ),
                    _buildBuyerInfoItem(
                      'GST Number',
                      buyerData['gstNumber'] ?? 'Not Available',
                      Icons.receipt_long,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildBuyerInfoSection(
                  'Location Details',
                  Icons.location_on,
                  [
                    _buildBuyerInfoItem(
                      'Address',
                      buyerData['address'] ?? 'Not Available',
                      Icons.home,
                    ),
                    _buildBuyerInfoItem(
                      'District',
                      buyerData['district'] ?? 'Not Available',
                      Icons.location_city,
                    ),
                    _buildBuyerInfoItem(
                      'State',
                      buyerData['state'] ?? 'Not Available',
                      Icons.map,
                    ),
                    _buildBuyerInfoItem(
                      'PIN Code',
                      buyerData['pinCode'] ?? 'Not Available',
                      Icons.pin_drop,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBuyerInfoSection(
      String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBuyerInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionCompleteCard(
      Map<String, dynamic> auction, Map<String, dynamic> currentBidder) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.white],
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.celebration,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Auction Complete',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildWinnerInfoTile(
                    'Winning Bid',
                    '₹${auction['currentBid'] ?? 0}',
                    Icons.monetization_on,
                  ),
                  const SizedBox(height: 12),
                  _buildWinnerInfoTile(
                    'Winner',
                    currentBidder['name'] ?? 'Unknown Bidder',
                    Icons.emoji_events,
                  ),
                  if (currentBidder['phone'] != null) ...[
                    const SizedBox(height: 12),
                    _buildWinnerInfoTile(
                      'Contact',
                      currentBidder['phone'],
                      Icons.phone,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('buyers')
                .doc(currentBidder['id'])
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final buyerData = snapshot.data!.data() as Map<String, dynamic>?;
              if (buyerData == null) {
                return const SizedBox();
              }

              return Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.green.shade100,
                            child: Icon(
                              Icons.business,
                              color: Colors.green.shade700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Buyer Details',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                if (buyerData['company'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    buyerData['company'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (buyerData['gstNumber'] != null) ...[
                        _buildDetailTile(
                          'GST Number',
                          buyerData['gstNumber'],
                          Icons.receipt_long,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (buyerData['address'] != null) ...[
                        _buildDetailTile(
                          'Address',
                          buyerData['address'],
                          Icons.location_on,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (buyerData['district'] != null) ...[
                        _buildDetailTile(
                          'District',
                          buyerData['district'],
                          Icons.location_city,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (buyerData['state'] != null) ...[
                        _buildDetailTile(
                          'State',
                          buyerData['state'],
                          Icons.map,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (buyerData['pinCode'] != null)
                        _buildDetailTile(
                          'PIN Code',
                          buyerData['pinCode'],
                          Icons.pin_drop,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWinnerInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'Time not available';

    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (timestamp is String) {
        final date = DateTime.parse(timestamp);
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
      return 'Invalid time format';
    } catch (e) {
      return 'Time not available';
    }
  }
}
