import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:water/logic.dart';
import 'package:water/widgets/navBar.dart';
import 'package:water/widgets/inforwidget.dart';
import 'package:water/widgets/lotprogress.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

const List<String> routes = ['/', '/analysis', '/goals', '/settings'];

class WaterTrackScreen extends StatefulWidget {
  const WaterTrackScreen({super.key});
  static bool _hasShownDialog = false; // Track if dialog has been shown

  @override
  _WaterTrackScreenState createState() => _WaterTrackScreenState();
}

class _WaterTrackScreenState extends State<WaterTrackScreen> {
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

  // Show onboarding dialog for new users

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = Provider.of<Data>(context, listen: false);
      if (!WaterTrackScreen._hasShownDialog && data.isSignUp) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => InfoDialog(
            onFinish: () {
              setState(() {
                WaterTrackScreen._hasShownDialog = true;
              });
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    final currentIndex = routes.indexOf(currentRoute);

    return Consumer<Data>(
      builder: (context, data, child) {
        // Show dialog for new users

        final userData = data.user;
        final greeting = _getGreeting();
        final name = userData.userName.isNotEmpty ? userData.userName : 'User';
        final amountDrank =
            userData.Day_Log.values.fold(0, (sum, amount) => sum + amount);
        final num percentage =
            userData.goal > 0 ? (amountDrank / userData.goal) * 100 : 0;

        return Scaffold(
          backgroundColor: Color(0xFFF4F8FB),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    // IconButton(
                    //   icon: const Icon(
                    //     Icons.notifications_none,
                    //     color: Colors.blue,
                    //     size: 40,
                    //   ),
                    //   onPressed: () {
                    //     // TODO: Implement notification action
                    //   },
                    // ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 140,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.water_drop,
                                      color: Colors.blue, size: 27),
                                  Text(
                                    "Today's Progress ",
                                    style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 3.0, 0.0, 3.0),
                                child: Row(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "${amountDrank}ml",
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "/ ${userData.goal}ml",
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 0.0, 5.0, 0.0),
                                      child: Text(
                                        "${percentage.toStringAsFixed(0)}% complete",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/log');
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
                        child: ElegantGlassWidget(
                          level: percentage * 0.01, // 75% filled
                          waterColor: Color(0xFF5DADE2), // Light blue water
                        )),
                    SizedBox(width: 20),
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
                              Text(
                                "Target:",
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500),
                              ),
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
                Text(
                  "Statistics",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: WeeklyWaterTrackingChart(
                      dayLog: userData.Log,
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: navBar(
            currentIndex: currentIndex,
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
  final Map<DateTime, int> dayLog;

  const WeeklyWaterTrackingChart({super.key, required this.dayLog});

  @override
  Widget build(BuildContext context) {
    // Generate a list of the last 7 days (starting from Monday)
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final weekDays = List.generate(
      7,
      (i) => DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + i,
      ),
    );

    // Normalize dayLog dates to compare only year/month/day
    final normalizedLog = {
      for (final entry in dayLog.entries)
        DateTime(entry.key.year, entry.key.month, entry.key.day): entry.value
    };

    // Convert to FlSpots
    final spots = weekDays.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      final amount = normalizedLog[date] ?? 0;
      return FlSpot(index.toDouble(), amount.toDouble());
    }).toList();

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
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 2500,
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: 500,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun'
                  ];
                  if (value >= 0 && value < 7)
                    return Text(
                      days[value.toInt()],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    );
                  return const Text('');
                },
                reservedSize: 18,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.black87,
              tooltipRoundedRadius: 8,
              getTooltipItems: (spots) => spots.map((spot) {
                final dayName = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun'
                ][spot.x.toInt()];
                return LineTooltipItem(
                  '$dayName\n${spot.y.toInt()}ml',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue.shade400,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
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
