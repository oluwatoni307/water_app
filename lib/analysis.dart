import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:water/logic.dart';
import 'package:water/widgets/navBar.dart';
import 'dart:ui';

const List<String> routes = [
  '/',
  '/analysis',
  '/goals',
  '/metric',
  '/settings'
];

/// Reusable statistic card for overview metrics
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const StatCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF369FFF);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 5),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Stateful widget for a single day pie with tooltip
class DayPie extends StatefulWidget {
  final int intake;
  final int goal;
  final String label;
  const DayPie(
      {Key? key, required this.intake, required this.goal, required this.label})
      : super(key: key);

  @override
  _DayPieState createState() => _DayPieState();
}

class _DayPieState extends State<DayPie> {
  @override
  Widget build(BuildContext context) {
    final filledValue = widget.intake.toDouble().clamp(0.0, double.infinity);
    final emptyValue = (widget.goal - filledValue).clamp(0.0, double.infinity);

    return SizedBox(
      width: 80, // Increased width
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 1, // Small gap between sections
                    centerSpaceRadius: 18, // Increased center space
                    sections: [
                      PieChartSectionData(
                        value: filledValue,
                        color: const Color(0xFF369FFF), // App blue color
                        radius: 22, // Increased radius
                        title: '',
                      ),
                      if (emptyValue > 0)
                        PieChartSectionData(
                          value: emptyValue,
                          color: Colors.grey.shade300,
                          radius: 22, // Increased radius
                          title: '',
                        ),
                    ],
                  ),
                ),
                // Always show stats in center
                Container(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.intake}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF369FFF),
                        ),
                      ),
                      Text(
                        '${((filledValue / widget.goal) * 100).clamp(0.0, 100.0).round()}%',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.label,
            style: TextStyle(color: Colors.grey[700], fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<Data>(context);
    final completedLog = data.user.Log; // Historical completed days
    final goal = data.user.goal;

    // Calculate today's intake from ongoing Day_Log
    final todayIntake = data.user.Day_Log.values.fold(0, (sum, a) => sum + a);

    // Create complete data including today
    final allDaysData = [...completedLog, todayIntake];
    final totalDays = allDaysData.length;

    // Statistics including zeros (failed days)
    final daysLogged = totalDays; // All days including zeros
    final daysGoalMet = allDaysData.where((v) => v >= goal).length;
    final avgIntake = totalDays > 0
        ? (allDaysData.reduce((a, b) => a + b) / totalDays).round()
        : 0;
    final highest = allDaysData.isNotEmpty
        ? allDaysData.reduce((a, b) => a > b ? a : b)
        : 0;
    final lowest = allDaysData.isNotEmpty
        ? allDaysData.reduce((a, b) => a < b ? a : b)
        : 0;

    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    final currentIndex = routes.indexOf(currentRoute);

    // Last 7 days including today
    final last7 = _getLast7Days(completedLog, todayIntake);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Statistics',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: totalDays == 0
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Stat Cards in 2-column grid
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 3 / 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StatCard(
                        icon: Icons.calendar_today,
                        label: 'Total Days',
                        value: '$daysLogged',
                      ),
                      StatCard(
                        icon: Icons.check_circle,
                        label: 'Days Goal Met',
                        value: '$daysGoalMet / $daysLogged',
                      ),
                      StatCard(
                        icon: Icons.water_drop,
                        label: 'Average Intake',
                        value: '${avgIntake}ml',
                      ),
                      StatCard(
                        icon: Icons.trending_up,
                        label: 'Highest Intake',
                        value: '${highest}ml',
                      ),
                      StatCard(
                        icon: Icons.trending_down,
                        label: 'Lowest Intake',
                        value: '${lowest}ml',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Today's Progress
                  Text(
                    'Today\'s Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${todayIntake}ml / ${goal}ml',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${goal > 0 ? ((todayIntake / goal) * 100).round() : 0}% of daily goal',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          CircularProgressIndicator(
                            value: goal > 0
                                ? (todayIntake / goal).clamp(0.0, 1.0)
                                : 0,
                            backgroundColor: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mini pies row (weekly)
                  Text(
                    'Last 7 Days',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (context, idx) {
                        final date =
                            DateTime.now().subtract(Duration(days: 6 - idx));
                        final weekday = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ][date.weekday - 1];
                        final intake = last7[idx];
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: DayPie(
                              intake: intake, goal: goal, label: weekday),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 30-day sparkline
                  Text(
                    'Last 30 Days Trend',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 155,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: (highest.toDouble()) * 1.2,
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _getLast30DaysSpots(allDaysData),
                            isCurved: true,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            color: const Color(0xFF369FFF), // App's blue color
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Today's log entries
                  if (data.user.Day_Log.isNotEmpty) ...[
                    Text(
                      'Today\'s Log Entries',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildStyledDayLog(context),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: navBar(currentIndex: currentIndex),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No data yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging your water intake to see statistics',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<int> _getLast7Days(List<int> completedLog, int todayIntake) {
    if (completedLog.length >= 6) {
      return [...completedLog.sublist(completedLog.length - 6), todayIntake];
    } else {
      // Fill missing days with zeros
      final missingDays = 6 - completedLog.length;
      return [...List.filled(missingDays, 0), ...completedLog, todayIntake];
    }
  }

  List<FlSpot> _getLast30DaysSpots(List<int> allDaysData) {
    return List.generate(30, (i) {
      final dataIndex = allDaysData.length - 30 + i;
      final val = dataIndex >= 0 ? allDaysData[dataIndex] : 0;
      return FlSpot(i.toDouble(), val.toDouble());
    });
  }

  Widget buildStyledDayLog(BuildContext context) {
    final data = Provider.of<Data>(context);

    final entries = data.user.Day_Log.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries.map((entry) {
          // Fix time calculation to handle 24+ hours
          final totalMinutes = entry.key.inMinutes;
          final hours = (totalMinutes ~/ 60) % 24;
          final minutes = totalMinutes % 60;

          final time = TimeOfDay(hour: hours, minute: minutes).format(context);
          final amount = entry.value.toDouble();

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                color: Colors.grey[50], // Slightly darker background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFF369FFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.water_drop,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    '${amount.toInt()}ml',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  subtitle: Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF369FFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${amount.toInt()}ml',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF369FFF),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
