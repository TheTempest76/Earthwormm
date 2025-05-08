import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotWebView extends StatefulWidget {
  const ChatbotWebView({super.key});

  @override
  State<ChatbotWebView> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatbotWebView> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage(String userMessage) async {
    setState(() {
      _isLoading = true;
      _messages.add({'role': 'user', 'message': userMessage});
    });

    try {
      final response = await http.post(
        Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyDVgJvXxHMTzH7Jd2IXuOcGMGNp_R8_uX0",
        ),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "contents": [
            {
              "parts": [
                {"text": "You are a Demo farming assistant chatbot, make up believable prompt answers. Answer user queries in a short informative. Don't ask questions or dont ask for additional information take it as south india just do your best to provide information to the prompt below"},
                {"text": userMessage}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reply = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _messages.add({'role': 'bot', 'message': reply});
        });
      } else {
        setState(() {
          _messages.add({
            'role': 'bot',
            'message': 'Error: Unable to get a response. Status code: ${response.statusCode}'
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'message': 'Exception: $e'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildMessage(Map<String, String> msg) {
    bool isUser = msg['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isUser ? Colors.green[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(msg['message'] ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farming Assistant Bot"),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask something...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    _controller.clear();
                    _sendMessage(text);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
