import 'package:flutter/material.dart';

enum Language { English, Kannada, Hindi }

class CropAssistanceScreen extends StatefulWidget {
  @override
  _CropAssistanceScreenState createState() => _CropAssistanceScreenState();
}

class _CropAssistanceScreenState extends State<CropAssistanceScreen> {
  Language _selectedLanguage = Language.English;

  // Define translations for the texts
  final Map<Language, Map<String, String>> _localizedStrings = {
    Language.English: {
      'title1': 'Advanced Crop Disease Detection',
      'subtitle1': 'Identify diseases in crops using AI.',
      'title2': 'Crop and Seed Varieties',
      'subtitle2': 'Explore different crop and seed varieties.',
      'title3': 'Farming Advance Map Visualization',
      'subtitle3': 'Visualize your farm with advanced mapping.',
      'title4': 'Advanced Crop Scheduling',
      'subtitle4': 'Optimize your crop planting and harvesting schedule.',
      'languageLabel': 'Select Language',
    },
    Language.Kannada: {
      'title1': 'ಅತ್ಯಾಧುನಿಕ ಬೆಳೆ ರೋಗ ಪತ್ತೆ',
      'subtitle1': 'ಎಐ ಬಳಸಿಕೊಂಡು ಬೆಳೆಗಳಲ್ಲಿ ರೋಗಗಳನ್ನು ಗುರುತಿಸಿ.',
      'title2': 'ಬೆಳೆ ಮತ್ತು ಬೀಜ ವೈವಿಧ್ಯಗಳು',
      'subtitle2': 'ವಿವಿಧ ಬೆಳೆ ಮತ್ತು ಬೀಜ ವೈವಿಧ್ಯಗಳನ್ನು ಅನ್ವೇಷಿಸಿ.',
      'title3': 'ಬೆಳೆ ಮುಂದುವರಿಯುವ ನಕ್ಷೆ ದೃಶ್ಯೀಕರಣ',
      'subtitle3': 'ಆಧುನಿಕ ನಕ್ಷೆಗಳನ್ನು ಬಳಸಿಕೊಂಡು ನಿಮ್ಮ ಮಣ್ಣನ್ನು ದೃಶ್ಯೀಕರಿಸಿ.',
      'title4': 'ಅತ್ಯಾಧುನಿಕ ಬೆಳೆ ಶೆಡ್ಯುಲಿಂಗ್',
      'subtitle4': 'ನಿಮ್ಮ ಬೆಳೆ ನೆಟ್ಟಣ ಮತ್ತು ಕಡಿಯುವ ವೇಳಾಪಟ್ಟಿಯನ್ನು ಸುಧಾರಿಸಿ.',
      'languageLabel': 'ಭಾಷೆಯನ್ನು ಆಯ್ಕೆ ಮಾಡಿ',
    },
    Language.Hindi: {
      'title1': 'उन्नत फसल रोग पहचान',
      'subtitle1': 'कृषि में एआई का उपयोग करके रोगों की पहचान करें।',
      'title2': 'फसल और बीज किस्में',
      'subtitle2': 'विभिन्न फसल और बीज किस्मों का अन्वेषण करें।',
      'title3': 'खेती के उन्नत मानचित्र दृश्य',
      'subtitle3': 'उन्नत मानचित्रण के साथ अपने खेत का दृश्य बनाएं।',
      'title4': 'उन्नत फसल अनुसूची',
      'subtitle4': 'अपनी फसल की बुवाई और कटाई की अनुसूची को अनुकूलित करें।',
      'languageLabel': 'भाषा चुनें',
    },
  };

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Assistance'),
        backgroundColor: Color(0xFF66BB6A),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              // Language Selection Dropdown
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
                hint: Text('Select Language'),
              ),
              SizedBox(height: 24),
              _buildLargeFeatureBox(
                context,
                _localizedStrings[_selectedLanguage]!['title1']!,
                _localizedStrings[_selectedLanguage]!['subtitle1']!,
                Icons.local_florist,
                '/disease-detection',
                Color(0xFF66BB6A),
                boxWidth,
              ),
              _buildLargeFeatureBox(
                context,
                _localizedStrings[_selectedLanguage]!['title2']!,
                _localizedStrings[_selectedLanguage]!['subtitle2']!,
                Icons.grass,
                '/seed-varieties',
                Color(0xFF43A047),
                boxWidth,
              ),
              _buildLargeFeatureBox(
                context,
                _localizedStrings[_selectedLanguage]!['title4']!,
                _localizedStrings[_selectedLanguage]!['subtitle4']!,
                Icons.schedule,
                '/crop-scheduling',
                Color(0xFF1B5E20),
                boxWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeFeatureBox(BuildContext context, String title, String subtitle,
      IconData icon, String route, Color color, double width) {
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