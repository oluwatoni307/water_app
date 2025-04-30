import 'package:flutter/material.dart';
import 'package:water/goals/widgets/numberpad.dart';
import 'package:water/goals/widgets/templateCont.dart';
import 'package:water/logic.dart';
import 'package:provider/provider.dart'; // Add this import for context.read

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  late TextEditingController _controller;
  String inputAmount = "";

  @override
  void initState() {
    super.initState();
    final goal = context.read<Data>().user.goal;
    inputAmount = goal.toString();
    _controller = TextEditingController(text: inputAmount);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void saveGoal() {
    if (inputAmount.isNotEmpty) {
      final parsedAmount = double.tryParse(inputAmount);
      if (parsedAmount != null && parsedAmount > 0) {
        context.read<Data>().setGoals(inputAmount);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              duration: Duration(seconds: 1), // Shorten the duration
              behavior: SnackBarBehavior.floating, // Makes it floating
              content: Text('Goal saved successfully!'),
              backgroundColor: Colors.blueGrey),
        );
        Navigator.pushNamed(context, '/metric'); // Navigate to GoalPage
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
    });
  }

  void onDeletePressed() {
    setState(() {
      if (inputAmount.isNotEmpty) {
        inputAmount = inputAmount.substring(0, inputAmount.length - 1);
        _controller.text = inputAmount;
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
            title: const Text(
              'Goal Page',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 48,
                      ),
                    ),
                    readOnly:
                        true, // Prevent manual typing, use number pad or templates
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
              child: const Text('Choose Goal  from Template'),
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
