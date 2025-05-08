import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class BuyerBiddingPage extends StatefulWidget {
  final String auctionId;
  final double currentBid;

  const BuyerBiddingPage({
    Key? key,
    required this.auctionId,
    required this.currentBid,
  }) : super(key: key);

  @override
  _BuyerBiddingPageState createState() => _BuyerBiddingPageState();
}

class _BuyerBiddingPageState extends State<BuyerBiddingPage>
    with SingleTickerProviderStateMixin {
  final _bidController = TextEditingController();
  late Stream<DocumentSnapshot> auctionStream;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    auctionStream = FirebaseFirestore.instance
        .collection('auctions')
        .doc(widget.auctionId)
        .snapshots();

    _setupAuctionEndCheck();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  // Your existing _setupAuctionEndCheck and _placeBid methods remain the same

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "${hours}h ${minutes}m ${seconds}s";
  }

  void _setupAuctionEndCheck() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) async {
      try {
        final auctionDoc = await FirebaseFirestore.instance
            .collection('auctions')
            .doc(widget.auctionId)
            .get();

        if (!auctionDoc.exists) return;

        final auctionData = auctionDoc.data() as Map<String, dynamic>;
        final endTime = (auctionData['endTime'] as Timestamp).toDate();

        if (DateTime.now().isAfter(endTime) &&
            auctionData['status'] == 'active' &&
            auctionData['winner'] == null) {
          final currentBidder = auctionData['currentBidder'];
          if (currentBidder != null) {
            await FirebaseFirestore.instance
                .collection('auctions')
                .doc(widget.auctionId)
                .update({
              'status': 'completed',
              'completedAt': FieldValue.serverTimestamp(),
              'lastUpdated': FieldValue.serverTimestamp(),
              'winner': currentBidder['id'],
              'winnerDetails': currentBidder,
              'winningBid': auctionData['currentBid'],
              'winningBidder': currentBidder,
            });
          } else {
            // Handle case where auction ends with no bids
            await FirebaseFirestore.instance
                .collection('auctions')
                .doc(widget.auctionId)
                .update({
              'status': 'completed',
              'completedAt': FieldValue.serverTimestamp(),
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          }
        }
      } catch (e) {
        print('Error in auction end check: $e');
      }
    });
  }

  Future<void> _placeBid() async {
    try {
      if (_bidController.text.isEmpty) {
        _showErrorSnackBar('Please enter a bid amount');
        return;
      }

      final newBid = double.parse(_bidController.text);
      final auctionDoc = await FirebaseFirestore.instance
          .collection('auctions')
          .doc(widget.auctionId)
          .get();

      final auctionData = auctionDoc.data() as Map<String, dynamic>;
      final currentBid = auctionData['currentBid'] as double;

      // Add minimum bid increment (e.g., 1% of current bid)
      final minimumBidIncrement = currentBid * 0.02; // 1% increment
      final minimumNextBid = currentBid + minimumBidIncrement;

      if (newBid <= currentBid) {
        _showErrorSnackBar(
            'Bid must be higher than current bid: ₹${NumberFormat('#,##,###').format(currentBid)}');
        return;
      }

      if (newBid < minimumNextBid) {
        _showErrorSnackBar(
            'Minimum bid should be ₹${NumberFormat('#,##,###').format(minimumNextBid)}');
        return;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showErrorSnackBar('Please sign in to place a bid');
        return;
      }

      // Get buyer data
      final buyerDoc = await FirebaseFirestore.instance
          .collection('buyers')
          .doc(currentUser.uid)
          .get();

      if (!buyerDoc.exists) {
        _showErrorSnackBar('Buyer profile not found');
        return;
      }

      final buyerData = buyerDoc.data()!;

      // Get auction data to check if it's still active

      final endTime = (auctionData['endTime'] as Timestamp).toDate();

      if (DateTime.now().isAfter(endTime)) {
        _showErrorSnackBar('Auction has ended');
        return;
      }

      // Update auction with new bid
      await FirebaseFirestore.instance
          .collection('auctions')
          .doc(widget.auctionId)
          .update({
        'currentBid': newBid,
        'currentBidder': {
          'id': currentUser.uid,
          'name': buyerData['company'] ?? 'Unknown Company',
          'phone': buyerData['phone'] ?? '',
        },
        'bids': FieldValue.arrayUnion([
          {
            'amount': newBid,
            'bidderId': currentUser.uid,
            'bidderName': buyerData['company'] ?? 'Unknown Company',
            'timestamp': DateTime.now().toIso8601String(),
          }
        ]),
      });

      _bidController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Bid placed successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: auctionStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }

          final auction = snapshot.data!.data() as Map<String, dynamic>;
          final endTime = (auction['endTime'] as Timestamp).toDate();
          final remainingTime = endTime.difference(DateTime.now());
          final cropDetails = auction['cropDetails'];

          if (remainingTime.isNegative) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_off, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Auction has ended',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.green[700]!, Colors.green],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -50,
                          top: -50,
                          child: CircleAvatar(
                            radius: 100,
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        Positioned(
                          left: -30,
                          bottom: -30,
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                cropDetails['type'],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${cropDetails['quantity']} quintals',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTimerCard(remainingTime),
                      SizedBox(height: 24),
                      _buildBiddingCard(auction),
                      SizedBox(height: 24),
                      _buildBidHistoryCard(auction),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimerCard(Duration remainingTime) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Time Remaining',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          ScaleTransition(
            scale: _animation,
            child: Text(
              _formatDuration(remainingTime),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: remainingTime.inMinutes < 5
                    ? Colors.red[700]
                    : Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiddingCard(Map<String, dynamic> auction) {
    final currentBid = auction['currentBid'];
    final basePrice = auction['cropDetails']['basePrice'];
    final increase =
        ((currentBid - basePrice) / basePrice * 100).toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Bid',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '₹${NumberFormat('#,##,###').format(currentBid)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+$increase%',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          TextField(
            controller: _bidController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Your Bid Amount',
              prefixText: '₹ ',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.green, width: 2),
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _placeBid,
            icon: Icon(Icons.gavel),
            label: Text(
              'Place Bid',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidHistoryCard(Map<String, dynamic> auction) {
    final bids = auction['bids'] as List<dynamic>? ?? [];

    if (bids.isEmpty) return SizedBox();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bid History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...bids.reversed.take(5).map((bid) => Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bid['bidderName'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹${NumberFormat('#,##,###').format(bid['amount'])}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bidController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
