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
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final filledValue = widget.intake.toDouble().clamp(0.0, double.infinity);
    final emptyValue = (widget.goal - filledValue).clamp(0.0, double.infinity);

    return SizedBox(
      width: 60,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 14,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, resp) {
                        if (resp == null || resp.touchedSection == null) {
                          setState(() => _touchedIndex = null);
                          return;
                        }
                        setState(() => _touchedIndex =
                            resp.touchedSection!.touchedSectionIndex);
                      },
                    ),
                    sections: [
                      PieChartSectionData(
                        value: filledValue,
                        color: Colors.blueGrey,
                        radius: 18,
                        title: '',
                      ),
                      if (emptyValue > 0)
                        PieChartSectionData(
                          value: emptyValue,
                          color: Colors.grey.shade300,
                          radius: 18,
                          title: '',
                        ),
                    ],
                  ),
                ),
                if (_touchedIndex != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${widget.intake}ml\n${((filledValue / widget.goal) * 100).clamp(0.0, 100.0).round()}%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
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
    final log = data.user.Log; // List<int>
    final goal = data.user.goal;

    final daysLogged = log.where((v) => v > 0).length;
    final daysGoalMet = log.where((v) => v >= goal).length;
    final avgIntake =
        daysLogged > 0 ? (log.reduce((a, b) => a + b) / daysLogged).round() : 0;
    final highest = log.isNotEmpty ? log.reduce((a, b) => a > b ? a : b) : 0;
    final lowest = log.where((v) => v > 0).isNotEmpty
        ? log.where((v) => v > 0).reduce((a, b) => a < b ? a : b)
        : 0;

    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    final currentIndex = routes.indexOf(currentRoute);
    final last7 = log.length >= 7
        ? log.sublist(log.length - 7)
        : List.filled(7 - log.length, 0) + log;

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
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 3 / 1.2,
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
                    child: DayPie(intake: intake, goal: goal, label: weekday),
                  );
                },
              ),
            ),

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
                  maxY: (log.isEmpty
                          ? 100
                          : log.reduce((a, b) => a > b ? a : b).toDouble()) *
                      1.2,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(30, (i) {
                        final val = i < log.length ? log[i] : 0;
                        return FlSpot(i.toDouble(), val.toDouble());
                      }),
                      isCurved: true,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            buildStyledDayLog(context),
          ],
        ),
      ),
      bottomNavigationBar: navBar(currentIndex: currentIndex),
    );
  }

  Widget buildStyledDayLog(BuildContext context) {
    final data = Provider.of<Data>(context);

    final entries = data.user.Day_Log.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final totalGoal = data.user.goal.toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries.map((entry) {
          final time = TimeOfDay(
            hour: entry.key.inHours,
            minute: entry.key.inMinutes.remainder(60),
          ).format(context);
          final amount = entry.value.toDouble();
          final percentage = (amount / totalGoal).clamp(0.0, 1.0);

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percentage),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.2),
                        child: Icon(
                          Icons.water_drop,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      title: Text(
                        '$amount ml',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        time,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      trailing: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 4,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          Text(
                            '${(value * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
