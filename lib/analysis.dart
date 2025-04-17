// stats_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:water/logic.dart';
import 'package:water/model/navBar.dart';

const List<String> routes = ['/', '/analysis', '/goals', '/settings'];

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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
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
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
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

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<Data>(context);
    final log = data.user.Log; // Map<DateTime, int>
    final goal = data.user.goal;

    // Compute overall stats
    final daysLogged = log.length;
    final daysGoalMet = log.values.where((intake) => intake >= goal).length;
    final avgIntake = daysLogged > 0
        ? (log.values.reduce((a, b) => a + b) / daysLogged).round()
        : 0;
    final highest = log.entries.isNotEmpty
        ? log.entries.reduce((a, b) => a.value > b.value ? a : b)
        : MapEntry(DateTime.now(), 0);
    final lowest = log.entries.isNotEmpty
        ? log.entries.reduce((a, b) => a.value < b.value ? a : b)
        : MapEntry(DateTime.now(), 0);

    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    final currentIndex = routes.indexOf(currentRoute);

    const primaryColor = Color(0xFF369FFF);
    const secondaryColor = Color(0xFF5DCCFC);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Stat Cards in 2-column grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 13,
              mainAxisSpacing: 13,
              childAspectRatio: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatCard(
                  icon: Icons.calendar_today,
                  label: 'Days Logged',
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
                  value: '${highest.value}ml',
                ),
                StatCard(
                  icon: Icons.trending_down,
                  label: 'Lowest Intake',
                  value: '${lowest.value}ml',
                ),
              ],
            ),
            const SizedBox(height: 24),

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
                  final date = DateTime.now().subtract(Duration(days: 6 - idx));
                  final key = DateTime(date.year, date.month, date.day);
                  final intake = log[key] ?? 0;
                  final percent = goal > 0 ? (intake / goal).clamp(0, 1) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 80,
                      child: Column(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: intake.toDouble(),
                                    color: primaryColor,
                                    radius: 30,
                                    title: '${(percent * 100).round()}%',
                                    titleStyle: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  PieChartSectionData(
                                    value: (goal - intake).toDouble().abs(),
                                    color: Colors.grey.shade200,
                                    radius: 30,
                                    title: '',
                                  ),
                                ],
                                centerSpaceRadius: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun'
                            ][key.weekday - 1],
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // 30-day sparkline
            Text(
              'Last 30 Days Trend',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: log.values.fold(0, (p, n) => n > p ? n : p).toDouble() *
                      1.2,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(30, (i) {
                        final date =
                            DateTime.now().subtract(Duration(days: 29 - i));
                        final key = DateTime(date.year, date.month, date.day);
                        final val = log[key] ?? 0;
                        return FlSpot(i.toDouble(), val.toDouble());
                      }),
                      isCurved: true,
                      color: secondaryColor,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            secondaryColor.withOpacity(0.3),
                            secondaryColor.withOpacity(0.05)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Export or share button
          ],
        ),
      ),
      bottomNavigationBar: navBar(currentIndex: currentIndex),
    );
  }
}
