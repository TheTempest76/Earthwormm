import 'package:flutter/material.dart';
import 'videos_page.dart';
import 'quiz_page.dart';

class OptionsPage extends StatelessWidget {
  final String topic;

  OptionsPage({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Method'), // Shorter title
        backgroundColor: Colors.green, // Green theme for the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Smaller, non-bold, descriptive title
            Text(
              'What would you like to explore about $topic?',
              style: TextStyle(
                fontSize: 16, // Smaller font size for a softer look
                fontWeight: FontWeight.normal, // Normal weight (not bold)
                color: Colors.green[600], // Darker green for text color
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // Watch Videos Option with Green Gradient
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideosPage(topic: topic),
                  ),
                );
              },
              child: Container(
                width: 250,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.lightGreen], // Green gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        'Watch Videos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Play Quiz Option with Green Gradient
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPage(topic: topic),
                  ),
                );
              },
              child: Container(
                width: 250,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.green[400]!, Colors.green[200]!], // Lighter green gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        'Play Quiz',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
