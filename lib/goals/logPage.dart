import 'package:flutter/material.dart';
import 'package:water/goals/widgets/userMetric.dart';
import 'package:water/goals/widgets/numberpad.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';
import 'package:water/logic.dart';
import 'package:provider/provider.dart';

class Log extends StatefulWidget {
  @override
  _LogState createState() => _LogState();
}

class _LogState extends State<Log> {
  String inputAmount = "";
  int selectedCategoryIndex = -1;

  void onCategorySelected(int index, int value) {
    setState(() {
      selectedCategoryIndex = index;
      inputAmount = value.toString();
    });
  }

  void onNumberPressed(String number) {
    setState(() {
      inputAmount += number;
    });
  }

  void logData() {
    if (inputAmount.isNotEmpty) {
      final parsedAmount = int.tryParse(inputAmount);
      if (parsedAmount != null && parsedAmount > 0) {
        context.read<Data>().log(parsedAmount);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(' successfully logged '),
              backgroundColor: Colors.green),
        );
        Navigator.pushNamed(context, '/'); // Navigate to GoalPage
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please enter a valid positive number'),
              backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a goal amount'),
            backgroundColor: Colors.red),
      );
    }
  }

  void onDeletePressed() {
    setState(() {
      if (inputAmount.isNotEmpty) {
        inputAmount = inputAmount.substring(0, inputAmount.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = context.read<Data>().user;

    return Scaffold(
      backgroundColor: Color(0xFFF4F8FB),
      body: Column(
        children: [
          // Top spacing
          SizedBox(height: 30),

          // Wave background at the top
          _buildWaveBackground(),

          // Main content area
          Expanded(
            child: Container(
              color: Color(0x8C2596FF),
              child: Column(
                children: [
                  // Input display area
                  Flexible(
                    flex: 2,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Display the input amount
                          Text(
                            inputAmount.isEmpty ? "0" : inputAmount,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Unit: ml",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Categories strip
                  if (data.metric.isNotEmpty)
                    Flexible(
                      flex: 1,
                      child: _buildCategoryButtons(),
                    ),

                  // Number pad
                  Flexible(
                    flex: 3,
                    child: CustomNumberPad(
                      onNumberTap: onNumberPressed,
                      onDelete: onDeletePressed,
                      finished: logData,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBackground() {
    return SizedBox(
      height: 50,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: WaveWidget(
          config: CustomConfig(
            colors: [
              Color(0x4D2596FF), // ~30% opacity for first wave
              Color(0x4D2596FF), // ~30% opacity for second wave
            ],
            durations: [4000, 3200],
            heightPercentages: [0.20, 0.25],
          ),
          waveAmplitude: 15,
          size: Size(double.infinity, 130),
        ),
      ),
    );
  }

  Widget _buildCategoryButtons() {
    final data = context.read<Data>().user;
    Map categories = data.metric;
    final categoryList = categories.keys.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SizedBox(
        height: categoryList.isNotEmpty ? 80 : 0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final categoryKey = categoryList[index];
            final categoryValue = categories[categoryKey];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: MetricButton(
                label: categoryList[index],
                isSelected: index == selectedCategoryIndex,
                onTap: () => onCategorySelected(index, categoryValue!),
              ),
            );
          },
        ),
      ),
    );
  }
}
