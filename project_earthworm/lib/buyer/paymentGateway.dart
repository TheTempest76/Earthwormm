import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:vibration/vibration.dart';

class PaymentSlider extends StatefulWidget {
  final double amount;
  //final VoidCallback onPaymentComplete;

  const PaymentSlider({
    Key? key,
    required this.amount,
    //required this.onPaymentComplete,
  }) : super(key: key);

  @override
  _PaymentSliderState createState() => _PaymentSliderState();
}

class _PaymentSliderState extends State<PaymentSlider>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  bool _isCompleted = false;
  bool _isDragging = false;
  late ConfettiController _confettiController;
  late AnimationController _checkmarkController;
  late Animation<double> _checkmarkAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _checkmarkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  void _handleComplete() async {
    if (!_isCompleted) {
      setState(() {
        _isCompleted = true;
        _progress = 1.0;
      });

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      }

      _checkmarkController.forward();
      _confettiController.play();
      //widget.onPaymentComplete.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sliderHeight = 60.0;
    final containerPadding = 20.0;

    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth - (containerPadding * 2);
      final circlePosition = _isCompleted
          ? maxWidth - sliderHeight
          : _progress * (maxWidth - sliderHeight);

      return Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 10,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              numberOfParticles: 75,
              gravity: 0.2,
              colors: [
                Colors.green,
                Colors.lightGreen,
                Colors.yellow,
                Colors.greenAccent,
              ],
            ),
          ),
          Container(
            height: sliderHeight,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: containerPadding),
            child: GestureDetector(
              onHorizontalDragStart: (_) => setState(() => _isDragging = true),
              onHorizontalDragEnd: (_) {
                setState(() => _isDragging = false);
                if (_progress > 0.7) {
                  _handleComplete();
                } else {
                  setState(() => _progress = 0.0);
                }
              },
              onHorizontalDragUpdate: (details) {
                if (!_isCompleted) {
                  final double newProgress =
                      (_progress + details.delta.dx / (maxWidth - sliderHeight))
                          .clamp(0.0, 1.0);
                  setState(() => _progress = newProgress);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(sliderHeight / 2),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: _progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.lightGreen.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(sliderHeight / 2),
                        ),
                      ),
                    ),
                    Positioned(
                      left: circlePosition,
                      child: _isCompleted
                          ? AnimatedBuilder(
                              animation: _checkmarkAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: sliderHeight,
                                  height: sliderHeight,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: (sliderHeight * 0.6) *
                                        _checkmarkAnimation.value,
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: sliderHeight,
                              height: sliderHeight,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: _isDragging
                                    ? [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Pay\n₹${widget.amount.toStringAsFixed(2)}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class PaymentPage extends StatelessWidget {
  final double amount;
  final bool isSupport;
  final String cropName;
  final String farmerName;
  final String farmerPhone;

  PaymentPage({
    Key? key,
    required this.amount,
    required this.isSupport,
    required this.cropName,
    required this.farmerName,
    required this.farmerPhone,
  }) : super(key: key);

  final NumberFormat _formatter = NumberFormat('#,##0.00', 'en_US');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Farmer Name: $farmerName'),
            Text('Phone: $farmerPhone'),
            const SizedBox(height: 20),

            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 3,
              child: ListTile(
                title: Text(cropName),
                subtitle: Text(isSupport ? 'Support Payment' : 'Crop Payment'),
                trailing: Text('₹${_formatter.format(amount)}'),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Scan to Pay',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Center(
              child: Image.network(
                'https://drive.google.com/uc?id=1BD_m2y6x7tlkFv1r-g5oQ5GtzXQ5Kgt_',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Payment Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Card Number'),
                    const SizedBox(height: 5),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter card number',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Expiration Date'),
                              const SizedBox(height: 5),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'MM/YY',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CVV'),
                              const SizedBox(height: 5),
                              TextField(
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: '***',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Payment Slider
            Center(
              child: PaymentSlider(
                amount: amount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}