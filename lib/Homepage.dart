import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:water/logic.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';
import 'package:provider/provider.dart';

const List<String> routes = ['/', '/profile', '/goals', '/'];

class WaterTrackScreen extends StatelessWidget {
  const WaterTrackScreen({super.key});

  // Helper to format DateTime to "HH:MM AM/PM"
  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  // Helper to get greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)!.settings.name;
    // Determine the current index based on the route
    final currentIndex = routes.indexOf(currentRoute!);
    return Consumer<Data>(
      builder: (context, data, child) {
        final userData = data.user; // Access UserData
        final (nextReminderTime, suggestedAmount) =
            data.calculateNextReminder();
        final greeting = _getGreeting();
        final name = userData.userName.isNotEmpty
            ? userData.userName
            : 'User'; // Fallback if empty

        return Scaffold(
          backgroundColor: Color(0xFFF4F8FB),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: TextStyle(fontSize: 22, color: Colors.grey),
                        ),
                        Text(
                          name,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.blue,
                        size: 40,
                      ),
                      onPressed: () {
                        // TODO: Implement notification action
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: WaveWidget(
                            config: CustomConfig(
                              colors: [
                                Color(0x695DCCFC),
                                Color(0x695DCCFC),
                              ],
                              durations: [4000, 3200],
                              heightPercentages: [0.20, 0.25],
                              blur: MaskFilter.blur(BlurStyle.solid, 10),
                            ),
                            waveAmplitude: 10,
                            size: Size(double.infinity, 130),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatTime(nextReminderTime),
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "$suggestedAmount ml water (${(suggestedAmount / 100).round()} Glass)",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 50),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Open goal-setting dialog
                                  Navigator.pushNamed(
                                      context, '/log'); // Navigate to GoalPage
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                child: const Text(
                                  "Add Your Goal",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Container(
                          width: 150,
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    userData.lastLog.isNotEmpty
                                        ? _formatTime(DateTime.now().subtract(
                                            userData.lastLog.keys.first))
                                        : 'N/A',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 7),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: userData.goal > 0
                                          ? userData.Day_Log.values.fold(
                                                  0,
                                                  (sum, amount) =>
                                                      sum + amount) /
                                              userData.goal
                                          : 0.0,
                                      backgroundColor: Colors.grey.shade300,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    userData.lastLog.isNotEmpty
                                        ? "${userData.lastLog.values.first}ml"
                                        : "0ml",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.red),
                                  ),
                                  Text(
                                    userData.goal > 0
                                        ? "${((userData.Day_Log.values.fold(0, (sum, amount) => sum + amount) / userData.goal) * 100).round()}%"
                                        : "0%",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 60),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 35, 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text("Target:",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                          SizedBox(height: 5),
                          Text(
                            "${userData.goal}ml",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Statistic",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: LineChartWidget(),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex, // Highlight the current tab
            onTap: (index) {
              // Navigate to the selected route, replacing the current one
              Navigator.pushNamed(context, routes[index]);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.blueGrey),
                label: "Home",
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart, color: Colors.blueGrey),
                  label: "Analysis"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings, color: Colors.blueGrey),
                  label: "Setting"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person, color: Colors.blueGrey),
                  label: "Profile"),
            ],
          ),
        );
      },
    );
  }

  // Dialog to set a new goal
  void _showGoalDialog(BuildContext context, Data data) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Your Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Goal (ml)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              data.setGoals(controller.text);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 1),
              FlSpot(1, 1.5),
              FlSpot(2, 1),
              FlSpot(3, 2),
              FlSpot(4, 1.5),
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
          ),
        ],
      ),
    );
  }
}
