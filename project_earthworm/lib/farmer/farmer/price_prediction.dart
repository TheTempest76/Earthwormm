import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PricePredictionForm extends StatefulWidget {
  const PricePredictionForm({super.key});

  @override
  State<PricePredictionForm> createState() => _PricePredictionFormState();
}

class _PricePredictionFormState extends State<PricePredictionForm> {
  final _formKey = GlobalKey<FormState>();
  
  String? state;
  String? district;
  String? market;
  String? commodity;
  String? variety;
  String? grade;
  
  double? predictedPrice;
  bool isLoading = false;
  String? errorMessage;

  Future<void> getPrediction() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://evident-cosine-442010-n1-440160446921.us-central1.run.app/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'State': state,
          'District': district,
          'Market': market,
          'Commodity': commodity,
          'Variety': variety,
          'Grade': grade,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          predictedPrice = data['predicted_price'];
        });
      } else {
        setState(() {
          errorMessage = 'Failed to get prediction. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'State',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the state';
                }
                return null;
              },
              onSaved: (value) => state = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'District',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the district';
                }
                return null;
              },
              onSaved: (value) => district = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Market',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the market';
                }
                return null;
              },
              onSaved: (value) => market = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Commodity',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the commodity';
                }
                return null;
              },
              onSaved: (value) => commodity = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Variety',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the variety';
                }
                return null;
              },
              onSaved: (value) => variety = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Grade',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the grade';
                }
                return null;
              },
              onSaved: (value) => grade = value,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        getPrediction();
                      }
                    },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Get Price Prediction'),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (predictedPrice != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Predicted Price',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${predictedPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
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