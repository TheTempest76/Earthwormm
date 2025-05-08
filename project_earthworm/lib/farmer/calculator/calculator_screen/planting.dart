import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlantingHarvestingScheduleScreen extends StatefulWidget {
  @override
  _PlantingHarvestingScheduleScreenState createState() =>
      _PlantingHarvestingScheduleScreenState();
}

class _PlantingHarvestingScheduleScreenState
    extends State<PlantingHarvestingScheduleScreen> {
  // Controllers for input fields
  final TextEditingController cropNameController = TextEditingController();
  final TextEditingController maturityPeriodController =
      TextEditingController();

  // Date selection variables
  DateTime? plantingDate;
  int? maturityPeriod;

  // Calculation results
  DateTime? expectedHarvestDate;
  int? daysUntilHarvest;

  // Method to select planting date
  Future<void> _selectPlantingDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != plantingDate) {
      setState(() {
        plantingDate = pickedDate;
        _calculateHarvestDetails();
      });
    }
  }

  // Method to calculate harvest details
  void _calculateHarvestDetails() {
    if (plantingDate != null && maturityPeriod != null) {
      setState(() {
        expectedHarvestDate =
            plantingDate!.add(Duration(days: maturityPeriod!));
        daysUntilHarvest =
            expectedHarvestDate!.difference(DateTime.now()).inDays;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planting & Harvesting Scheduler'),
        backgroundColor: Color(0xFF2E7D32), // Dark Green
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Name Input
            TextField(
              controller: cropNameController,
              decoration: InputDecoration(
                labelText: 'Crop Name',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE8F5E9), // Light Green
                filled: true,
              ),
            ),
            SizedBox(height: 15),

            // Maturity Period Input
            TextField(
              controller: maturityPeriodController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Crop Maturity Period (Days)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE8F5E9), // Light Green
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  maturityPeriod = int.tryParse(value);
                  _calculateHarvestDetails();
                });
              },
            ),
            SizedBox(height: 15),

            // Planting Date Selection
            Row(
              children: [
                Expanded(
                  child: Text(
                    plantingDate == null
                        ? 'Select Planting Date'
                        : 'Planting Date: ${DateFormat('dd MMM yyyy').format(plantingDate!)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectPlantingDate(context),
                  child: Text('Choose Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E7D32), // Dark Green
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Results Section
            if (expectedHarvestDate != null) ...[
              Card(
                color: Color(0xFFA5D6A7), // Light Green
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harvest Scheduling Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Crop: ${cropNameController.text}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Expected Harvest Date: ${DateFormat('dd MMM yyyy').format(expectedHarvestDate!)}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Days Until Harvest: $daysUntilHarvest days',
                        style: TextStyle(
                          fontSize: 16,
                          color: daysUntilHarvest! <= 30
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Informative Text
            SizedBox(height: 20),
            Text(
              'Planting and Harvesting Scheduler helps you track crop growth timeline. Enter crop details and planting date to estimate harvest schedule.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    cropNameController.dispose();
    maturityPeriodController.dispose();
    super.dispose();
  }
}
