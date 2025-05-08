import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'options_page.dart';

class LearnHome extends StatelessWidget {
  final List<String> topics = [
    'Soil Preparation',
    'Irrigation Techniques',
    'Crop Rotation',
    'Pest Management',
    'Organic Farming',
    'Sustainable Agriculture',
    'Greenhouse Techniques',
  ];

  final List<IconData> topicIcons = [
    Icons.grain, // Soil Preparation
    Icons.water, // Irrigation Techniques
    Icons.rotate_left, // Crop Rotation
    Icons.pest_control, // Pest Management
    Icons.eco, // Organic Farming
    Icons.nature_people, // Sustainable Agriculture
    Icons.local_florist, // Greenhouse Techniques
  ];

  // Fetch scores for the current user from Firestore
  Future<Map<String, int>> _fetchScores() async {
    try {
      // Get the currently signed-in user
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not signed in');
      }

      // Fetch the user's document from Firestore
      final doc = await FirebaseFirestore.instance.collection('farmers').doc(user.uid).get();

      // Retrieve scores or return an empty map
      return Map<String, int>.from(doc.data()?['scores'] ?? {});
    } catch (e) {
      // Handle errors (e.g., log them or return an empty map)
      print('Error fetching scores: $e');
      return {};
    }
  }

  // Build star widgets based on the score
  Widget _buildStars(int score) {
    List<Widget> stars = [];

    // Custom colors for stars
    const bronzeColor = Color(0xFFCD7F32);
    const silverColor = Color(0xFFC0C0C0);
    const goldColor = Color(0xFFFFD700);

    // Add stars based on score
    if (score >= 100) stars.add(Icon(Icons.star, color: bronzeColor, size: 20));
    if (score >= 300) stars.add(Icon(Icons.star, color: silverColor, size: 20));
    if (score >= 500) stars.add(Icon(Icons.star, color: goldColor, size: 20));

    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farming Practices'),
        backgroundColor: Colors.green, // Green theme for app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, int>>(
          future: _fetchScores(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading scores.'));
            }

            final scores = snapshot.data ?? {};

            return SingleChildScrollView(
              child: GridView.builder(
                shrinkWrap: true, // Prevent the grid from taking up more space than necessary
                physics: NeverScrollableScrollPhysics(), // Disable the internal scrolling of GridView
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two cards per row
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8, // Adjust aspect ratio as needed
                ),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  final score = scores[topic] ?? 0;

                  return GestureDetector(
                    onTap: () {
                      // Navigate to the next page with the selected topic
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OptionsPage(topic: topic),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.green[50], // Light green background for cards
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              topicIcons[index],
                              size: 40,
                              color: Colors.green, // Green icon color
                            ),
                            SizedBox(height: 10),
                            Text(
                              topic,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800], // Darker green text color
                              ),
                            ),
                            SizedBox(height: 10),
                            _buildStars(score), // Display stars based on score
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
