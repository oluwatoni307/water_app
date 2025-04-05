import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:water/logic.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

const List<String> routes = ['/', '/profile', '/goals', '/settings'];

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
    final currentRoute = ModalRoute.of(context)?.settings.name ??
        '/'; // Determine the current index based on the route
    final currentIndex = routes.indexOf(currentRoute);
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
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            name,
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.w600),
                          ),
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
                const SizedBox(height: 15),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 130,
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
                            size: Size(double.infinity, 80),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatTime(nextReminderTime),
                                style: GoogleFonts.poppins(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                "$suggestedAmount ml water (${(suggestedAmount / 100).round()} Glass)",
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500),
                              ),
                              Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Open goal-setting dialog
                                  Navigator.pushNamed(
                                      context, '/log'); // Navigate to GoalPage
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                child: Text(
                                  "Log your water",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
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
                const SizedBox(height: 15),
                Row(
                  children: [
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: LiquidCircularProgressIndicator(
                        value: userData.goal > 0
                            ? (userData.Day_Log.values
                                    .fold(0, (sum, amount) => sum + amount) /
                                userData.goal)
                            : 0.0,
                        valueColor:
                            AlwaysStoppedAnimation(const Color(0xFF369FFF)),
                        backgroundColor: Colors.white,
                        // borderColor: const Color(0xFF369FFF),
                        // borderWidth: 5.0,
                        direction: Axis.vertical,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      children: [
                        Container(
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
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
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
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600),
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
                        const SizedBox(height: 13),
                        Container(
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
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500)),
                              SizedBox(height: 5),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  "${userData.goal}ml",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text("Statistics",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: WeeklyWaterTrackingChart(),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex, // Highlight the current tab
            onTap: (index) {
              final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
              final newRoute = routes[index];

              // Only navigate if the new route is different from the current one
              if (currentRoute != newRoute) {
                Navigator.pushNamed(context, newRoute);
              }
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
    ).then((_) => controller.dispose());
  }
}

class WeeklyWaterTrackingChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: 500,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  String text = '';
                  if (value == 0) {
                    text = 'Mon';
                  } else if (value == 1) {
                    text = 'Tue';
                  } else if (value == 2) {
                    text = 'Wed';
                  } else if (value == 3) {
                    text = 'Thu';
                  } else if (value == 4) {
                    text = 'Fri';
                  } else if (value == 5) {
                    text = 'Sat';
                  } else if (value == 6) {
                    text = 'Sun';
                  }
                  return Text(
                    text,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 18,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 2500,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.black87,
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final day = spot.x == 0
                      ? 'Mon'
                      : spot.x == 1
                          ? 'Tue'
                          : spot.x == 2
                              ? 'Wed'
                              : spot.x == 3
                                  ? 'Thu'
                                  : spot.x == 4
                                      ? 'Fri'
                                      : spot.x == 5
                                          ? 'Sat'
                                          : 'Sun';
                  return LineTooltipItem(
                    '$day\n${spot.y.toInt()}ml',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
            touchCallback:
                (FlTouchEvent event, LineTouchResponse? touchResponse) {},
            handleBuiltInTouches: true,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 1500), // Monday
                FlSpot(1, 1300), // Tuesday
                FlSpot(2, 2000), // Wednesday (highlighted in design)
                FlSpot(3, 1800), // Thursday
                FlSpot(4, 1600), // Friday
                FlSpot(5, 1100), // Saturday
                FlSpot(6, 2200), // Sunday
              ],
              isCurved: true,
              color: Colors.blue.shade400,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    // Make Wednesday (day 2) highlighted with a larger dot

                    return FlDotCirclePainter(
                      radius: 0, // Hide all other dots
                      color: Colors.transparent,
                      strokeWidth: 0,
                      strokeColor: Colors.transparent,
                    );
                  }),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.2),
                    Colors.blue.withOpacity(0.02),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
