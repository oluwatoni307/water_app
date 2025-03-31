import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const AddButton({
    Key? key,
    required this.text,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.blue,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: 25,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
