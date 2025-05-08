import 'package:flutter/material.dart';

class PestDiseaseManagementScreen extends StatefulWidget {
  @override
  _PestDiseaseManagementScreenState createState() =>
      _PestDiseaseManagementScreenState();
}

class _PestDiseaseManagementScreenState
    extends State<PestDiseaseManagementScreen> {
  final TextEditingController areaToTreatController = TextEditingController();
  final TextEditingController dosePerHectareController =
      TextEditingController();

  final List<String> pestTypes = [
    'Insecticide',
    'Fungicide',
    'Herbicide',
    'Nematicide'
  ];
  String selectedPestType = 'Insecticide';

  double pesticideQuantity = 0.0;
  String treatmentRecommendation = '';

  void calculatePesticideQuantity() {
    double areaToTreat = double.tryParse(areaToTreatController.text) ?? 0;
    double dosePerHectare = double.tryParse(dosePerHectareController.text) ?? 0;

    setState(() {
      pesticideQuantity = areaToTreat * dosePerHectare;

      treatmentRecommendation = pesticideQuantity > 0
          ? 'Apply ${pesticideQuantity.toStringAsFixed(2)} liters/kg of $selectedPestType'
          : 'Invalid input';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pest and Disease Management'),
        backgroundColor: Color(0xFFD32F2F), // Red
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesticide Quantity Calculator',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD32F2F), // Red
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Calculate precise pesticide requirements for effective crop protection. Input treatment area and dosage to determine the exact quantity needed.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Pest Type Dropdown
            DropdownButtonFormField<String>(
              value: selectedPestType,
              decoration: InputDecoration(
                labelText: 'Pest Type',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFFFEBEE), // Light Red
                filled: true,
              ),
              items: pestTypes.map((String type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedPestType = newValue!;
                });
              },
            ),
            SizedBox(height: 10),

            // Area to Treat
            TextField(
              controller: areaToTreatController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Area to Treat (hectares)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFFFEBEE), // Light Red
                filled: true,
              ),
            ),
            SizedBox(height: 10),

            // Dose per Hectare
            TextField(
              controller: dosePerHectareController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Dose per Hectare (liters/kg)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFFFEBEE), // Light Red
                filled: true,
              ),
            ),
            SizedBox(height: 20),

            // Calculate Button
            ElevatedButton(
              onPressed: calculatePesticideQuantity,
              child: Text('Calculate Pesticide Quantity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD32F2F), // Red
              ),
            ),
            SizedBox(height: 20),

            // Results Section
            Card(
              color: Color(0xFFFFEBEE), // Light Red
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Treatment Recommendation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD32F2F), // Red
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Total Pesticide Quantity: ${pesticideQuantity.toStringAsFixed(2)} liters/kg',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFD32F2F), // Red
                      ),
                    ),
                    Text(
                      treatmentRecommendation,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF44336), // Bright Red
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
