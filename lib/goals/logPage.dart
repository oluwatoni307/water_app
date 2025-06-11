import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    HapticFeedback.lightImpact();
    setState(() {
      if (selectedCategoryIndex == index) {
        // Deselect
        selectedCategoryIndex = -1;
        inputAmount = "";
      } else {
        selectedCategoryIndex = index;
        inputAmount = value.toString();
      }
    });
  }

  void onNumberPressed(String number) {
    HapticFeedback.selectionClick();
    setState(() {
      // If a category was selected, clear it when manual input starts
      if (selectedCategoryIndex != -1) {
        selectedCategoryIndex = -1;
        inputAmount = '';
      }
      inputAmount += number;
    });
  }

  void onDeletePressed() {
    HapticFeedback.selectionClick();
    setState(() {
      if (inputAmount.isNotEmpty) {
        inputAmount = inputAmount.substring(0, inputAmount.length - 1);
      }
    });
  }

  void logData() {
    if (inputAmount.isNotEmpty) {
      final parsedAmount = int.tryParse(inputAmount);
      if (parsedAmount != null && parsedAmount > 0) {
        context.read<Data>().log(parsedAmount);

        final user = context.read<Data>().user;
        final amountDrank =
            user.Day_Log.values.fold(0, (sum, amount) => sum + amount);
        final percentage = user.goal > 0 ? (amountDrank / user.goal) * 100 : 0;

        String title;
        String message;

        if (percentage < 15) {
          title = "Let’s Get Started 💧";
          message = "Every drop counts! You're just getting going.";
        } else if (percentage < 30) {
          title = "Flowing Nicely 🚰";
          message = "Good start! Keep the flow going.";
        } else if (percentage < 45) {
          title = "Solid Progress 👍";
          message = "You're building momentum — stay on track!";
        } else if (percentage < 60) {
          title = "Halfway There! 🧭";
          message = "You’ve crossed the halfway mark. Keep going!";
        } else if (percentage < 75) {
          title = "Hydration Hero 🦸‍♂️";
          message = "You're doing great! Don’t slow down now.";
        } else if (percentage < 90) {
          title = "Almost There! 🏁";
          message = "Just a bit more — you're so close!";
        } else if (percentage < 100) {
          title = "Final Push 💙";
          message = "You're nearly at your goal. Keep sipping!";
        } else {
          title = "Goal Achieved! 🏆";
          message = "You crushed your hydration goal today. Amazing job!";
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/');
                },
                child: const Text("Continue"),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid positive number'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a goal amount'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      body: Column(
        children: [
          const SizedBox(height: 30),
          _buildWaveBackground(),
          Expanded(
            child: Container(
              color: const Color(0x8C2596FF),
              child: Column(
                children: [
                  // Display area
                  Flexible(
                    flex: 2,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            inputAmount.isEmpty ? '0' : inputAmount,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Unit: ml',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Number pad
                  Flexible(
                    flex: 3,
                    child: CustomNumberPad(
                      onNumberTap: onNumberPressed,
                      onDelete: onDeletePressed,
                      finished: logData,
                      color: Colors.white,
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
              const Color(0x4D2596FF),
              const Color(0x4D2596FF),
            ],
            durations: [4000, 3200],
            heightPercentages: [0.20, 0.25],
          ),
          waveAmplitude: 15,
          size: const Size(double.infinity, 130),
        ),
      ),
    );
  }
}
