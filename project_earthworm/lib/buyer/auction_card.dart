import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auction_detail_page.dart';
import 'buyer_bidding_page.dart';

class AuctionCard extends StatelessWidget {
  final String auctionId;
  final Map<String, dynamic> data;

  const AuctionCard({
    Key? key,
    required this.auctionId,
    required this.data,
  }) : super(key: key);

  String _getRemainingTimeString(Duration remainingTime) {
    if (remainingTime.inDays > 0) {
      return '${remainingTime.inDays}d ${remainingTime.inHours % 24}h';
    } else if (remainingTime.inHours > 0) {
      return '${remainingTime.inHours}h ${remainingTime.inMinutes % 60}m';
    } else {
      return '${remainingTime.inMinutes}m ${remainingTime.inSeconds % 60}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final endTime = (data['endTime'] as Timestamp).toDate();
    final remainingTime = endTime.difference(DateTime.now());
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                currentBid: (data['currentBid'] as num).toDouble(),
                auctionData: data,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data['cropDetails']['type']}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer, size: 16, color: Colors.orange),
                              SizedBox(width: 4),
                              Text(
                                _getRemainingTimeString(remainingTime),
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.inventory,
                      title: 'Quantity',
                      value: '${data['cropDetails']['quantity']} quintals',
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.price_change,
                      title: 'Base Price',
                      value: '₹${data['cropDetails']['basePrice']}',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.gavel,
                      title: 'Current Bid',
                      value: '₹${data['currentBid']}',
                      highlighted: true,
                    ),
                  ),
                  SizedBox(width: 8),
                  if (data['qualityScore'] != null)
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.star,
                        title: 'Quality Score',
                        value: '${data['qualityScore'].toStringAsFixed(1)}',
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuyerBiddingPage(
                          auctionId: auctionId,
                          currentBid: (data['currentBid'] as num).toDouble(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Place Bid',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool highlighted;

  const _InfoCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    this.highlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: highlighted ? Colors.green : Colors.grey[600],
              ),
              SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: highlighted ? Colors.green[700] : null,
            ),
          ),
        ],
      ),
    );
  }
}
