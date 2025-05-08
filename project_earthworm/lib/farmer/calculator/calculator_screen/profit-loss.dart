import 'package:flutter/material.dart';

class ProfitLossCalculatorScreen extends StatefulWidget {
  const ProfitLossCalculatorScreen({Key? key}) : super(key: key);

  @override
  _ProfitLossCalculatorScreenState createState() =>
      _ProfitLossCalculatorScreenState();
}

class _ProfitLossCalculatorScreenState
    extends State<ProfitLossCalculatorScreen> {
  final TextEditingController revenueController = TextEditingController();
  final TextEditingController inputCostsController = TextEditingController();
  final TextEditingController laborCostsController = TextEditingController();
  final TextEditingController equipmentCostsController =
      TextEditingController();

  double totalRevenue = 0.0;
  double totalExpenses = 0.0;
  double netProfit = 0.0;
  double profitMargin = 0.0;

  void calculateProfitLoss() {
    setState(() {
      totalRevenue = double.tryParse(revenueController.text) ?? 0;
      double inputCosts = double.tryParse(inputCostsController.text) ?? 0;
      double laborCosts = double.tryParse(laborCostsController.text) ?? 0;
      double equipmentCosts =
          double.tryParse(equipmentCostsController.text) ?? 0;

      totalExpenses = inputCosts + laborCosts + equipmentCosts;
      netProfit = totalRevenue - totalExpenses;
      profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit & Loss Analysis'),
        backgroundColor: const Color(0xFF4CAF50), // Green theme
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Performance Analysis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Analyze your business financial performance by calculating revenue, expenses, net profit, and profit margin.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: revenueController,
              labelText: 'Total Revenue (₹)',
              hintText: 'Enter total revenue',
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: inputCostsController,
              labelText: 'Input Costs (₹)',
              hintText: 'Enter input costs',
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: laborCostsController,
              labelText: 'Labor Costs (₹)',
              hintText: 'Enter labor costs',
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: equipmentCostsController,
              labelText: 'Equipment Costs (₹)',
              hintText: 'Enter equipment costs',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateProfitLoss,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Calculate Profit & Loss'),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Financial Analysis Results',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildResultRow(
                      'Total Revenue', '₹${totalRevenue.toStringAsFixed(2)}'),
                  _buildResultRow(
                      'Total Expenses', '₹${totalExpenses.toStringAsFixed(2)}'),
                  _buildResultRow(
                      'Net Profit', '₹${netProfit.toStringAsFixed(2)}',
                      color: netProfit >= 0 ? Colors.green : Colors.red),
                  _buildResultRow(
                      'Profit Margin', '${profitMargin.toStringAsFixed(2)}%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        fillColor: const Color(0xFFE8F5E9),
        filled: true,
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
