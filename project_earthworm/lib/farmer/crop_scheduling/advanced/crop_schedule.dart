import 'package:flutter/material.dart';

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
