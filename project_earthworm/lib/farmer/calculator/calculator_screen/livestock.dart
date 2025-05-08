import 'package:flutter/material.dart';

class LivestockFeedCalculatorScreen extends StatefulWidget {
  @override
  _LivestockFeedCalculatorScreenState createState() =>
      _LivestockFeedCalculatorScreenState();
}

class _LivestockFeedCalculatorScreenState
    extends State<LivestockFeedCalculatorScreen> {
  final TextEditingController animalWeightController = TextEditingController();
  final TextEditingController feedPercentageController =
      TextEditingController();

  double dailyFeedRequirement = 0.0;
  String selectedAnimalType = 'Cattle';

  // List of animal types with typical feed percentage ranges
  final List<Map<String, dynamic>> animalTypes = [
    {'type': 'Cattle', 'minFeedPercentage': 2.5, 'maxFeedPercentage': 3.5},
    {'type': 'Sheep', 'minFeedPercentage': 3.0, 'maxFeedPercentage': 4.0},
    {'type': 'Goat', 'minFeedPercentage': 3.5, 'maxFeedPercentage': 4.5},
    {'type': 'Horse', 'minFeedPercentage': 1.5, 'maxFeedPercentage': 2.5},
  ];

  void calculateDailyFeedRequirement() {
    double animalWeight = double.tryParse(animalWeightController.text) ?? 0;
    double feedPercentage = double.tryParse(feedPercentageController.text) ?? 0;

    setState(() {
      dailyFeedRequirement = animalWeight * (feedPercentage / 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livestock Feed Calculator'),
        backgroundColor: Color(0xFF2E7D32), // Dark Green
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Feed Requirement Calculator',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32), // Dark Green
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Calculate the daily feed requirement based on animal weight and feed percentage. Different animal types have varying feed requirements.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedAnimalType,
                decoration: InputDecoration(
                  labelText: 'Animal Type',
                  border: OutlineInputBorder(),
                  fillColor: Color(0xFFE8F5E9), // Light Green
                  filled: true,
                ),
                items: animalTypes.map<DropdownMenuItem<String>>((animal) {
                  return DropdownMenuItem(
                    value: animal['type'],
                    child: Text(animal['type']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAnimalType = value!;
                    // Automatically update feed percentage based on selected animal type
                    var selectedAnimal = animalTypes
                        .firstWhere((animal) => animal['type'] == value);
                    feedPercentageController.text =
                        ((selectedAnimal['minFeedPercentage'] +
                                    selectedAnimal['maxFeedPercentage']) /
                                2)
                            .toStringAsFixed(1);
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: animalWeightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Animal Weight (kg)',
                  border: OutlineInputBorder(),
                  fillColor: Color(0xFFE8F5E9), // Light Green
                  filled: true,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: feedPercentageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Feed Percentage of Body Weight (%)',
                  border: OutlineInputBorder(),
                  fillColor: Color(0xFFE8F5E9), // Light Green
                  filled: true,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: calculateDailyFeedRequirement,
                child: Text('Calculate Daily Feed Requirement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32), // Dark Green
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Daily Feed Requirement: ${dailyFeedRequirement.toStringAsFixed(2)} kg',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32), // Dark Green
                ),
              ),
              SizedBox(height: 20),
              // Additional Information Section
              Text(
                'Additional Information:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              ...animalTypes
                  .map((animal) => Text(
                        '${animal['type']}: ${animal['minFeedPercentage'].toStringAsFixed(1)}-${animal['maxFeedPercentage'].toStringAsFixed(1)}% of body weight',
                        style: TextStyle(fontSize: 16),
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}
