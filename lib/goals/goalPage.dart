import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:water/goals/widgets/numberpad.dart';
import 'package:water/goals/widgets/templateCont.dart';
import 'package:water/logic.dart';
import 'package:provider/provider.dart'; // Add this import for context.read

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> with TickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _caretController;
  String inputAmount = "";
  bool _showCaret = false;

  @override
  void initState() {
    super.initState();
    final goal = context.read<Data>().user.goal;
    inputAmount = goal.toString();
    _controller = TextEditingController(text: inputAmount);

    // Initialize caret animation controller
    _caretController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    if (!_showCaret) {
      _showCaret = true;
      _caretController.repeat(reverse: true); // Start blinking animation
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _caretController.dispose();
    super.dispose();
  }

  void saveGoal() {
    if (inputAmount.isNotEmpty) {
      final parsedAmount = double.tryParse(inputAmount);
      if (parsedAmount != null && parsedAmount > 0) {
        context.read<Data>().setGoals(inputAmount);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Awesome! Your hydration goal is saved 💦'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.blueGrey,
          ),
        );

        Navigator.pushReplacementNamed(
            context, '/'); // Navigate to GoalPage and replace current
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

  void onNumberPressed(String number) {
    setState(() {
      inputAmount += number;
      _controller.text = inputAmount; // Sync controller with input

      // Start caret blinking when user first starts typing
      if (!_showCaret) {
        _showCaret = true;
        _caretController.repeat(reverse: true); // Start blinking animation
      }
    });
  }

  void onDeletePressed() {
    setState(() {
      if (inputAmount.isNotEmpty) {
        inputAmount = inputAmount.substring(0, inputAmount.length - 1);
        _controller.text = inputAmount;

        // Stop caret if no more input
        if (inputAmount.isEmpty) {
          _showCaret = false;
          _caretController.stop();
        }
      }
    });
  }

  // Function to show the TemplateGoalContainer as a bottom sheet
  void _showTemplateBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return TemplateGoalContainer(
          onGoalSelected: (String value) {
            setState(() {
              inputAmount = value; // Update inputAmount with selected goal
              _controller.text = inputAmount;

              // Start caret blinking when template is selected
              if (!_showCaret && inputAmount.isNotEmpty) {
                _showCaret = true;
                _caretController.repeat(reverse: true);
              }
            });
            Navigator.pop(context); // Close the bottom sheet
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF369FFF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 20, 0, 0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF369FFF)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            title: Text(
              'Set Your Daily Hydration Goal 💧',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16, // Optimal for AppBar
                fontWeight:
                    FontWeight.w600, // Semi-bold: professional yet friendly
                // letterSpacing: 0.5,
                // height: 1.3, // Adjust line height if wrapped
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: AnimatedBuilder(
                    animation: _caretController,
                    builder: (context, child) {
                      return RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: inputAmount.isEmpty
                                  ? 'Enter your goal (ml)'
                                  : inputAmount,
                              style: TextStyle(
                                fontSize: inputAmount.isEmpty ? 24 : 48,
                                fontWeight: FontWeight.bold,
                                color: inputAmount.isEmpty
                                    ? Colors.grey
                                    : Colors.white,
                              ),
                            ),
                            if (_showCaret)
                              TextSpan(
                                text: '|',
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                      .withOpacity(_caretController.value),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _showTemplateBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF369FFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Choose a Goal Template'),
            ),
          ),
          CustomNumberPad(
            onNumberTap: onNumberPressed,
            onDelete: onDeletePressed,
            finished: saveGoal,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
