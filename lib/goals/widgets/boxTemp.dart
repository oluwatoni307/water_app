import 'package:flutter/material.dart';
import 'package:water/data/template_story.dart';
import 'package:water/history.dart';

class BoxTemp extends StatelessWidget {
  final String title;
  final int value;
  final String? icon;
  final VoidCallback onPressed; // Callback function
  final bool tapped;

  const BoxTemp({
    super.key,
    this.icon,
    required this.title,
    required this.value,
    required this.onPressed,
    required this.tapped,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      onLongPress: () =>
          _handleLongPress(context, title), // ✅ Pass context and title here
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: tapped ? Colors.blue[100] : Colors.white, // Highlight selection
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${value}ml",
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ),
                  if (icon != null)
                    Image.asset(
                      icon!,
                      height: 40,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLongPress(BuildContext context, String name) {
    print(name);
    String content = template[name] ?? 'No content found.';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TitleContentCard(
          title: name,
          content: content,
        ),
      ),
    );
  }
}
