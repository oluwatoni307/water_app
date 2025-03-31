import 'package:flutter/material.dart';
import 'package:water/goals/widgets/userMetric.dart';
import 'package:water/goals/widgets/numberpad.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';
import 'package:water/logic.dart';
import 'package:provider/provider.dart'; // Add this import for context.read

class Log extends StatefulWidget {
  @override
  _LogState createState() => _LogState();
}

class _LogState extends State<Log> {
  String inputAmount = "";
  int selectedCategoryIndex = -1;
  // final Map<String, int> categories = {"Coke": 50, "fanta": 50};

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
    return Scaffold(
      backgroundColor: Color(0xFFF4F8FB),
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          _buildWaveBackground(),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Color(0x8C2596FF),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 20),
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
                            SizedBox(height: 20),
                            _buildCategoryButtons(),
                            SizedBox(height: 20),
                            SizedBox(height: 20),
                            CustomNumberPad(
                              onNumberTap: onNumberPressed,
                              onDelete: onDeletePressed,
                              finished: logData,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
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
    final data =
        context.read<Data>().user; // Add this line to access data provider
    Map categories = data.metric;
    final categoryList = categories.keys.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
        height: categoryList.length > 0 ? 80 : 0,
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
