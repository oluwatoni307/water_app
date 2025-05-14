import 'package:flutter/material.dart';
import 'package:water/model/box_model.dart';
import 'package:water/goals/widgets/boxTemp.dart';
import 'package:water/logic.dart';
import 'package:provider/provider.dart';

class Metricpage extends StatefulWidget {
  @override
  State<Metricpage> createState() => _MetricpageState();
}

class _MetricpageState extends State<Metricpage> {
  List<BoxModel> user_metric = [];

  // Handle tapping on a metric to add/remove it
  void _tappedMetrics(String name, int quantity) {
    setState(() {
      bool exists = user_metric.any((metric) => metric.title == name);
      if (exists) {
        user_metric.removeWhere((metric) => metric.title == name);
      } else {
        user_metric.add(BoxModel(title: name, value: quantity));
      }
    });
  }

  // // Add a new custom metric
  // void _addMetric(String name, int quantity) {
  //   setState(() {
  //     fruits.add(BoxModel(title: name, value: quantity));
  //     user_metric.add(BoxModel(title: name, value: quantity));
  //   });
  // }

  // Save selected metrics to Data provider
  void saveMetric() {
    try {
      Map<String, int> metricMap = {};
      for (var metric in user_metric) {
        metricMap[metric.title] = metric.value;
      }

      context.read<Data>().setMetrics(metricMap);

      if (user_metric.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Metrics saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving metrics: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Subtle background color
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with back arrow and title
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context); // Navigate back
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Metrics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                        width: 48), // Balance the layout with back arrow
                  ],
                ),
              ),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'We prepared a lot of metrics for you, you can also choose one of these',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // Grid of metrics
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: fruits.length,
                    itemBuilder: (context, index) {
                      bool exists = user_metric
                          .any((met) => met.title == fruits[index].title);
                      return BoxTemp(
                        title: fruits[index].title,
                        value: fruits[index].value,
                        icon: fruits[index].icon,
                        onPressed: () => _tappedMetrics(
                            fruits[index].title, fruits[index].value),
                        tapped: exists,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Buttons at the bottom
              Center(
                child: ElevatedButton(
                  onPressed: saveMetric,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Finish',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
