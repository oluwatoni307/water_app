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
  List<BoxModel> userMetric = [];

  @override
  void initState() {
    super.initState();
    final existingMetrics = context.read<Data>().user.metric;
    userMetric = fruits
        .where((fruit) => existingMetrics.containsKey(fruit.title))
        .map((fruit) => BoxModel(title: fruit.title, value: fruit.value))
        .toList();
  }

  void _tappedMetrics(String name, int quantity) {
    setState(() {
      bool exists = userMetric.any((metric) => metric.title == name);
      if (exists) {
        userMetric.removeWhere((metric) => metric.title == name);
      } else {
        userMetric.add(BoxModel(title: name, value: quantity));
      }
    });
  }

  void saveMetric() {
    try {
      if (userMetric.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please select at least one fruit to track hydration.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Map<String, int> metricMap = {
        for (var metric in userMetric) metric.title: metric.value,
      };

      context.read<Data>().setMetrics(metricMap);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fruit metrics saved! Stay hydrated 🍉🍍🥭'),
          backgroundColor: Colors.green,
        ),
      );

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
    const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 16.0);

    return Scaffold(
      backgroundColor: Colors.grey[200],
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Fruit Hydration',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Padding(
                padding: pagePadding,
                child: Text(
                  'Choose the fruits you enjoy most! They help track your hydration. Long-press any fruit to discover its benefits.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Padding(
                  padding: pagePadding,
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
                      final fruit = fruits[index];
                      final isSelected =
                          userMetric.any((m) => m.title == fruit.title);
                      return GestureDetector(
                        child: BoxTemp(
                          title: fruit.title,
                          value: fruit.value,
                          icon: fruit.icon,
                          onPressed: () =>
                              _tappedMetrics(fruit.title, fruit.value),
                          tapped: isSelected,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
