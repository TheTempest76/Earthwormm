import 'package:flutter/material.dart';

class CropYieldScreen extends StatefulWidget {
  @override
  _CropYieldScreenState createState() => _CropYieldScreenState();
}

class _CropYieldScreenState extends State<CropYieldScreen> {
  final TextEditingController totalCropWeightController =
      TextEditingController();
  final TextEditingController cultivatedAreaController =
      TextEditingController();
  double yieldPerHectare = 0.0;

  void calculateYield() {
    double totalCropWeight =
        double.tryParse(totalCropWeightController.text) ?? 0;
    double cultivatedArea = double.tryParse(cultivatedAreaController.text) ?? 0;

    setState(() {
      yieldPerHectare =
          cultivatedArea > 0 ? totalCropWeight / cultivatedArea : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Yield Estimation'),
        backgroundColor: Color(0xFF4CAF50), // Blue
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yield per Hectare',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50), // Green
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Yield per hectare is a key metric that helps farmers understand the productivity of their land. It is calculated by dividing the total crop weight harvested by the cultivated area in hectares. This provides a measure of the yield or output per unit of land area.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: totalCropWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total Crop Weight (kg)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE3F2FD), // Light blue
                filled: true,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: cultivatedAreaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cultivated Area (hectares)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE3F2FD), // Light blue
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateYield,
              child: Text('Calculate Yield'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50), // Green
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Yield per Hectare: ${yieldPerHectare.toStringAsFixed(2)} kg/hectare',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50), // Green
              ),
            ),
          ],
        ),
      ),
    );
  }
}
