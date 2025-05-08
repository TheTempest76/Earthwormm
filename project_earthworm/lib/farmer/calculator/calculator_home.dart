import 'package:flutter/material.dart';
import 'calculator_screen/crop_yield.dart';
import 'calculator_screen/input_cost.dart';
import 'calculator_screen/irrigation.dart';
import 'calculator_screen/profit-loss.dart';
import 'calculator_screen/soil-fertile.dart';
import 'calculator_screen/pest.dart';
import 'calculator_screen/market.dart';
import 'calculator_screen/loan.dart';
import 'calculator_screen/planting.dart';
import 'calculator_screen/livestock.dart';

class CalculatorHomeScreen extends StatelessWidget {
  final List<CalculatorInfo> calculators = [
    CalculatorInfo(
      title: 'Crop Yield',
      description: 'Estimate crop production',
      screen: CropYieldScreen(),
      icon: Icons.agriculture,
    ),
    CalculatorInfo(
      title: 'Input Cost',
      description: 'Manage input expenses',
      screen: InputCostManagementScreen(),
      icon: Icons.attach_money,
    ),
    CalculatorInfo(
      title: 'Irrigation',
      description: 'Water management',
      screen: IrrigationRequirementsScreen(),
      icon: Icons.water_drop,
    ),
    CalculatorInfo(
      title: 'Profit Analysis',
      description: 'Financial performance',
      screen: ProfitLossCalculatorScreen(),
      icon: Icons.analytics,
    ),
    CalculatorInfo(
      title: 'Soil Fertility',
      description: 'Soil nutrient analysis',
      screen: SoilFertilityScreen(),
      icon: Icons.grass,
    ),
    CalculatorInfo(
      title: 'Pest Management',
      description: 'Pest control strategy',
      screen: PestDiseaseManagementScreen(),
      icon: Icons.bug_report,
    ),
    CalculatorInfo(
      title: 'Market Price',
      description: 'Price trend analysis',
      screen: MarketPriceScreen(),
      icon: Icons.trending_up,
    ),
    CalculatorInfo(
      title: 'Loan Calculator',
      description: 'Financial planning',
      screen: LoanSubsidyCalculatorScreen(),
      icon: Icons.account_balance,
    ),
    CalculatorInfo(
      title: 'Planting Schedule',
      description: 'Crop timeline planning',
      screen: PlantingHarvestingScheduleScreen(),
      icon: Icons.calendar_month,
    ),
    CalculatorInfo(
      title: 'Livestock Feed',
      description: 'Animal nutrition',
      screen: LivestockFeedCalculatorScreen(),
      icon: Icons.pets,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Smart Farming Calculators'),
        backgroundColor: Color.fromARGB(255, 46, 152, 53),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B5E20).withOpacity(0.1),
              Colors.white,
              Color(0xFF66BB6A).withOpacity(0.1),
            ],
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: calculators.length,
          itemBuilder: (context, index) {
            return _buildCalculatorCard(context, calculators[index]);
          },
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(BuildContext context, CalculatorInfo info) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => info.screen,
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF1B5E20).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  info.icon,
                  color: Color(0xFF1B5E20),
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      info.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF1B5E20),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalculatorInfo {
  final String title;
  final String description;
  final Widget screen;
  final IconData icon;

  CalculatorInfo({
    required this.title,
    required this.description,
    required this.screen,
    required this.icon,
  });
}
