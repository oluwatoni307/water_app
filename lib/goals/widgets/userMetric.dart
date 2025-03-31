import 'package:flutter/material.dart';

class MetricButton extends StatelessWidget {
  final String label;

  final bool isSelected;
  final VoidCallback onTap;

  const MetricButton({
    Key? key,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: 100,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white54, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.blueGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
