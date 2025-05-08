import 'package:flutter/material.dart';

class SoilFertilityScreen extends StatefulWidget {
  @override
  _SoilFertilityScreenState createState() => _SoilFertilityScreenState();
}

class _SoilFertilityScreenState extends State<SoilFertilityScreen> {
  // Controllers for input fields
  final TextEditingController targetNutrientController =
      TextEditingController();
  final TextEditingController soilNutrientController = TextEditingController();
  final TextEditingController cultivatedAreaController =
      TextEditingController();
  final TextEditingController applicationRateController =
      TextEditingController();

  // Nutrient types
  final List<String> nutrientTypes = [
    'Nitrogen (N)',
    'Phosphorus (P)',
    'Potassium (K)'
  ];
  String selectedNutrientType = 'Nitrogen (N)';

  // Result variables
  double fertilizerRequirement = 0.0;
  String fertilizerRecommendation = '';

  void calculateFertilizerRequirement() {
    double targetNutrientLevel =
        double.tryParse(targetNutrientController.text) ?? 0;
    double soilNutrientLevel =
        double.tryParse(soilNutrientController.text) ?? 0;
    double cultivatedArea = double.tryParse(cultivatedAreaController.text) ?? 0;
    double applicationRate =
        double.tryParse(applicationRateController.text) ?? 0;

    setState(() {
      // Core calculation logic
      fertilizerRequirement = (targetNutrientLevel - soilNutrientLevel) *
          cultivatedArea *
          applicationRate;

      // Generate recommendation based on requirement
      if (fertilizerRequirement <= 0) {
        fertilizerRecommendation = 'No additional fertilizer needed';
      } else {
        fertilizerRecommendation =
            'Apply ${fertilizerRequirement.toStringAsFixed(2)} kg/ha of $selectedNutrientType fertilizer';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soil Fertility Management'),
        backgroundColor: Color(0xFF2E7D32), // Dark Green
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fertilizer Requirement Calculator',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32), // Dark Green
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Calculate the precise fertilizer requirement for optimal crop nutrition. Input target nutrient levels, current soil nutrient levels, and area to get tailored recommendations.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Nutrient Type Dropdown
            DropdownButtonFormField<String>(
              value: selectedNutrientType,
              decoration: InputDecoration(
                labelText: 'Nutrient Type',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE8F5E9), // Light Green
                filled: true,
              ),
              items: nutrientTypes.map((String type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedNutrientType = newValue!;
                });
              },
            ),
            SizedBox(height: 10),

            // Target Nutrient Level
            TextField(
              controller: targetNutrientController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target Nutrient Level (kg/ha)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE8F5E9), // Light Green
                filled: true,
              ),
            ),
            SizedBox(height: 10),

            // Current Soil Nutrient Level
            TextField(
              controller: soilNutrientController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Current Soil Nutrient Level (kg/ha)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE8F5E9), // Light Green
                filled: true,
              ),
            ),
            SizedBox(height: 10),

            // Cultivated Area
            TextField(
              controller: cultivatedAreaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cultivated Area (hectares)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE8F5E9), // Light Green
                filled: true,
              ),
            ),
            SizedBox(height: 10),

            // Application Rate
            TextField(
              controller: applicationRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Application Rate (kg/ha)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE8F5E9), // Light Green
                filled: true,
              ),
            ),
            SizedBox(height: 20),

            // Calculate Button
            ElevatedButton(
              onPressed: calculateFertilizerRequirement,
              child: Text('Calculate Fertilizer Requirement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E7D32), // Dark Green
              ),
            ),
            SizedBox(height: 20),

            // Results Section
            Card(
              color: Color(0xFFE8F5E9), // Light Green
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fertilizer Recommendation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32), // Dark Green
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Total Fertilizer Requirement: ${fertilizerRequirement.toStringAsFixed(2)} kg/ha',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2E7D32), // Dark Green
                      ),
                    ),
                    Text(
                      fertilizerRecommendation,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF388E3C), // Slightly lighter green
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
