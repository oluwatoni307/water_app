import 'package:flutter/material.dart';
import 'package:water/goals/widgets/metric_buttons.dart';
import 'package:water/goals/widgets/numberpad.dart';
import 'package:water/widgets/addButton.dart';
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
  int selectedCategoryIndex = 0;
  final Map<String, int> categories = {"Coke": 50, "fanta": 50};

  void onCategorySelected(int index) {
    setState(() {
      selectedCategoryIndex = index;
    });
  }

  void onNumberPressed(String number) {
    setState(() {
      inputAmount += number;
    });
  }

  void saveGoal() {
    if (inputAmount.isNotEmpty) {
      final parsedAmount = int.tryParse(inputAmount);
      if (parsedAmount != null && parsedAmount > 0) {
        context.read<Data>().log(parsedAmount);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Goal saved successfully!'),
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
      backgroundColor: Colors.blue,
      body: Column(
        children: [
          Stack(
            children: [
              _buildWaveBackground(),
              Column(
                children: [
                  SizedBox(height: 100),
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
                  AddButton(
                    text: "Add",
                    backgroundColor: Colors.white,
                    textColor: Colors.blue,
                    onPressed: () {},
                  ),
                  SizedBox(height: 20),
                  CustomNumberPad(
                    onNumberTap: onNumberPressed,
                    onDelete: onDeletePressed,
                    finished: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBackground() {
    return SizedBox(
      height: 250,
      child: WaveWidget(
        config: CustomConfig(
          gradients: [
            [Colors.blueAccent, Colors.blue],
            [Colors.lightBlueAccent, Colors.blue],
          ],
          durations: [3500, 1940],
          heightPercentages: [0.3, 0.5],
          blur: MaskFilter.blur(BlurStyle.solid, 5),
        ),
        size: Size(double.infinity, double.infinity),
        waveAmplitude: 0,
      ),
    );
  }

  Widget _buildCategoryButtons() {
    final categoryList = categories.keys.toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(categories.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: MetricButton(
            label: categoryList[index],
            isSelected: index == selectedCategoryIndex,
            onTap: () => onCategorySelected(index),
          ),
        );
      }),
    );
  }
}
