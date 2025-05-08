import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'crop_schedule.dart';

class CropQuestionnaireScreen extends StatefulWidget {
  const CropQuestionnaireScreen({super.key});

  @override
  State<CropQuestionnaireScreen> createState() =>
      _CropQuestionnaireScreenState();
}

class _CropQuestionnaireScreenState extends State<CropQuestionnaireScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Form values
  String? location;
  String? cropType;
  bool recommendCrop = false;
  String? landSize;
  DateTime? plantingDate;
  String? irrigationType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(
            'Location services are disabled. Please enable them in settings.');
      }

      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(
              'Location permissions are denied. Grant permissions to continue.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied. Enable them in settings.');
      }

      // Fetch the current location
      setState(() => _isLoading = true);
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Update location and proceed to next step
      setState(() {
        location = "Lat: ${position.latitude}, Long: ${position.longitude}";
        _isLoading = false;
        _currentStep = 1; // Move to next step automatically
      });
    } catch (e) {
      // Log and display user-friendly error messages
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farming Plan'),
        backgroundColor: Colors.green[700],
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 4) {  // Ensure the last step index is 4
              setState(() {
                _currentStep++;
              });
            } else {
              // Navigate to the next screen (as before)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FarmingScheduleScreen(
                    cropName: cropType ?? 'No crop selected', // Handle "No crop selected"
                    fieldSize: landSize ?? '',
                    plantingDate: plantingDate ?? DateTime.now(),
                    location: location ?? '',
                    farmingType: irrigationType ?? '', // Pass irrigation type as farming type
                  ),
                ),
              );
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            }
          },
          steps: [
            Step(
              title: const Text('Location'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Text(location ?? 'Location not fetched'),
                ],
              ),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('Crop Type'),
              content: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Recommend crop'),
                    value: recommendCrop,
                    onChanged: (value) {
                      setState(() {
                        recommendCrop = value ?? false;
                        // If recommended, set cropType to "Recommend a crop"
                        if (recommendCrop) {
                          cropType = 'Recommend a crop';
                        } else {
                          cropType = null; // Reset cropType if not recommended
                        }
                      });
                    },
                  ),
                  if (!recommendCrop)
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Enter crop type',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => cropType = value,
                      validator: (value) => recommendCrop || (value?.isNotEmpty ?? false)
                          ? null
                          : 'Please enter or recommend a crop type',
                    ),
                ],
              ),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text('Land Size'),
              content: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Enter land size in acres',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => landSize = value,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter land size' : null,
              ),
              isActive: _currentStep >= 2,
            ),
            Step(
              title: const Text('Planting Date'),
              content: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => plantingDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Select planting date',
                  ),
                  child: Text(
                    plantingDate != null
                        ? '${plantingDate!.day}/${plantingDate!.month}/${plantingDate!.year}'
                        : 'Tap to select date',
                  ),
                ),
              ),
              isActive: _currentStep >= 3,
            ),
            Step(
              title: const Text('Irrigation Type'),
              content: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select irrigation type',
                ),
                items: [
                  'Drip',
                  'Sprinkler',
                  'Flood',
                  'Furrow',
                  'Rain-fed'
                ].map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                    .toList(),
                onChanged: (value) => setState(() => irrigationType = value),
                validator: (value) =>
                    value == null ? 'Please select an irrigation type' : null,
              ),
              isActive: _currentStep >= 4,
            ),
          ],
        ),
      ),
    );
  }
}
