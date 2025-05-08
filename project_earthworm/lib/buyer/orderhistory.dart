import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('orderDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/empty_orders.png', height: 200),
                  const Text('No orders placed yet'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              return OrderCard(
                data: doc.data() as Map<String, dynamic>,
                docId: doc.id,
              );
            },
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const OrderCard({
    Key? key,
    required this.data,
    required this.docId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##,###");
    final orderStatus = data['status'] ?? 'Processing';
    final orderDate =
        (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetailedView(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Image with Status Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    data['cropImage'] ??
                        'images/' + data['cropType'].toLowerCase() + '.png',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(orderStatus),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      orderStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['cropType'] ?? 'Unknown Crop',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${formatter.format(data['totalAmount'] ?? 0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Farmer Info
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Farmer: ${data['farmerName'] ?? 'Unknown Farmer'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Ordered on: ${DateFormat('MMM dd, yyyy').format(orderDate)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.scale, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Quantity: ${formatter.format(data['quantity'] ?? 0)} quintals',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  // Rate Order Button
                  if (orderStatus == 'Delivered' && !(data['isRated'] ?? false))
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showRatingDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Rate Your Order'),
                        ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDetailedView(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetailedOrderView(data: data),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RatingDialog(orderId: docId),
    );
  }
}

class DetailedOrderView extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailedOrderView({Key? key, required this.data}) : super(key: key);

  @override
  _DetailedOrderViewState createState() => _DetailedOrderViewState();
}

class _DetailedOrderViewState extends State<DetailedOrderView> {
  int _currentImageIndex = 0;
  final _formatter = NumberFormat("#,##,###");

  @override
  Widget build(BuildContext context) {
    final orderDate =
        (widget.data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    final deliveryDate = (widget.data['deliveryDate'] as Timestamp?)?.toDate();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Order Status Timeline
            _buildOrderTimeline(),
            const SizedBox(height: 24),

            // Basic Info
            Text(
              widget.data['cropType'] ?? 'Unknown Crop',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Order ID: ${widget.data['orderId'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Order Details
            _buildInfoCard(
              title: 'Order Date',
              content: DateFormat('MMM dd, yyyy').format(orderDate),
              icon: Icons.calendar_today,
            ),
            if (deliveryDate != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Delivery Date',
                content: DateFormat('MMM dd, yyyy').format(deliveryDate),
                icon: Icons.local_shipping,
              ),
            ],
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Total Amount',
              content: '₹${_formatter.format(widget.data['totalAmount'] ?? 0)}',
              icon: Icons.payment,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Quantity',
              content:
                  '${_formatter.format(widget.data['quantity'] ?? 0)} quintals',
              icon: Icons.scale,
            ),
            const SizedBox(height: 24),

            // Farmer Details
            const Text(
              'Farmer Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                        'Name', widget.data['farmerName'] ?? 'Unknown'),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                        'Phone', widget.data['farmerPhone'] ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                        'Location', widget.data['pickupLocation'] ?? 'N/A'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTimeline() {
    final status = widget.data['status']?.toLowerCase() ?? '';
    return Column(
      children: [
        _buildTimelineItem('Order Placed', true, Colors.green),
        _buildTimelineItem('Processing', status != 'placed', Colors.blue),
        _buildTimelineItem('Shipped',
            status == 'shipped' || status == 'delivered', Colors.orange),
        _buildTimelineItem('Delivered', status == 'delivered', Colors.green),
      ],
    );
  }

  Widget _buildTimelineItem(String title, bool isCompleted, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted ? color : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isCompleted ? Colors.black : Colors.grey,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (title != 'Delivered')
          Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? color : Colors.grey[300],
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.green),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(content,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class RatingDialog extends StatefulWidget {
  final String orderId;

  const RatingDialog({Key? key, required this.orderId}) : super(key: key);

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 0;
  String _review = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Your Order'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 36,
                ),
                onPressed: () => setState(() => _rating = index + 1.0),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write your review...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _review = value,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _rating > 0 ? () => _submitRating(context) : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Future<void> _submitRating(BuildContext context) async {
    try {
      // Update the order document with rating information
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'rating': _rating,
        'review': _review,
        'isRated': true,
        'ratedAt': FieldValue.serverTimestamp(),
      });

      // Show success message and close dialog
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your rating!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting rating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
