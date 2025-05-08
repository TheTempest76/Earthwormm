import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';

class PriceGraphWidget extends StatefulWidget {
  const PriceGraphWidget({super.key});

  @override
  State<PriceGraphWidget> createState() => _PriceGraphWidgetState();
}

class _PriceGraphWidgetState extends State<PriceGraphWidget> {
  List<FlSpot> _spots = [];
  String _commodity = '';

  @override
  void initState() {
    super.initState();
    _loadCsvData();
  }

  Future<void> _loadCsvData() async {
    final csvString = await rootBundle.loadString('assets/data.csv');
    final List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

    // Find the header and one row of data
    final header = rows[0];
    final dataRow = rows.firstWhere((row) => row[3] == 'Tomato'); // Example: filter for Tomato

    final startIndex = header.indexOf('Day_1');
    final spots = <FlSpot>[];

    for (int i = 0; i < 31; i++) {
      final price = dataRow[startIndex + i];
      if (price is num) {
        spots.add(FlSpot(i + 1, price.toDouble()));
      }
    }

    setState(() {
      _spots = spots;
      _commodity = dataRow[3]; // e.g., Tomato
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Price Trend: $_commodity')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _spots.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          return Text('D${value.toInt()}');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 500,
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _spots,
                      isCurved: true,
                      dotData: FlDotData(show: false),
                      color: Colors.green,
                      barWidth: 2,
                    )
                  ],
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
      ),
    );
  }
}
