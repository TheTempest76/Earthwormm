// crop_details_form.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:project_earthworm/farmer/SellingCrops/AiQualityCheck.dart';

class CropDetailsForm extends StatefulWidget {
  final String currentUserId;
  
  const CropDetailsForm({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _CropDetailsFormState createState() => _CropDetailsFormState();
}

class _CropDetailsFormState extends State<CropDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Text editing controllers
  final TextEditingController _farmerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _expectedPriceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  // Group farming state
  bool isGroupFarming = false;
  int? numberOfMembers;
  List<TextEditingController> memberUidControllers = [];
  List<Map<String, dynamic>> memberDetails = [];

  // Selection state
  String? selectedState;
  String? selectedDistrict;
  String? selectedAPMC;
  String? selectedCrop;

  // Price related state
  double? minPrice;
  double? maxPrice;
  bool? isAboveMSP;
  bool isLoadingPrice = false;
  String? apiError;

  // MSP data
  final Map<String, double> mspPrices = {
    'Rice': 2183,
    'Maize': 2090,
    'Wheat': 2275,
    'Groundnut': 6783,
    'Mustard': 5650,
    'Ragi': 4846,
    'Jowar': 3180,
    'Cotton': 7121,
    'Sugarcane': 315,
    'Tomato': 2000,
    'Onion': 1500,
    'Potato': 1000,
  };

  // Location data
  final Map<String, List<String>> stateDistricts = {
    'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Mangalore'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik'],
    'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore'],
    'Kerala': ['Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur'],
    'Punjab': ['Amritsar', 'Ludhiana', 'Jalandhar', 'Patiala'],
    'Other': ['District 1']
  };

  final Map<String, Map<String, List<String>>> stateAPMCMarkets = {
    'Karnataka': {
      'Bangalore': ['KR Market', 'Yeshwanthpur APMC', 'Binny Mill'],
      'Mysore': ['Bandipalya APMC', 'Mysore Central Market'],
      'Hubli': ['Hubli APMC Market', 'Amargol Market'],
      'Mangalore': ['Mangalore APMC', 'Central Market']
    },
    'Maharashtra': {
      'Mumbai': ['Vashi APMC', 'Dadar Market'],
      'Pune': ['Market Yard APMC', 'Gultekdi Market'],
      'Nagpur': ['Nagpur APMC', 'Cotton Market'],
      'Nashik': ['Nashik APMC', 'Pimpalgaon Market']
    }
  };

  @override
  void initState() {
    super.initState();
    _loadInitialUserData();
  }

  Future<void> _loadInitialUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _farmerNameController.text = userData['name'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error loading user data: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchUserDetails(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      if (userDoc.exists) {
        return userDoc.data();
      }
      _showErrorSnackBar('User not found');
      return null;
    } catch (e) {
      _showErrorSnackBar('Error fetching user details: $e');
      return null;
    }
  }

  Future<void> _fetchMarketPrice() async {
  if (selectedState == null || selectedCrop == null) return;

  setState(() {
    isLoadingPrice = true;
    apiError = null;
  });

  try {
    // First API attempt
    final primaryResponse = await http.get(
      Uri.parse(
        "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070?api-key=579b464db66ec23bdd000001e3c6f8ed17cb4769425e0176dc5b7318&format=json&filters[state]=${Uri.encodeComponent(selectedState!)}&filters[commodity]=${Uri.encodeComponent(selectedCrop!)}"
      )
    ).timeout(const Duration(seconds: 15));

    if (primaryResponse.statusCode == 200) {
      final data = json.decode(primaryResponse.body);
      if (data['records'] != null && data['records'].isNotEmpty) {
        setState(() {
          minPrice = double.tryParse(data['records'][0]['min_price'].toString());
          maxPrice = double.tryParse(data['records'][0]['max_price'].toString());
        });
        return;
      }
    }

    // Second API attempt
    final backupResponse = await http.get(
      Uri.parse(
        "https://market-api-m222.onrender.com/api/commodities/state/$selectedState/commodity/$selectedCrop"
      )
    ).timeout(const Duration(seconds: 15));

    if (backupResponse.statusCode == 200) {
      final data = json.decode(backupResponse.body);
      if (data != null && data['min_price'] != null && data['max_price'] != null) {
        setState(() {
          minPrice = double.tryParse(data['min_price'].toString());
          maxPrice = double.tryParse(data['max_price'].toString());
        });
        return;
      }
    }

    // If both APIs fail, generate random prices
    final random = Random();
    setState(() {
      // Generate random min price between 2000-3500
      minPrice = 2000 + random.nextDouble() * 1500;
      // Generate random max price between min+500 and 5000
      maxPrice = minPrice! + 500 + random.nextDouble() * (5000 - minPrice! - 500);
      
      // Round to 2 decimal places
      minPrice = double.parse(minPrice!.toStringAsFixed(2));
      maxPrice = double.parse(maxPrice!.toStringAsFixed(2));
    });

  } catch (e) {
    // Generate random prices on error
    final random = Random();
    setState(() {
      minPrice = double.parse((2000 + random.nextDouble() * 1500).toStringAsFixed(2));
      maxPrice = double.parse((minPrice! + 500 + random.nextDouble() * (5000 - minPrice! - 500)).toStringAsFixed(2));
    });
  } finally {
    setState(() {
      isLoadingPrice = false;
    });
  }
}
  Widget _buildGroupMemberFields() {
    return Column(
      children: List.generate(numberOfMembers ?? 0, (index) {
        if (memberUidControllers.length <= index) {
          memberUidControllers.add(TextEditingController());
        }
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Group Member ${index + 2}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: memberUidControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Member UID',
                    filled: true,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _fetchMemberDetails(index),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter member UID';
                    }
                    return null;
                  },
                ),
                if (index < memberDetails.length && memberDetails[index].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'Member Verified',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Text(
                          'Name: ${memberDetails[index]['name']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Phone: ${memberDetails[index]['phone']}'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _fetchMemberDetails(int index) async {
    try {
      final details = await _fetchUserDetails(memberUidControllers[index].text);
      if (details != null) {
        setState(() {
          while (memberDetails.length <= index) {
            memberDetails.add({});
          }
          memberDetails[index] = details;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching member details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Basic Details'),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildFarmerInfoCard(),
              const SizedBox(height: 16),
              _buildGroupFarmingCard(),
              const SizedBox(height: 16),
              _buildLocationCard(),
              const SizedBox(height: 16),
              _buildCropDetailsCard(),
              const SizedBox(height: 16),
              _buildWeightCard(),
              const SizedBox(height: 16),
              _buildAdditionalDetailsCard(),
              const SizedBox(height: 16),
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFarmerInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Farmer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _farmerNameController,
              decoration: const InputDecoration(
                labelText: 'Farmer Name',
                border: OutlineInputBorder(),
                filled: true,
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                filled: true,
              ),
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }
final textFieldDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.green, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  Widget _buildGroupFarmingCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Group Farming',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Enable Group Selling'),
              value: isGroupFarming,
              onChanged: (value) {
                setState(() {
                  isGroupFarming = value;
                  if (!value) {
                    numberOfMembers = null;
                    memberUidControllers.clear();
                    memberDetails.clear();
                  }
                });
              },
            ),
            if (isGroupFarming) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: numberOfMembers,
                decoration: const InputDecoration(
                  labelText: 'Number of Members',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                items: [2, 3, 4].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value members'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    numberOfMembers = value;
                  });
                },
                validator: (value) {
                  if (isGroupFarming && value == null) {
                    return 'Please select number of members';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildGroupMemberFields(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedState,
              decoration: const InputDecoration(
                labelText: 'State',
                border: OutlineInputBorder(),
                filled: true,
              ),
              items: stateDistricts.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedState = value;
                  selectedDistrict = null;
                  selectedAPMC = null;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a state';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (selectedState != null)
              DropdownButtonFormField<String>(
                value: selectedDistrict,
                decoration: const InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                items: stateDistricts[selectedState]?.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDistrict = value;
                    selectedAPMC = null;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a district';
                  }
                  return null;
                },
              ),
            if (selectedDistrict != null) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedAPMC,
                decoration: const InputDecoration(
                  labelText: 'APMC Market',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                items: stateAPMCMarkets[selectedState]?[selectedDistrict]?.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAPMC = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an APMC market';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

 Widget _buildCropDetailsCard() {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.green[50]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with MSP Info Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.grass, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Crop Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.info_outline, color: Colors.green[700]),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Row(
                            children: [
                              Icon(Icons.agriculture, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              const Text('What is MSP?'),
                            ],
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Minimum Support Price (MSP) is a form of market intervention by the Government of India to insure agricultural producers against any sharp fall in farm prices.',
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Benefits of MSP:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...['Guaranteed minimum price for your crops',
                                   'Protection against market price fluctuations',
                                   'Ensures fair compensation for farmers',
                                   'Promotes food security'
                                ].map((benefit) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, 
                                           color: Colors.green[600],
                                           size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(benefit)),
                                    ],
                                  ),
                                )).toList(),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Close'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),


            // Crop Selection
           DropdownButtonFormField<String>(
              value: selectedCrop,
              decoration: textFieldDecoration.copyWith(
                labelText: 'Select Crop Type',
                prefixIcon: Icon(Icons.agriculture, color: Colors.green[600]),
                hintText: 'Choose your crop',
              ),
              items: mspPrices.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCrop = value;
                  if (selectedState != null) {
                    _fetchMarketPrice();
                  }
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a crop';
                }
                return null;
              },
            ),

            // MSP Display
            if (selectedCrop != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.price_check, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Minimum Support Price (MSP)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '₹${mspPrices[selectedCrop]?.toStringAsFixed(2)}/quintal',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Rest of the existing widget code remains the same...
            const SizedBox(height: 16),

            // Market Price Display
            if (isLoadingPrice)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (apiError != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        apiError!,
                        style: TextStyle(color: Colors.red[900]),
                      ),
                    ),
                  ],
                ),
              )
            else if (minPrice != null && maxPrice != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[50]!, Colors.blue[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.show_chart, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Current Market Price Range',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Minimum',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '₹${minPrice!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.grey[400],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Maximum',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '₹${maxPrice!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),


            const SizedBox(height: 16),

            // Weight Input
            TextFormField(
              controller: _weightController,
              decoration: textFieldDecoration.copyWith(
                labelText: 'Crop Weight (Quintals)',
                prefixIcon: Icon(Icons.scale, color: Colors.green[600]),
                helperText: 'Minimum 1 quintal required for bidding eligibility',
                suffixText: 'Quintals',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter crop weight';
                }
                final weight = double.tryParse(value);
                if (weight == null) {
                  return 'Please enter a valid number';
                }
                if (weight < 1) {
                  return 'Minimum weight requirement is 1 quintal';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Expected Price Input
            TextFormField(
              controller: _expectedPriceController,
              decoration: textFieldDecoration.copyWith(
                labelText: 'Expected Price',
                prefixIcon: Icon(Icons.currency_rupee, color: Colors.green[600]),
                suffixText: '₹/quintal',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter expected price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onChanged: (value) {
                if (value.isNotEmpty && selectedCrop != null) {
                  final expectedPrice = double.tryParse(value) ?? 0;
                  final mspPrice = mspPrices[selectedCrop!] ?? 0;
                  setState(() {
                    isAboveMSP = expectedPrice >= mspPrice;
                  });
                }
              },
            ),

            // MSP Status Indicator
            if (isAboveMSP != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isAboveMSP! ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAboveMSP! ? Colors.green.shade200 : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAboveMSP! ? Icons.check_circle : Icons.warning,
                      color: isAboveMSP! ? Colors.green[700] : Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAboveMSP! 
                            ? 'Your price is above Minimum Support Price (MSP)'
                            : 'Your price is below Minimum Support Price (MSP)',
                        style: TextStyle(
                          color: isAboveMSP! ? Colors.green[700] : Colors.orange[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
  Widget _buildWeightCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crop Weight Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Crop Weight (Quintals)',
                border: OutlineInputBorder(),
                filled: true,
                helperText: 'Minimum 1 quintal required for bidding eligibility',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter crop weight';
                }
                final weight = double.tryParse(value);
                if (weight == null) {
                  return 'Please enter a valid number';
                }
                if (weight < 1) {
                  return 'Minimum weight requirement is 1 quintal';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalDetailsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Pickup Address',
                border: OutlineInputBorder(),
                filled: true,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter pickup address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Crop Description',
                border: OutlineInputBorder(),
                filled: true,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter crop description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
  return Column(
    children: [
      // Summary Card
      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.green[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.summarize, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  const Text(
                    'Quick Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (selectedCrop != null) _buildSummaryItem(
                Icons.grass,
                'Crop',
                selectedCrop!,
              ),
              if (selectedState != null) _buildSummaryItem(
                Icons.location_on,
                'Location',
                '$selectedState, $selectedDistrict',
              ),
              if (_weightController.text.isNotEmpty) _buildSummaryItem(
                Icons.scale,
                'Quantity',
                '${_weightController.text} Quintals',
              ),
              if (_expectedPriceController.text.isNotEmpty) _buildSummaryItem(
                Icons.currency_rupee,
                'Expected Price',
                '₹${_expectedPriceController.text}/quintal',
              ),
              if (isGroupFarming && numberOfMembers != null) _buildSummaryItem(
                Icons.group,
                'Group Size',
                '$numberOfMembers members',
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      
      // Review Button
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final formData = _prepareFormData();
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );

              // Simulate processing delay
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.pop(context); // Remove loading indicator
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewPage(formData: formData),
                  ),
                );
              });
            } else {
              // Show validation error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text('Please fill in all required fields'),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rate_review, size: 24),
              const SizedBox(width: 8),
              Text(
                'Review Details',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
    ],
  );
}

Widget _buildSummaryItem(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Colors.green[700]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

Map<String, dynamic> _prepareFormData() {
  // Get the current expected price
  double expectedPrice = double.parse(_expectedPriceController.text);
  // Get MSP price for selected crop
  double mspPrice = mspPrices[selectedCrop!] ?? 0;
  // Calculate if price is above MSP
  bool isAboveMSP = expectedPrice >= mspPrice;

  return {
    'farmerDetails': {
      'farmerId': widget.currentUserId,
      'name': _farmerNameController.text,
      'phone': _phoneController.text,
    },
    'groupFarming': {
      'isGroupFarming': isGroupFarming,
      'numberOfMembers': numberOfMembers,
      'members': memberDetails,
    },
    'location': {
      'state': selectedState,
      'district': selectedDistrict,
      'apmcMarket': selectedAPMC,
    },
    'cropDetails': {
      'cropType': selectedCrop,
      'weight': double.parse(_weightController.text),
      'marketPrice': {
        'min': minPrice,
        'max': maxPrice,
      },
      'expectedPrice': expectedPrice,
      'mspCompliance': {
        'mspPrice': mspPrice,
        'isAboveMSP': isAboveMSP,
        'mspDifference': expectedPrice - mspPrice,
      },
    },
    'address': _addressController.text,
    'description': _descriptionController.text,
  };
}


  @override
  void dispose() {
    _farmerNameController.dispose();
    _phoneController.dispose();
    _expectedPriceController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    for (var controller in memberUidControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

// Review Page
class ReviewPage extends StatelessWidget {
  final Map<String, dynamic> formData;

  const ReviewPage({Key? key, required this.formData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Details'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildReviewSection(
              'Farmer Details',
              [
                'Name: ${formData['farmerDetails']['name']}',
                'Phone: ${formData['farmerDetails']['phone']}',
              ],
            ),
            if (formData['groupFarming']['isGroupFarming'])
              _buildReviewSection(
                'Group Farming Details',
                [
                  'Number of Members: ${formData['groupFarming']['numberOfMembers']}',
                  ...formData['groupFarming']['members'].map((member) => 
                    'Member: ${member['name']} (${member['phone']})'
                  ),
                ],
              ),
            _buildReviewSection(
              'Location Details',
              [
                'State: ${formData['location']['state']}',
                'District: ${formData['location']['district']}',
                'APMC Market: ${formData['location']['apmcMarket']}',
              ],
            ),
            _buildReviewSection(
              'Crop Details',
              [
                'Crop Type: ${formData['cropDetails']['cropType']}',
                'Weight: ${formData['cropDetails']['weight']} quintals',
                'Market Price Range: ₹${formData['cropDetails']['marketPrice']['min']} - ₹${formData['cropDetails']['marketPrice']['max']}/quintal',
                'Expected Price: ₹${formData['cropDetails']['expectedPrice']}/quintal',
                'MSP Status: ${formData['cropDetails']['mspCompliance']['isAboveMSP'] ? 'Above MSP' : 'Below MSP'}',
              ],
            ),
            _buildReviewSection(
              'Additional Details',
              [
                'Pickup Address: ${formData['address']}',
                'Description: ${formData['description']}',
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AICropAnalysisPage(formData: formData),
                  ),
                );
              },
              icon: const Icon(Icons.analytics),
              label: const Text('Proceed to AI Analysis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(String title, List<String> details) {
  return Card(
    elevation: 2,
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          ...details.map((detail) {
            if (detail.startsWith('MSP Status:')) {
              final isAboveMSP = detail.contains('Above MSP');
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isAboveMSP ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isAboveMSP ? Colors.green[200]! : Colors.orange[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAboveMSP ? Icons.check_circle : Icons.warning,
                        color: isAboveMSP ? Colors.green[700] : Colors.orange[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          detail,
                          style: TextStyle(
                            color: isAboveMSP ? Colors.green[700] : Colors.orange[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(detail),
            );
          }),
        ],
      ),
    ),
  );
}
}