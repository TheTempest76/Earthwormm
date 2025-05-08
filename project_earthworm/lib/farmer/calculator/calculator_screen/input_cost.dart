import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputCostManagementScreen extends StatefulWidget {
  @override
  _InputCostManagementScreenState createState() =>
      _InputCostManagementScreenState();
}

class _InputCostManagementScreenState extends State<InputCostManagementScreen> {
  final TextEditingController seedCostController = TextEditingController();
  final TextEditingController fertilizerCostController =
      TextEditingController();
  final TextEditingController pesticideCostController = TextEditingController();
  final TextEditingController laborCostController = TextEditingController();
  final TextEditingController irrigationCostController =
      TextEditingController();

  double totalInputCost = 0.0;

  void calculateInputCost() {
    double seedCost = double.tryParse(seedCostController.text) ?? 0;
    double fertilizerCost = double.tryParse(fertilizerCostController.text) ?? 0;
    double pesticideCost = double.tryParse(pesticideCostController.text) ?? 0;
    double laborCost = double.tryParse(laborCostController.text) ?? 0;
    double irrigationCost = double.tryParse(irrigationCostController.text) ?? 0;

    setState(() {
      totalInputCost = seedCost +
          fertilizerCost +
          pesticideCost +
          laborCost +
          irrigationCost;
    });
  }

  String formatCurrency(double value) {
    return '₹ ${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Cost Management'),
        backgroundColor: Color(0xFF1E88E5), // Green
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Input Cost Calculation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E88E5), // Blue
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Calculate the total input cost by summing expenses for seeds, fertilizers, pesticides, labor, and irrigation.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Input Fields
            _buildCostTextField(seedCostController, 'Cost of Seeds'),
            SizedBox(height: 10),
            _buildCostTextField(
                fertilizerCostController, 'Cost of Fertilizers'),
            SizedBox(height: 10),
            _buildCostTextField(pesticideCostController, 'Cost of Pesticides'),
            SizedBox(height: 10),
            _buildCostTextField(laborCostController, 'Labor Cost'),
            SizedBox(height: 10),
            _buildCostTextField(irrigationCostController, 'Irrigation Cost'),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateInputCost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50), // Green
              ),
              child: Text('Calculate Total Cost'),
            ),

            SizedBox(height: 20),
            Text(
              'Total Input Cost: ${formatCurrency(totalInputCost)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E88E5), // Blue
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        fillColor: Color(0xFFE3F2FD), // Light blue
        filled: true,
        prefixText: '₹ ',
      ),
    );
  }
}
