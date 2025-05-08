import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_earthworm/farmer/CropAssistanceScreen.dart';
import 'package:project_earthworm/farmer/calculator/calculator_home.dart';
import 'package:project_earthworm/farmer/farmerdashboard.dart';
import 'insurance_signup.dart';
import "package:project_earthworm/buyer/chatboat.dart";

enum Language { English, Kannada, Hindi }

class FarmerHome extends StatefulWidget {
  static Language selectedLanguage = Language.English; // Default value

  @override
  _FarmerHomeState createState() => _FarmerHomeState();
}

class _FarmerHomeState extends State<FarmerHome> {
  int _selectedIndex = 0;
  Language _selectedLanguage = Language.English;

  // Define translations for the texts
  final Map<Language, Map<String, String>> _localizedStrings = {
    Language.English: {
      'welcome_back': 'Welcome Back!',
      'farming_journey': 'Your farming journey continues here!',
      'farmer_dashboard': 'Farmer Dashboard',
      'sell_your_crops': 'Sell Your Crops',
      'crop_assistance': 'Crop Assistance',
      'track_activities': 'Track and manage your farm activities',
      'manage_sales': 'List and manage your crop sales',
      'get_advice': 'Get expert advice and crop management tips',
      'languageLabel': 'Select Language',
      'logout': 'Logout',
      'learn': 'Learn Farming Practices',
      'gain_knowledge': 'Learn and gain more knowledge about farming practices',
    },
    Language.Kannada: {
      'welcome_back': 'ಮರುಬಳಕೆದಾರರಾಗಿ ಸ್ವಾಗತ!',
      'farming_journey': 'ನಿಮ್ಮ ಕೃಷಿ ಪಯಣವು ಇಲ್ಲಿ ಮುಂದುವರಿಯುತ್ತದೆ!',
      'farmer_dashboard': 'ಕೃಷಕಿ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್',
      'sell_your_crops': 'ನಿಮ್ಮ ಬೆಳೆಗಳನ್ನು ಮಾರಾಟ ಮಾಡಿ',
      'crop_assistance': 'ಬೆಳೆ ಸಹಾಯ',
      'track_activities': 'ನಿಮ್ಮ ಕೃಷಿ ಚಟುವಟಿಕೆಗಳನ್ನು ಟ್ರ್ಯಾಕ್ ಮತ್ತು ನಿರ್ವಹಿಸಿ',
      'manage_sales': 'ನಿಮ್ಮ ಬೆಳೆ ಮಾರಾಟಗಳನ್ನು ಪಟ್ಟಿಮಾಡಿ ಮತ್ತು ನಿರ್ವಹಿಸಿ',
      'get_advice': 'ತಜ್ಞರ ಸಲಹೆ ಮತ್ತು ಬೆಳೆ ನಿರ್ವಹಣೆಯ ಟಿಪ್ಪಣಿಗಳನ್ನು ಪಡೆಯಿರಿ',
      'languageLabel': 'ಭಾಷೆಯನ್ನು ಆಯ್ಕೆ ಮಾಡಿ',
      'logout': 'ಬೇರು',
      'learn': 'ಕೃಷಿ ಪದ್ಧತಿಗಳ ಬಗ್ಗೆ ತಿಳಿಯಿರಿ',
      'gain_knowledge':
          'ಕೃಷಿ ಪದ್ಧತಿಗಳ ಬಗ್ಗೆ ಹೆಚ್ಚಿನ ಜ್ಞಾನವನ್ನು ಕಲಿಯಿರಿ ಮತ್ತು ಪಡೆದುಕೊಳ್ಳಿ',
    },
    Language.Hindi: {
      'welcome_back': 'फिर से स्वागत है!',
      'farming_journey': 'आपकी खेती की यात्रा यहां जारी है!',
      'farmer_dashboard': 'किसान डैशबोर्ड',
      'sell_your_crops': 'अपनी फसलें बेचे',
      'crop_assistance': 'फसल सहायता',
      'track_activities': 'अपने खेत की गतिविधियों को ट्रैक और प्रबंधित करें',
      'manage_sales': 'अपनी फसल बिक्री की सूची बनाएं और प्रबंधित करें',
      'get_advice': 'विशेषज्ञ सलाह और फसल प्रबंधन टिप्स प्राप्त करें',
      'languageLabel': 'भाषा चुनें',
      'logout': 'लॉग आउट',
      'learn': 'कृषि पद्धतियों के बारे में जानें',
      'gain_knowledge':
          'कृषि पद्धतियों के बारे में जानें और अधिक जानकारी प्राप्त करें',
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
      // Navigate to the login screen or home screen after logout
      // You can replace the following line with your desired navigation
      Navigator.of(context).pushReplacementNamed('/signin');
    } catch (e) {
      // Handle errors as needed
      print('Logout failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeScreen(localizedStrings: _localizedStrings[_selectedLanguage]!),
      CalculatorHomeScreen(),
      const ChatbotWebView(
          chatbotUrl: "https://effulgent-semifreddo-39d899.netlify.app/"),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          DropdownButton<Language>(
            value: _selectedLanguage,
            items: Language.values.map((Language language) {
              return DropdownMenuItem<Language>(
                value: language,
                child: Text(language == Language.English
                    ? 'English'
                    : language == Language.Kannada
                        ? 'ಕನ್ನಡ'
                        : 'हिन्दी'),
              );
            }).toList(),
            onChanged: (Language? newValue) {
              setState(() {
                _selectedLanguage = newValue!;
              });
            },
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child:
                  Text(_localizedStrings[_selectedLanguage]!['languageLabel']!),
            ),
          ),
          SizedBox(width: 16), // Add some spacing
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: _localizedStrings[_selectedLanguage]!['logout']!,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF1B5E20), // Dark green
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: _localizedStrings[_selectedLanguage]!['farmer_dashboard']!,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Farming Calculators',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat bot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Map<String, String> localizedStrings;

  const HomeScreen({required this.localizedStrings});

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Color(0xFF66BB6A); // Vibrant green
    final Color secondaryGreen = Color(0xFF1B5E20); // Dark green
    final Color backgroundColor = Color(0xFFF1F8E9); // Light green background
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.9; // 90% of screen width

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              // Welcome Header with enhanced styling
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
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
                      localizedStrings['welcome_back']!,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: secondaryGreen,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      localizedStrings['farming_journey']!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Feature Boxes with enhanced styling
              _buildLargeFeatureBox(
                context,
                localizedStrings['farmer_dashboard']!,
                localizedStrings['track_activities']!,
                Icons.dashboard,
                '/dashboard',
                Color(0xFF66BB6A), // Vibrant green
                boxWidth,
              ),

              _buildLargeFeatureBox(
                context,
                localizedStrings['sell_your_crops']!,
                localizedStrings['manage_sales']!,
                Icons.store,
                '/sell-crops',
                Color(0xFF43A047), // Slightly darker green
                boxWidth,
              ),

              _buildLargeFeatureBox(
                context,
                localizedStrings['crop_assistance']!,
                localizedStrings['get_advice']!,
                Icons.eco,
                '/crop-assistance',
                Color(0xFF2E7D32), // Darkest green
                boxWidth,
              ),
              _buildLargeFeatureBox(
                context,
                localizedStrings['learn']!,
                localizedStrings['gain_knowledge']!,
                Icons.eco,
                '/learn-home',
                Color.fromARGB(255, 1, 96, 6), // Darkest green
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

// Route generator and other screens remain the same as previous implementation
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => OnboardingScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => FarmerDashboardScreen());
      case '/sell-crops':
        return MaterialPageRoute(builder: (_) => SellCropsScreen());
      case '/crop-assistance':
        return MaterialPageRoute(builder: (_) => CropAssistanceScreen());
      case '/insurance':
        return MaterialPageRoute(builder: (_) => FarmerInsuranceSignup());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}

// Feature screens with matching theme
class FarmerDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farmer Dashboard'),
        backgroundColor: Color(0xFF66BB6A),
      ),
      body: Center(child: Text('Farmer Dashboard Content')),
    );
  }
}

class SellCropsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sell Your Crops'),
        backgroundColor: Color(0xFF43A047),
      ),
      body: Center(child: Text('Sell Crops Content')),
    );
  }
}
