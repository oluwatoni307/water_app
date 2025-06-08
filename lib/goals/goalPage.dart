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
            backgroundColor: Color(0xFF369FFF),
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
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Color(0xFF369FFF), // Secondary color
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8.0), // Add margin for better spacing
            decoration: const BoxDecoration(
              color: Color(0xFFF4F8FB),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF369FFF)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                'Set Your Goal',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Start your journey to better hydration',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
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
                              style: GoogleFonts.poppins(
                                // Use consistent font
                                fontSize: inputAmount.isEmpty ? 24 : 48,
                                fontWeight: FontWeight.bold,
                                color: inputAmount.isEmpty
                                    ? Colors.grey[500]
                                    : Color(0xFF369FFF), // Secondary color
                              ),
                            ),
                            if (_showCaret)
                              TextSpan(
                                text: '|',
                                style: GoogleFonts.poppins(
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF369FFF)
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
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0), // Increased padding
            child: SizedBox(
              width: double.infinity, // Full width button
              height: 50, // Consistent height
              child: ElevatedButton(
                onPressed: _showTemplateBottomSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 2, // Add subtle shadow
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12), // Slightly more rounded
                    side: const BorderSide(
                      color: Color(0xFF369FFF),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Text(
                  'Choose a Goal Template',
                  style: GoogleFonts.poppins(
                      // Consistent font
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF369FFF)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16), // Consistent spacing
          CustomNumberPad(
            onNumberTap: onNumberPressed,
            onDelete: onDeletePressed,
            finished: saveGoal,
          ),
          const SizedBox(height: 24), // Slightly more bottom padding
        ],
      ),
    );
  }
}
