import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FarmerInsuranceSignup extends StatefulWidget {
  const FarmerInsuranceSignup({Key? key}) : super(key: key);

  @override
  _FarmerInsuranceSignupState createState() => _FarmerInsuranceSignupState();
}

class _FarmerInsuranceSignupState extends State<FarmerInsuranceSignup> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _mobileController = TextEditingController();
  final _landSizeController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedCrop = 'Rice';
  String _selectedState = 'Maharashtra';

  final List<String> _crops = [
    'Rice',
    'Wheat',
    'Cotton',
    'Sugarcane',
    'Pulses'
  ];
  final List<String> _states = [
    'Maharashtra',
    'Punjab',
    'Uttar Pradesh',
    'Karnataka',
    'Gujarat'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('किसान बीमा पंजीकरण / Farmer Insurance Signup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'पूरा नाम / Full Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Aadhaar Number
              TextFormField(
                controller: _aadhaarController,
                decoration: const InputDecoration(
                  labelText: 'आधार नंबर / Aadhaar Number *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 12,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Aadhaar number';
                  }
                  if (value.length != 12) {
                    return 'Aadhaar number must be 12 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mobile Number
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'मोबाइल नंबर / Mobile Number *',
                  border: OutlineInputBorder(),
                  prefixText: '+91 ',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter mobile number';
                  }
                  if (value.length != 10) {
                    return 'Mobile number must be 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date of Birth
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'जन्म तिथि / Date of Birth *',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // State Selection
              DropdownButtonFormField<String>(
                value: _selectedState,
                decoration: const InputDecoration(
                  labelText: 'राज्य / State *',
                  border: OutlineInputBorder(),
                ),
                items: _states.map((String state) {
                  return DropdownMenuItem(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedState = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Crop Selection
              DropdownButtonFormField<String>(
                value: _selectedCrop,
                decoration: const InputDecoration(
                  labelText: 'फसल / Crop *',
                  border: OutlineInputBorder(),
                ),
                items: _crops.map((String crop) {
                  return DropdownMenuItem(
                    value: crop,
                    child: Text(crop),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCrop = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Land Size
              TextFormField(
                controller: _landSizeController,
                decoration: const InputDecoration(
                  labelText: 'भूमि का आकार (एकड़ में) / Land Size (in acres) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter land size';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Implement form submission
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Processing Registration...'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'पंजीकरण करें / Register',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aadhaarController.dispose();
    _mobileController.dispose();
    _landSizeController.dispose();
    super.dispose();
  }
}
