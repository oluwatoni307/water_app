import 'package:flutter/material.dart';

class CustomNumberPad extends StatelessWidget {
  final Function onNumberTap;
  final VoidCallback finished;
  final VoidCallback onDelete;
  final Color color; // Added color parameter

  const CustomNumberPad({
    Key? key,
    required this.onNumberTap,
    required this.onDelete,
    required this.finished,
    this.color = const Color(0xFF369FFF), // Default color if not provided
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        if (index == 10) {
          return IconButton(
            icon: Icon(Icons.backspace, color: color),
            onPressed: onDelete,
          );
        } else if (index == 11) {
          return IconButton(
            icon: Icon(Icons.done, color: color),
            onPressed: finished,
          );
        }
        String number = index == 9 ? "0" : "${index + 1}";
        return GestureDetector(
          onTap: () => onNumberTap(number),
          child: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }
}
