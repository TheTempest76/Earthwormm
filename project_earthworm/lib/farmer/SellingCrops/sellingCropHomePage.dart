import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_earthworm/farmer/SellingCrops/IntailCropdetails.dart';
import 'former_auction_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_earthworm/rise.dart';
// Color scheme constants for better organization
class AppColors {
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color darkBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFFBBDEFB);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color deepBlue = Color(0xFF0D47A1);
}

enum Language { English, Kannada, Hindi }

class SellingCropHomePage extends StatefulWidget {
  @override
  _SellingCropHomePageState createState() => _SellingCropHomePageState();
}

class _SellingCropHomePageState extends State<SellingCropHomePage> {
  int _selectedIndex = 0;
  Language _selectedLanguage = Language.English;

  final Map<Language, Map<String, String>> _localizedStrings = {
    Language.English: {
      'welcome_message':
          'Now just a few clicks from selling your precious crop at the right price!',
      'order_status': 'Order Status',
      'bidding_results': 'Bidding Results',
      'order_history': 'Order History',
      'languageLabel': 'Select Language',
      'logout': 'Logout',
      'home': 'Home',
      'sell_your_crops': 'Sell Your Crops',
      'crop_assistance': 'Crop Assistance',
      'sell_your_crop_directly': 'Sell Your Crop Directly to Business',
      'join_marketplace':
          'Join the marketplace for wholesale buying and selling.',
      'build_your_brand': 'Build your brand and sell directly to consumers.',
    },
    Language.Kannada: {
      'welcome_message':
          'ಈಗ ನಿಮಗೆ ಸರಿಯಾದ ಬೆಲೆಗೆ ನಿಮ್ಮ ಅಮೂಲ್ಯ ಬೆಳೆಗಳನ್ನು ಮಾರಾಟ ಮಾಡಲು ಕೆಲವು ಕ್ಲಿಕ್ ಮಾತ್ರ ಉಳಿಯುತ್ತವೆ!',
      'order_status': 'ಆರ್ಡರ್ ಸ್ಥಿತಿ',
      'bidding_results': 'ಬಿಡ್ಡಿಂಗ್ ಫಲಿತಾಂಶಗಳು',
      'order_history': 'ಆರ್ಡರ್ ಇತಿಹಾಸ',
      'languageLabel': 'ಭಾಷೆಯನ್ನು ಆಯ್ಕೆ ಮಾಡಿ',
      'logout': 'ಬೇರು',
      'home': 'ಮನೆ',
      'sell_your_crops': 'ನಿಮ್ಮ ಬೆಳೆಗಳನ್ನು ಮಾರಾಟ ಮಾಡಿ',
      'crop_assistance': 'ಬೆಳೆ ಸಹಾಯ',
      'sell_your_crop_directly':
          'ನಿಮ್ಮ ಬೆಳೆಯನ್ನು ನೇರವಾಗಿ ವ್ಯಾಪಾರಕ್ಕೆ ಮಾರಾಟ ಮಾಡಿ',
      'join_marketplace':
          'ಸಗಟು ಖರೀದಿ ಮತ್ತು ಮಾರಾಟಕ್ಕಾಗಿ ಮಾರುಕಟ್ಟೆಗೆ ಸೇರಿಕೊಳ್ಳಿ.',
      'build_your_brand':
          'ನಿಮ್ಮ ಬ್ರಾಂಡ್ ಅನ್ನು ನಿರ್ಮಿಸಿ ನೇರವಾಗಿ ಗ್ರಾಹಕರಿಗೆ ಮಾರಾಟ ಮಾಡಿ.',
    },
    Language.Hindi: {
      'welcome_message':
          'अब बस कुछ क्लिक दूर हैं अपनी कीमती फसल को सही कीमत पर बेचने के लिए!',
      'order_status': 'ऑर्डर स्थिति',
      'bidding_results': 'बिडिंग परिणाम',
      'order_history': 'ऑर्डर इतिहास',
      'languageLabel': 'भाषा चुनें',
      'logout': 'लॉग आउट',
      'home': 'होम',
      'sell_your_crops': 'अपनी फसलें बेचे',
      'crop_assistance': 'फसल सहायता',
      'sell_your_crop_directly': 'अपनी फसल को सीधे व्यवसाय को बेचें',
      'join_marketplace': 'सीधे खरीदने और बेचने के लिए बाजार में शामिल हों।',
      'build_your_brand': 'अपना ब्रांड बनाएं और सीधे उपभोक्ताओं को बेचें।',
    },
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/signin');
    } catch (e) {
      print('Logout failed: $e');
    }
  }

  Future<String> _getLocationText(Map<String, dynamic> auction) async {
    try {
      // Check if there's a current bid with buyer info
      if (auction['currentBid'] != null && auction['currentBidder'] != null) {
        // Get the buyer ID from the currentBidder map
        final currentBidder = auction['currentBidder'] as Map<String, dynamic>;
        final buyerId = currentBidder['id'];

        if (buyerId != null) {
          // Fetch buyer's data
          final buyerDoc = await FirebaseFirestore.instance
              .collection('buyers')
              .doc(buyerId)
              .get();

          if (buyerDoc.exists) {
            final buyerData = buyerDoc.data() as Map<String, dynamic>?;
            if (buyerData != null) {
              // Construct location string from buyer's address
              final List<String> locationParts = [];
              if (buyerData['district'] != null) {
                locationParts.add(buyerData['district']);
              }
              if (buyerData['state'] != null) {
                locationParts.add(buyerData['state']);
              }

              return locationParts.isNotEmpty
                  ? locationParts.join(', ')
                  : 'Location not specified';
            }
          }
        }
      }

      // Fallback to auction location if no buyer info
      if (auction['location'] != null) {
        if (auction['location'] is String) {
          return auction['location'];
        } else if (auction['location'] is Map) {
          final locationMap = auction['location'] as Map<String, dynamic>;
          return locationMap['address'] ?? 'Location not specified';
        }
      }

      return 'Location not specified';
    } catch (e) {
      print('Error fetching location: $e');
      return 'Location not specified';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeScreen(localizedStrings: _localizedStrings[_selectedLanguage]!),
      Container(),
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('auctions')
            .where('farmerDetails.id',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .where('status', whereIn: ['active', 'completed'])
            .orderBy('startTime', descending: true)
            .orderBy(FieldPath.documentId, descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading auctions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.green.shade600,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading your auctions...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.inbox_rounded,
                        size: 72,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Active Auctions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start a new auction to sell your crops',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/farmer/create-auction');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create New Auction'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final auction =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final endTime = (auction['endTime'] as Timestamp).toDate();
              final isTimeExpired = DateTime.now().isAfter(endTime);

              // Update auction status if time has expired
              if (isTimeExpired && auction['status'] == 'active') {
                FirebaseFirestore.instance
                    .collection('auctions')
                    .doc(snapshot.data!.docs[index].id)
                    .update({'status': 'completed'});
              }

              final isActive = !isTimeExpired && auction['status'] == 'active';

              return FutureBuilder<String>(
                future: _getLocationText(auction),
                builder: (context, locationSnapshot) {
                  final locationText =
                      locationSnapshot.data ?? 'Location not specified';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FarmerAuctionStatusPage(
                              auctionId: snapshot.data!.docs[index].id,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        auction['cropDetails']['type']
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${auction['cropDetails']['quantity']} quintals',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isActive
                                            ? Icons.timer
                                            : Icons.check_circle,
                                        size: 16,
                                        color: isActive
                                            ? Colors.green.shade700
                                            : Colors.orange.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isActive ? 'Active' : 'Completed',
                                        style: TextStyle(
                                          color: isActive
                                              ? Colors.green.shade700
                                              : Colors.orange.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.monetization_on,
                                      size: 20,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '₹${auction['currentBid'] ?? auction['cropDetails']['basePrice']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 20,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          locationText,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue, // Blue
        title: Text(
          _localizedStrings[_selectedLanguage]!['welcome_message']!,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          _buildLanguageDropdown(),
          SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: _localizedStrings[_selectedLanguage]!['logout']!,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primaryBlue, // Blue
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: _localizedStrings[_selectedLanguage]!['home']!,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in, color: Colors.white),
            label: _localizedStrings[_selectedLanguage]!['order_status']!,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gavel, color: Colors.white),
            label: _localizedStrings[_selectedLanguage]!['bidding_results']!,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, color: Colors.white),
            label: _localizedStrings[_selectedLanguage]!['order_history']!,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: AppColors.primaryBlue,
      ),
      child: DropdownButton<Language>(
        value: _selectedLanguage,
        icon: Icon(Icons.language, color: Colors.white),
        underline: Container(),
        style: TextStyle(color: Colors.white),
        onChanged: (Language? newValue) {
          setState(() {
            _selectedLanguage = newValue!;
          });
        },
        items: Language.values.map((Language language) {
          return DropdownMenuItem<Language>(
            value: language,
            child: Text(
              language.toString().split('.').last,
              style: TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Map<String, String> localizedStrings;

  const HomeScreen({required this.localizedStrings});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color.fromARGB(255, 2, 104, 194); // Blue
    final Color secondaryColor = AppColors.deepBlue; // Darker Blue
    final Color backgroundColor = AppColors.lightBlue; // Light Blue
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.9;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              // Welcome Header
              Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  localizedStrings['welcome_message']!,
                  style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                  ),
                ),
                ],
              ),
              ),
              SizedBox(height: 32),

              // Feature Boxes
              _buildLargeFeatureBox(
              context,
              localizedStrings['sell_your_crop_directly']!,
              localizedStrings['join_marketplace']!,
              Icons.business,
              '/sell-business',
              primaryColor,
              boxWidth,
              ),
              _buildLargeFeatureBox(
              context,
              'AgriLoop',
              localizedStrings['join_marketplace']!,
              Icons.shopping_cart,
              '/agriloop',
              const Color.fromARGB(255, 6, 77, 158),
              boxWidth,
              ),
              _buildLargeFeatureBox(
              context,
              'Earthworm Rise Program',
              localizedStrings['build_your_brand']!,
              Icons.branding_watermark,
              '/earthworm-rise',
              const Color.fromARGB(255, 5, 85, 151),
              boxWidth,
              ),
             
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeFeatureBox(BuildContext context, String title,
      String subtitle, IconData icon, String route, Color color, double width) {
    return Container(
      width: width,
      margin: EdgeInsets.only(bottom: 24),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final currentUserId =
    FirebaseAuth.instance.currentUser?.uid ?? ''; // Get the current user's UID

// Route generator for additional screens
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/sell-business':
        return MaterialPageRoute(
            builder: (_) => CropDetailsForm(currentUserId: currentUserId));
      case '/agriloop':
        return MaterialPageRoute(builder: (_) => AgriLoopScreen());
      case '/earthworm-rise':
        return MaterialPageRoute(builder: (_) => EarthwormRiseScreen());
      

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}

// Placeholder screens for functionality
class SellBusinessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sell Your Crop Directly to Business'),
        backgroundColor: AppColors.darkBlue,
      ),
      body: Center(child: Text('Sell Business Content')),
    );
  }
}

class AgriLoopScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AgriLoop'),
        backgroundColor: AppColors.darkBlue,
      ),
      body: Center(child: Text('AgriLoop Content')),
    );
  }
}

class EarthwormRiseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Earthworm Rise Program'),
        backgroundColor: AppColors.darkBlue,
      ),
      body: Center(child: Text('Earthworm Rise Program Content')),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Farmer Dashboard',
    theme: ThemeData(primarySwatch: Colors.blue),
    initialRoute: '/',
    routes: {
      '/': (context) => SellingCropHomePage(),
      // Add other routes here if needed
    },
    onGenerateRoute: RouteGenerator.generateRoute,
  ));
}
