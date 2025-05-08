import 'package:flutter/material.dart';

class MarketPriceScreen extends StatefulWidget {
  @override
  _MarketPriceScreenState createState() => _MarketPriceScreenState();
}

class _MarketPriceScreenState extends State<MarketPriceScreen> {
  final TextEditingController currentPriceController = TextEditingController();
  final TextEditingController expectedPriceController = TextEditingController();

  final List<String> cropTypes = [
    'Wheat',
    'Rice',
    'Corn',
    'Soybeans',
    'Sugarcane',
    'Cotton',
    'Other'
  ];
  String selectedCropType = 'Wheat';

  double priceFluctuation = 0.0;
  String marketTrend = '';

  void calculatePriceFluctuation() {
    double currentPrice = double.tryParse(currentPriceController.text) ?? 0;
    double expectedPrice = double.tryParse(expectedPriceController.text) ?? 1;

    setState(() {
      priceFluctuation = ((currentPrice - expectedPrice) / expectedPrice) * 100;

      marketTrend = priceFluctuation > 0
          ? 'Price Increased'
          : priceFluctuation < 0
              ? 'Price Decreased'
              : 'Price Stable';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Market Price Fluctuations'),
        backgroundColor: Color(0xFFFF9800), // Orange
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Fluctuation Analysis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9800), // Orange
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Analyze market price variations to understand price trends and make informed selling decisions.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedCropType,
              decoration: InputDecoration(
                labelText: 'Crop Type',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFFFF3E0), // Light Orange
                filled: true,
              ),
              items: cropTypes.map((String type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCropType = newValue!;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: currentPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Current Market Price (per kg)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFFFF3E0), // Light Orange
                filled: true,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: expectedPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Expected Price (per kg)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFFFF3E0), // Light Orange
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculatePriceFluctuation,
              child: Text('Calculate Price Fluctuation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF9800), // Orange
              ),
            ),
            SizedBox(height: 20),
            Card(
              color: Color(0xFFFFF3E0), // Light Orange
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Analysis Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF9800), // Orange
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Price Fluctuation: ${priceFluctuation.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFF9800), // Orange
                      ),
                    ),
                    Text(
                      'Market Trend: $marketTrend',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5722), // Deep Orange
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
