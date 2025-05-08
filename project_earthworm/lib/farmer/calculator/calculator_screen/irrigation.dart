import 'package:flutter/material.dart';

class IrrigationRequirementsScreen extends StatefulWidget {
  @override
  _IrrigationRequirementsScreenState createState() =>
      _IrrigationRequirementsScreenState();
}

class _IrrigationRequirementsScreenState
    extends State<IrrigationRequirementsScreen> {
  final TextEditingController cropWaterDemandController =
      TextEditingController();
  final TextEditingController effectiveRainfallController =
      TextEditingController();
  double waterRequired = 0.0;

  void calculateIrrigationRequirements() {
    double cropWaterDemand =
        double.tryParse(cropWaterDemandController.text) ?? 0;
    double effectiveRainfall =
        double.tryParse(effectiveRainfallController.text) ?? 0;

    setState(() {
      waterRequired = cropWaterDemand - effectiveRainfall;
      // Ensure water required is not negative
      waterRequired = waterRequired > 0 ? waterRequired : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Irrigation Requirements Calculator'),
        backgroundColor: Color(0xFF4CAF50), // Blue
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Water Requirements',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50), // Green
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Irrigation requirement is calculated by subtracting effective rainfall from the crop water demand (ETc). This helps farmers determine the additional water needed for optimal crop growth.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: cropWaterDemandController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Crop Water Demand (ETc) in mm',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE3F2FD), // Light blue
                filled: true,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: effectiveRainfallController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Effective Rainfall (mm)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE3F2FD), // Light blue
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateIrrigationRequirements,
              child: Text('Calculate Water Requirements'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50), // Green
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Water Required: ${waterRequired.toStringAsFixed(2)} mm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50), // Green
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Note: A positive water requirement indicates the need for additional irrigation. Zero or negative value suggests sufficient moisture from rainfall.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
