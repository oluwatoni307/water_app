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

// Replace the existing 30-day trend section with this improved version

// 30-day trend chart with improved design
Widget build30DayTrendChart(List<int> allDaysData, int goal, int highest) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeOutCubic,
    builder: (context, animationValue, child) {
      return Transform.scale(
        scale: 0.95 + (0.05 * animationValue),
        child: Opacity(
          opacity: animationValue,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last 30 Days Trend',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your hydration journey',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF369FFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.show_chart,
                                size: 14,
                                color: const Color(0xFF369FFF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '30D',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF369FFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Chart
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: highest > 0
                              ? (highest.toDouble()) * 1.2
                              : 2000, // Default max if no data

                          // Grid styling
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: highest > 0
                                ? (highest * 1.2) / 4
                                : 500, // Default to 500ml intervals if no data
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade200,
                                strokeWidth: 1,
                              );
                            },
                          ),

                          // Titles/Axis
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 5,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  // Show every 5th day: 1, 5, 10, 15, 20, 25, 30
                                  if (value == 0 ||
                                      value % 5 == 0 ||
                                      value == 29) {
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                        '${(value + 1).toInt()}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 45,
                                interval: highest > 0
                                    ? (highest * 1.2) / 4
                                    : 500, // Default to 500ml intervals if no data
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      '${value.toInt()}ml',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Border
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                              left: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),

                          // Goal line (horizontal reference)
                          extraLinesData: ExtraLinesData(
                            horizontalLines: [
                              HorizontalLine(
                                y: goal.toDouble(),
                                color: const Color(0xFF369FFF).withOpacity(0.4),
                                strokeWidth: 2,
                                dashArray: [5, 5],
                                label: HorizontalLineLabel(
                                  show: true,
                                  alignment: Alignment.topRight,
                                  style: TextStyle(
                                    color: const Color(0xFF369FFF),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  labelResolver: (line) => 'Goal',
                                ),
                              ),
                            ],
                          ),

                          // Line data
                          lineBarsData: [
                            LineChartBarData(
                              spots: _getLast30DaysSpots(allDaysData),
                              isCurved: true,
                              curveSmoothness: 0.3,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              color: const Color(0xFF369FFF),

                              // Gradient fill under the line
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF369FFF).withOpacity(0.3),
                                    const Color(0xFF369FFF).withOpacity(0.05),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),

                              // Data points (only show for values > 0)
                              dotData: FlDotData(
                                show: true,
                                checkToShowDot: (spot, barData) {
                                  return (spot.y) >
                                      0; // Zero-safe: only show dots for positive values
                                },
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 3,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: const Color(0xFF369FFF),
                                  );
                                },
                              ),
                            ),
                          ],

                          // Touch interaction
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: Colors.black87,
                              tooltipRoundedRadius: 8,
                              tooltipPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              getTooltipItems:
                                  (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((barSpot) {
                                  final dayNumber = (barSpot.x + 1).toInt();
                                  final intake = barSpot.y.toInt();
                                  return LineTooltipItem(
                                    'Day $dayNumber\n$intake ml',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                            handleBuiltInTouches: true,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Chart legend/info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(
                          color: const Color(0xFF369FFF),
                          label: 'Daily Intake',
                        ),
                        const SizedBox(width: 20),
                        _buildLegendItem(
                          color: const Color(0xFF369FFF).withOpacity(0.4),
                          label: 'Goal Line',
                          isDashed: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildLegendItem({
  required Color color,
  required String label,
  bool isDashed = false,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 16,
        height: 3,
        decoration: BoxDecoration(
          color: isDashed ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(2),
        ),
        child: isDashed
            ? CustomPaint(
                painter: DashedLinePainter(color: color),
              )
            : null,
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

// Custom painter for dashed line in legend
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    const dashWidth = 3.0;
    const dashSpace = 2.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Keep the existing _getLast30DaysSpots method from your original code
List<FlSpot> _getLast30DaysSpots(List<int> allDaysData) {
  return List.generate(30, (i) {
    final dataIndex = allDaysData.length - 30 + i;
    final val = dataIndex >= 0 ? allDaysData[dataIndex] : 0;
    return FlSpot(i.toDouble(), val.toDouble());
  });
}

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
                  // Replace this section:
// Text('Last 30 Days Trend'...
// SizedBox(height: 155, child: LineChart(...

// With:
                  build30DayTrendChart(allDaysData, goal, highest),
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
