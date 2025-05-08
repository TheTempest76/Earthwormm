import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizPage extends StatefulWidget {
  final String topic;

  QuizPage({required this.topic});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String _question = '';
  List<String> _options = [];
  String _correctAnswer = '';
  String _explanation = '';
  String? _selectedAnswer;
  String _result = '';

  bool _answered = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
  }

  Future<void> _fetchQuizData() async {
    setState(() {
      _isLoading = true;
      _answered = false;
    });

    try {
      final response = await http.post(
        Uri.parse(
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyCAGtWDRBB3dQf9eqiJLqAsjrUHpQB3seI"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "contents": [
            {
              "parts": [
                {
                  "text": "Generate a quiz based on the topic '${widget.topic}'. The response should contain:\n"
                      "- A question (first line),\n"
                      "- Four options (second line, separated by commas),\n"
                      "- The correct answer (third line, format exactly like in the option),\n"
                      "- An explanation (fourth line).\n"
                      "Please do not use ** for bold formatting."
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

        List<String> responseParts =
            fullResponse.split("\n").map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

        if (responseParts.length >= 4) {
          setState(() {
            _question = responseParts[0];
            _options = responseParts[1].split(",").map((option) => option.trim()).toList();
            _correctAnswer = responseParts[2].replaceFirst("Correct answer: ", "").trim();
            _explanation = responseParts[3].trim();
          });
        } else {
          setState(() {
            _question = "Error: Quiz data is incomplete.";
            _options = [];
            _correctAnswer = "";
            _explanation = "";
          });
        }
      } else {
        setState(() {
          _question = "Failed to fetch quiz question. Status code: ${response.statusCode}";
          _options = [];
          _correctAnswer = "";
          _explanation = "";
        });
      }
    } catch (e) {
      setState(() {
        _question = "Error fetching quiz data: $e";
        _options = [];
        _correctAnswer = "";
        _explanation = "";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onAnswerSelected(String? answer) {
    setState(() {
      _selectedAnswer = answer;
    });
  }

  Future<void> _storeScoreInFirestore() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print("Error: No authenticated user found.");
        return;
      }

      String farmerDocId = currentUser.uid;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('farmers').doc(farmerDocId).set({
        'scores': {
          widget.topic: FieldValue.increment(10),
        }
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error storing score: $e");
    }
  }

  void _submitQuiz() async {
    setState(() {
      _answered = true;
      if (_selectedAnswer == _correctAnswer) {
        _result = 'Correct!';
        _storeScoreInFirestore();
      } else {
        _result = 'Incorrect. The correct answer is $_correctAnswer.';
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _isLoading = true;
      _question = '';
      _options = [];
      _correctAnswer = '';
      _explanation = '';
      _selectedAnswer = null;
      _result = '';
      _answered = false;
    });
    _fetchQuizData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.topic}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading) Center(child: CircularProgressIndicator()),
            if (_question.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.question_mark, size: 30),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _question,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20),
            if (_options.isNotEmpty)
              ..._options.map((option) {
                return ListTile(
                  title: Text(option),
                  leading: Radio<String?>(
                    value: option,
                    groupValue: _selectedAnswer,
                    onChanged: _onAnswerSelected,
                  ),
                );
              }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _answered ? null : _submitQuiz,
              child: Text('Submit'),
            ),
            SizedBox(height: 20),
            if (_answered)
              Text(
                _result,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _result == 'Correct!' ? Colors.green : Colors.red,
                ),
              ),
            SizedBox(height: 20),
            if (_answered)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Correct Answer: $_correctAnswer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Explanation: $_explanation',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            SizedBox(height: 20),
            if (_answered)
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text('Next Question'),
              ),
          ],
        ),
      ),
    );
  }
}