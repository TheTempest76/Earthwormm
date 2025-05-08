import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FarmingScheduleScreen extends StatefulWidget {
  final String cropName;
  final String fieldSize;
  final DateTime plantingDate;
  final String location;
  final String farmingType;

  const FarmingScheduleScreen({
    Key? key,
    required this.cropName,
    required this.fieldSize,
    required this.plantingDate,
    required this.location,
    required this.farmingType,
  }) : super(key: key);

  @override
  _FarmingScheduleScreenState createState() => _FarmingScheduleScreenState();
}

class _FarmingScheduleScreenState extends State<FarmingScheduleScreen> {
  bool _isLoading = false;
  String _scheduleResponse = '';

  @override
  void initState() {
    super.initState();
    _fetchFarmingSchedule();
  }

  Future<void> _fetchFarmingSchedule() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyCAGtWDRBB3dQf9eqiJLqAsjrUHpQB3seI",
        ),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "contents": [
            {
              "parts": [
                {
                  "text": """
                      Generate a farming schedule for crop '${widget.cropName}' with the following details:
                      - Field size: ${widget.fieldSize}
                      - Planting date: ${widget.plantingDate.day}/${widget.plantingDate.month}/${widget.plantingDate.year}
                      - Location: ${widget.location}
                      - Farming type: ${widget.farmingType}

                      Please break the schedule into sections using '****' to separate different sections. 
                      Each section should contain:
                      1. Date or time period (e.g., Day 1, Week 1, etc.)
                      2. Task description
                      For each section, break down the task into smaller subsections using '----' as the divider. 
                      Make each subsection descriptive, explaining the task thoroughly.

                      Do not leave any empty lines between sections or subsections.
                      Do not add any extra text; strictly follow the rules.
                  """
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String fullResponse =
            responseData['candidates'][0]['content']['parts'][0]['text'];

        setState(() {
          _scheduleResponse = fullResponse.trim();
        });
      } else {
        setState(() {
          _scheduleResponse = 'Failed to fetch farming schedule. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _scheduleResponse = 'Error fetching schedule data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Split the response based on '****' to handle sections, then by '----' for subsections
    List<String> scheduleSections = _scheduleResponse.split('****');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Farming Schedule'),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          if (_scheduleResponse.isNotEmpty && !_isLoading)
            ...scheduleSections.map((section) {
              // Split subsections by '----'
              List<String> subsections = section.split('----');
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle the date/period and task description
                      Text(
                        subsections.isNotEmpty ? subsections[0] : 'No date/period info',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Add each subsections as task descriptions
                      ...subsections.skip(1).map((subsection) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            subsection.trim(),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }).toList(),
          // Display raw response for testing purposes as a fallback
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _scheduleResponse,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ElevatedButton(
            onPressed: () {
              // Navigate to the next screen if needed
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_turned_in, size: 24),
                SizedBox(width: 12),
                Text(
                  'View Detailed Tasks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
