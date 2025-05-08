import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoanSubsidyCalculatorScreen extends StatefulWidget {
  @override
  _LoanSubsidyCalculatorScreenState createState() =>
      _LoanSubsidyCalculatorScreenState();
}

class _LoanSubsidyCalculatorScreenState
    extends State<LoanSubsidyCalculatorScreen> {
  // Controllers for input fields
  final TextEditingController principalController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController loanTermController = TextEditingController();
  final TextEditingController eligibleExpenseController =
      TextEditingController();
  final TextEditingController subsidyPercentageController =
      TextEditingController();

  // Variables to store calculated results
  double loanRepaymentAmount = 0.0;
  double subsidyAmount = 0.0;

  void calculateLoanAndSubsidy() {
    // Parse input values with error handling
    double principal = double.tryParse(principalController.text) ?? 0;
    double interestRate = double.tryParse(interestRateController.text) ?? 0;
    double loanTerm = double.tryParse(loanTermController.text) ?? 0;
    double eligibleExpense =
        double.tryParse(eligibleExpenseController.text) ?? 0;
    double subsidyPercentage =
        double.tryParse(subsidyPercentageController.text) ?? 0;

    setState(() {
      // Loan Repayment Calculation: Principal × (1 + Interest rate)^Time
      loanRepaymentAmount =
          principal * math.pow((1 + (interestRate / 100)), loanTerm);

      // Subsidy Amount Calculation: Approved subsidy percentage × Eligible expense
      subsidyAmount = (subsidyPercentage / 100) * eligibleExpense;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loan & Subsidy Calculator'),
        backgroundColor: Color(0xFF1E88E5), // Blue
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loan and Subsidy Calculations',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50), // Green
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Calculate your loan repayment and potential subsidy. Enter the details below to get accurate financial insights.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Loan Calculation Section
            Text(
              'Loan Calculation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3), // Blue
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: principalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Principal Amount (₹)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE3F2FD), // Light blue
                filled: true,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: interestRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Interest Rate (%)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE3F2FD), // Light blue
                filled: true,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: loanTermController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Loan Term (Years)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE3F2FD), // Light blue
                filled: true,
              ),
            ),

            // Subsidy Calculation Section
            SizedBox(height: 20),
            Text(
              'Subsidy Calculation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50), // Green
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: eligibleExpenseController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Eligible Expense (₹)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE3F2FD), // Light blue
                filled: true,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: subsidyPercentageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Subsidy Percentage (%)',
                border: OutlineInputBorder(),
                fillColor: Color(0xFFE3F2FD), // Light blue
                filled: true,
              ),
            ),

            // Calculate Button
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateLoanAndSubsidy,
              child: Text('Calculate Loan & Subsidy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50), // Green
              ),
            ),

            // Results Section
            SizedBox(height: 20),
            Text(
              'Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3), // Blue
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Loan Repayment Amount: ₹${loanRepaymentAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF4CAF50), // Green
              ),
            ),
            Text(
              'Subsidy Amount: ₹${subsidyAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF4CAF50), // Green
              ),
            ),
          ],
        ),
      ),
    );
  }
}
