import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Handle auction expiry check with better error handling
  static Future<void> checkAndEndExpiredAuction(String auctionId) async {
    try {
      final auction =
          await _firestore.collection('auctions').doc(auctionId).get();
      if (!auction.exists) return;

      final auctionData = auction.data()!;
      if (auctionData['status'] == 'active') {
        final endTime = (auctionData['endTime'] as Timestamp).toDate();
        if (DateTime.now().isAfter(endTime)) {
          await endAuction(auctionId);
        }
      }
    } catch (e) {
      print('Error checking auction expiry: $e');
      rethrow;
    }
  }

  // Enhanced auction end handler
  static Future<void> endAuction(String auctionId) async {
    final auctionRef = _firestore.collection('auctions').doc(auctionId);

    try {
      await _firestore.runTransaction((transaction) async {
        final auctionDoc = await transaction.get(auctionRef);
        if (!auctionDoc.exists) return;

        final auctionData = auctionDoc.data()!;
        if (auctionData['status'] != 'active') return;

        // Ensure we have a current bidder
        final currentBidder = auctionData['currentBidder'];
        if (currentBidder == null) {
          // Handle case where auction ends with no bids
          transaction.update(auctionRef, {
            'status': 'completed',
            'completedAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          return;
        }

        // Decide which handler to use based on auction type
        final bool isGroupAuction = auctionData['isGroupFarming'] ?? false;

        if (isGroupAuction) {
          await _handleGroupAuctionEnd(transaction, auctionRef, auctionData);
        } else {
          await _handleSingleAuctionEnd(transaction, auctionRef, auctionData);
        }
      });
    } catch (e) {
      print('Error ending auction: $e');
      rethrow;
    }
  }

  // Updated single farmer auction completion
  static Future<void> _handleSingleAuctionEnd(
    Transaction transaction,
    DocumentReference auctionRef,
    Map<String, dynamic> auctionData,
  ) async {
    final currentBidder = auctionData['currentBidder'];
    final currentBid = auctionData['currentBid'];

    // Create order
    final orderRef = _firestore.collection('orders').doc();
    transaction.set(orderRef, {
      'buyerId': currentBidder['id'],
      'farmerId': auctionData['farmerDetails']['id'],
      'farmerName': auctionData['farmerDetails']['name'],
      'cropType': auctionData['cropDetails']['type'],
      'quantity': auctionData['cropDetails']['quantity'],
      'price': currentBid,
      'status': 'pending',
      'orderType': 'auction',
      'auctionId': auctionRef.id,
      'isGroupOrder': false,
      'location': auctionData['location'],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update auction with ALL required fields
    transaction.update(auctionRef, {
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'winner': currentBidder['id'],
      'winnerDetails': currentBidder,
      'winningBid': currentBid,
      'winningBidder': currentBidder,
    });

    // Create notification
    await _createNotification(
      userId: auctionData['farmerDetails']['id'],
      title: 'Auction Completed',
      message:
          'Your auction for ${auctionData['cropDetails']['type']} has been completed at ₹$currentBid',
      auctionId: auctionRef.id,
      orderId: orderRef.id,
    );
  }

  // Updated group auction completion
  static Future<void> _handleGroupAuctionEnd(
    Transaction transaction,
    DocumentReference auctionRef,
    Map<String, dynamic> auctionData,
  ) async {
    final currentBidder = auctionData['currentBidder'];
    final currentBid = auctionData['currentBid'];
    final List<dynamic> groupMembers = auctionData['groupMembers'] ?? [];

    if (groupMembers.isEmpty) return;

    // Create orders for each group member
    for (var member in groupMembers) {
      final orderRef = _firestore.collection('orders').doc();
      transaction.set(orderRef, {
        'buyerId': currentBidder['id'],
        'farmerId': member['farmerId'],
        'farmerName': member['name'],
        'cropType': auctionData['cropDetails']['type'],
        'quantity': auctionData['cropDetails']['quantity'],
        'price': currentBid,
        'status': 'pending',
        'orderType': 'auction',
        'auctionId': auctionRef.id,
        'isGroupOrder': true,
        'groupAuctionId': auctionRef.id,
        'location': auctionData['location'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _createNotification(
        userId: member['farmerId'],
        title: 'Group Auction Completed',
        message:
            'Your group auction for ${auctionData['cropDetails']['type']} has been completed at ₹$currentBid',
        auctionId: auctionRef.id,
        orderId: orderRef.id,
      );
    }

    // Update auction with ALL required fields
    transaction.update(auctionRef, {
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'winner': currentBidder['id'],
      'winnerDetails': currentBidder,
      'winningBid': currentBid,
      'winningBidder': currentBidder,
    });
  }

  // Updated notification creation
  static Future<void> _createNotification({
    required String userId,
    required String title,
    required String message,
    required String auctionId,
    required String orderId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': 'auction_completed',
        'title': title,
        'message': message,
        'auctionId': auctionId,
        'orderId': orderId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating notification: $e');
      rethrow;
    }
  }
}
