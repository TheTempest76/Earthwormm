// implementation_screens.dart

import 'package:flutter/material.dart';
import 'todo.dart';

// First Screen: Questionnaire
class FarmingMethodQuestionnaireScreen extends StatefulWidget {
  final String methodName;

  const FarmingMethodQuestionnaireScreen({
    Key? key,
    required this.methodName,
  }) : super(key: key);

  @override
  State<FarmingMethodQuestionnaireScreen> createState() =>
      _FarmingMethodQuestionnaireScreenState();
}

class _FarmingMethodQuestionnaireScreenState
    extends State<FarmingMethodQuestionnaireScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Form values
  String? landSize;
  DateTime? implementationDate;
  String? currentFarmingMethod;
  String? waterAvailability;
  String? budget;
  String? laborAvailability;

  void _navigateToSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImplementationScheduleScreen(
          methodName: widget.methodName,
          landSize: landSize ?? '',
          implementationDate: implementationDate ?? DateTime.now(),
          currentMethod: currentFarmingMethod ?? '',
          waterAvailability: waterAvailability ?? '',
          budget: budget ?? '',
          laborAvailability: laborAvailability ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.methodName} Implementation'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 5) {
              setState(() => _currentStep++);
            } else {
              _navigateToSchedule();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          steps: [
            Step(
              title: const Text('Land Size'),
              content: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Enter land size in acres/hectares',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => landSize = value,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter land size' : null,
              ),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('Implementation Date'),
              content: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => implementationDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Select implementation start date',
                  ),
                  child: Text(
                    implementationDate != null
                        ? '${implementationDate!.day}/${implementationDate!.month}/${implementationDate!.year}'
                        : 'Tap to select date',
                  ),
                ),
              ),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text('Current Farming Method'),
              content: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select current farming method',
                ),
                items: [
                  'Traditional Manual Farming',
                  'Basic Mechanized Farming',
                  'Mixed Farming',
                  'Subsistence Farming',
                  'Other'
                ]
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => currentFarmingMethod = value),
              ),
              isActive: _currentStep >= 2,
            ),
            Step(
              title: const Text('Water Availability'),
              content: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select water availability',
                ),
                items: [
                  'Abundant (Year-round)',
                  'Seasonal',
                  'Limited',
                  'Dependent on Rain',
                  'Borewell Available'
                ]
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => waterAvailability = value),
              ),
              isActive: _currentStep >= 3,
            ),
            Step(
              title: const Text('Budget Range'),
              content: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select budget range',
                ),
                items: [
                  'Less than ₹50,000',
                  '₹50,000 - ₹1,00,000',
                  '₹1,00,000 - ₹5,00,000',
                  'Above ₹5,00,000'
                ]
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => budget = value),
              ),
              isActive: _currentStep >= 4,
            ),
            Step(
              title: const Text('Labor Availability'),
              content: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select labor availability',
                ),
                items: [
                  'Family Labor Only',
                  'Limited Hired Labor',
                  'Adequate Hired Labor',
                  'Mechanization Preferred'
                ]
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => laborAvailability = value),
              ),
              isActive: _currentStep >= 5,
            ),
          ],
        ),
      ),
    );
  }
}

// Second Screen: Implementation Schedule
class ImplementationScheduleScreen extends StatelessWidget {
  final String methodName;
  final String landSize;
  final DateTime implementationDate;
  final String currentMethod;
  final String waterAvailability;
  final String budget;
  final String laborAvailability;

  const ImplementationScheduleScreen({
    Key? key,
    required this.methodName,
    required this.landSize,
    required this.implementationDate,
    required this.currentMethod,
    required this.waterAvailability,
    required this.budget,
    required this.laborAvailability,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Implementation Schedule'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildScheduleTimeline(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              // Navigate to detailed tasks
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TodoPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'View Detailed Tasks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Implementing $methodName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Land Size', landSize),
            _buildInfoRow('Start Date',
                '${implementationDate.day}/${implementationDate.month}/${implementationDate.year}'),
            _buildInfoRow('Current Method', currentMethod),
            _buildInfoRow('Water Availability', waterAvailability),
            _buildInfoRow('Budget', budget),
            _buildInfoRow('Labor', laborAvailability),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTimeline() {
    final scheduleItems = _getImplementationSchedule();
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Implementation Timeline',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            ...scheduleItems.map((item) => _buildTimelineItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, String> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['phase']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['tasks']!,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getImplementationSchedule() {
    // This would be customized based on the farming method
    return [
      {
        'phase': 'Planning Phase (Week 1-2)',
        'tasks':
            'Site assessment, resource planning, and consultation with agricultural experts'
      },
      {
        'phase': 'Preparation Phase (Week 3-4)',
        'tasks': 'Land preparation, procurement of equipment and materials'
      },
      {
        'phase': 'Initial Setup (Week 5-6)',
        'tasks':
            'Installation of basic infrastructure and training of farm workers'
      },
      {
        'phase': 'Implementation (Week 7-10)',
        'tasks':
            'Gradual transition to new farming method with expert supervision'
      },
      {
        'phase': 'Monitoring & Adjustment (Week 11-12)',
        'tasks':
            'Performance monitoring and necessary adjustments to the system'
      },
      {
        'phase': 'Full Operation (Week 13 onwards)',
        'tasks':
            'Complete transition to new farming method with regular monitoring'
      },
    ];
  }
}
