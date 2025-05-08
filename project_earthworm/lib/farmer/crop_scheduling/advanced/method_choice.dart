import 'package:flutter/material.dart';
import 'crop_questionnaire.dart';

class FarmingMethodsScreen extends StatelessWidget {
  const FarmingMethodsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Global Farming Innovations',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Advanced International Farming Methods',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Proven techniques from around the world',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              _buildMethodCard(
                context: context,
                title: 'Israeli Drip Irrigation',
                description:
                    'Advanced precision irrigation system developed in Israel, perfect for water-scarce regions. Delivers water and nutrients directly to plant roots.',
                features: [
                  'Saves up to 70% water compared to flood irrigation',
                  'Automated fertigation system integration',
                  'Pressure-compensated dripper technology',
                  'Suitable for various crop types and terrains',
                ],
                color: const Color(0xFF66BB6A),
                icon: Icons.water_drop,
              ),
              const SizedBox(height: 16),
              _buildMethodCard(
                context: context,
                title: 'Russian Intensive Strip Farming',
                description:
                    'Efficient strip cultivation method that maximizes space utilization and soil health through careful crop rotation.',
                features: [
                  'Reduces soil erosion significantly',
                  'Optimizes nutrient distribution',
                  'Perfect for medium to large farmlands',
                  'Increases yield by 30-40%',
                ],
                color: const Color(0xFF43A047),
                icon: Icons.format_strikethrough,
              ),
              const SizedBox(height: 16),
              _buildMethodCard(
                context: context,
                title: 'Dutch Greenhouse Technology',
                description:
                    'Advanced controlled environment agriculture using minimal resources while maximizing crop yield.',
                features: [
                  'Year-round cultivation possible',
                  'Climate-controlled environment',
                  'Hydroponic/aeroponic integration',
                  'Smart sensors for optimal growth',
                ],
                color: const Color(0xFF2E7D32),
                icon: Icons.house,
              ),
              const SizedBox(height: 16),
              _buildMethodCard(
                context: context,
                title: 'Japanese Permaculture',
                description:
                    'Sustainable farming method that creates agricultural ecosystems working in harmony with nature.',
                features: [
                  'Minimal external input required',
                  'Multi-layer cultivation technique',
                  'Natural pest control methods',
                  'Soil regeneration focus',
                ],
                color: const Color(0xFF1B5E20),
                icon: Icons.eco,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required BuildContext context,
    required String title,
    required String description,
    required List<String> features,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to questionnaire screen when card is tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FarmingMethodQuestionnaireScreen(
                methodName: title,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: color.withOpacity(0.5),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: color,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
