import 'package:firebase_auth/firebase_auth.dart';
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

const List<String> routes = [
  '/',
  '/analysis',
  '/goals',
  '/metric',
  '/settings'
];

class WaterTrackScreen extends StatefulWidget {
  const WaterTrackScreen({super.key});
  static bool _hasShownDialog = false; // Track if dialog has been shown

  @override
  _WaterTrackScreenState createState() => _WaterTrackScreenState();
}

class _WaterTrackScreenState extends State<WaterTrackScreen>
    with WidgetsBindingObserver {
  // Helper to format DateTime to "HH:MM AM/PM"
  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Map<String, String> _getHeadlineSubhead(num percentage, String name) {
    name = name.isNotEmpty ? name : 'User';
    if (percentage <= 25) {
      return {
        'headline': 'Start Hydrating!',
        'subhead': 'Hey $name, a few sips now boost your energy and day!',
      };
    } else if (percentage <= 50) {
      return {
        'headline': 'Keep Sipping!',
        'subhead': 'Nice start, $name! Stay steady to hit your hydration goal!',
      };
    } else if (percentage <= 75) {
      return {
        'headline': 'Almost Done!',
        'subhead': 'Awesome, $name! A bit more to crush your goal today!',
      };
    }
    return {
      'headline': 'Hydration Star!',
      'subhead': 'Wow, $name! You’re killing it—keep up that hydration streak!',
    };
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null || WaterTrackScreen._hasShownDialog) return;

      // Set the flag *before* showing the dialog to prevent re-entry
      WaterTrackScreen._hasShownDialog = true;

      final data = Provider.of<Data>(context, listen: false);

      if (data.isSignUp) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => InfoDialog(),
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
    }
  }

  void _handleAppResumed() async {
    final data = Provider.of<Data>(context, listen: false);
    await data.checkAndUpdateDayRollover();
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    final currentIndex = routes.indexOf(currentRoute);

    return Consumer<Data>(
      builder: (context, data, child) {
        final userData = data.user;
        final name = userData.userName.isNotEmpty ? userData.userName : 'User';
        final amountDrank =
            userData.Day_Log.values.fold(0, (sum, amount) => sum + amount);
        final num percentage =
            userData.goal > 0 ? (amountDrank / userData.goal) * 100 : 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F8FB),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getHeadlineSubhead(percentage, name)['headline']!,
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        _getHeadlineSubhead(percentage, name)['subhead']!,
                        style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 135,
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
                                const Color(0x695DCCFC),
                                const Color(0x695DCCFC),
                              ],
                              durations: [4000, 3200],
                              heightPercentages: [0.20, 0.25],
                              blur: const MaskFilter.blur(BlurStyle.solid, 10),
                            ),
                            waveAmplitude: 10,
                            size: const Size(double.infinity, 80),
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
                                  const Icon(Icons.water_drop,
                                      color: Colors.blue, size: 27),
                                  Text(
                                    "Today's Progress ",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
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
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "/ ${userData.goal}ml",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 0.0, 5.0, 0.0),
                                      child: Text(
                                        "${percentage.toStringAsFixed(0)}% complete",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
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
                                    fontSize: 13,
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
                        width: 115,
                        height: 115,
                        child: ElegantGlassWidget(
                          level: percentage * 0.01,
                          waterColor: const Color(0xFF5DADE2),
                        )),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        Container(
                          width: 150,
                          padding: const EdgeInsets.all(11.0),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Last Log",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  Text(
                                    userData.Day_Log.isNotEmpty
                                        ? _formatTime(DateTime.now().copyWith(
                                            hour: userData
                                                .Day_Log.keys.last.inHours,
                                            minute: (userData.Day_Log.keys.last
                                                    .inMinutes %
                                                60),
                                            second: 0,
                                            millisecond: 0,
                                          ))
                                        : 'N/A',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 7),
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
                                    userData.Day_Log.isNotEmpty
                                        ? "${userData.Day_Log.values.last}ml"
                                        : "0ml",
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    userData.goal > 0
                                        ? "${((userData.Day_Log.values.fold(0, (sum, amount) => sum + amount) / userData.goal) * 100).round()}%"
                                        : "0%",
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.fromLTRB(12, 10, 35, 10),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Target Goal:",
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 5),
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
                const SizedBox(height: 5),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: WeeklyWaterTrackingChart(
                        completedLog: data.user.Log, // Historical data
                        todayIntake: amountDrank, // Current day total
                        currentDate: DateTime.now(),
                        goal: data.user.goal,
                      )),
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
        title: const Text('Set Your Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Goal (ml)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              data.setGoals(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }
}

class WeeklyWaterTrackingChart extends StatefulWidget {
  final List<int> completedLog;
  final int todayIntake;
  final DateTime currentDate;
  final int goal;
  final void Function(int startIndex, int endIndex)? onRangeSelected;

  const WeeklyWaterTrackingChart({
    super.key,
    required this.completedLog,
    required this.todayIntake,
    required this.currentDate,
    required this.goal,
    this.onRangeSelected,
  });

  @override
  _WeeklyWaterTrackingChartState createState() =>
      _WeeklyWaterTrackingChartState();
}

class _WeeklyWaterTrackingChartState extends State<WeeklyWaterTrackingChart> {
  List<int> _getLast7Days(List<int> completedLog, int todayIntake) {
    if (completedLog.length >= 6) {
      return [...completedLog.sublist(completedLog.length - 6), todayIntake];
    } else {
      final missingDays = 6 - completedLog.length;
      return [...List.filled(missingDays, 0), ...completedLog, todayIntake];
    }
  }

  @override
  Widget build(BuildContext context) {
    final last7DaysData =
        _getLast7Days(widget.completedLog, widget.todayIntake);

    final last7Days = List.generate(
      7,
      (i) => widget.currentDate.subtract(Duration(days: 6 - i)),
    );

    final maxLogged = last7DaysData.isNotEmpty
        ? last7DaysData.reduce((a, b) => a > b ? a : b)
        : widget.goal;
    final baseMaxY = (maxLogged > widget.goal ? maxLogged : widget.goal)
        .clamp(0, double.infinity);
    final maxY = (baseMaxY == 0 ? 1000 : baseMaxY) * 1.15;

    final spots = <FlSpot>[];
    final missingIndexes = <int>{};

    for (var i = 0; i < 7; i++) {
      final value = last7DaysData[i];
      if (value == 0) {
        missingIndexes.add(i);
      }
      spots.add(FlSpot(i.toDouble(), value.toDouble()));
    }

    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final completedDays = last7DaysData.where((d) => d >= widget.goal).length;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFFAFBFF),
            Colors.grey.shade50,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF4A90E2).withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Enhanced Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Progress',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1D29),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Keep up the great work! 💪',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: completedDays >= 5
                        ? [const Color(0xFF4CAF50), const Color(0xFF45A049)]
                        : completedDays >= 3
                            ? [const Color(0xFF4A90E2), const Color(0xFF357ABD)]
                            : [
                                const Color(0xFFFF9800),
                                const Color(0xFFF57C00)
                              ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (completedDays >= 5
                              ? const Color(0xFF4CAF50)
                              : completedDays >= 3
                                  ? const Color(0xFF4A90E2)
                                  : const Color(0xFFFF9800))
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      completedDays >= 5 ? Icons.star : Icons.trending_up,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$completedDays/7 days',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),

          // Enhanced Chart Area
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: maxY / 5,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: const Color(0xFF4A90E2).withOpacity(0.06),
                    strokeWidth: 1,
                    dashArray: [6, 6],
                  ),
                  drawVerticalLine: true,
                  verticalInterval: 1,
                  getDrawingVerticalLine: (_) => FlLine(
                    color: const Color(0xFF4A90E2).withOpacity(0.04),
                    strokeWidth: 1,
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: widget.goal.toDouble().clamp(0, double.infinity),
                      color: const Color(0xFF4CAF50),
                      strokeWidth: 2,
                      dashArray: [10, 6],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 8, top: 2),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF4CAF50),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          backgroundColor: Colors.white,
                        ),
                        labelResolver: (_) => '🎯 Goal ${widget.goal}ml',
                      ),
                    ),
                  ],
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < last7Days.length) {
                          final wd = last7Days[idx].weekday;
                          final isToday = last7Days[idx].day ==
                                  widget.currentDate.day &&
                              last7Days[idx].month ==
                                  widget.currentDate.month &&
                              last7Days[idx].year == widget.currentDate.year;

                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: isToday
                                ? BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4A90E2),
                                        Color(0xFF357ABD)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF4A90E2)
                                            .withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  )
                                : null,
                            child: Text(
                              weekdayNames[wd - 1],
                              style: GoogleFonts.inter(
                                color: isToday
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontSize: 11,
                                fontWeight:
                                    isToday ? FontWeight.w700 : FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchCallback: (touch, response) {},
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: const Color(0xFF1A1D29),
                    tooltipRoundedRadius: 16,
                    tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    tooltipMargin: 12,
                    tooltipBorder: BorderSide(
                      color: const Color(0xFF4A90E2).withOpacity(0.2),
                      width: 1,
                    ),
                    getTooltipItems: (spots) => spots.map((spot) {
                      final index = spot.x.toInt();
                      final date = last7Days[index];
                      final weekday = weekdayNames[date.weekday - 1];
                      final isToday = date.day == widget.currentDate.day &&
                          date.month == widget.currentDate.month &&
                          date.year == widget.currentDate.year;
                      final percentage = ((spot.y / widget.goal) * 100).round();

                      return LineTooltipItem(
                        '${isToday ? '💧 Today' : '📅 $weekday'}\n${spot.y.toInt()}ml ($percentage%)',
                        GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    preventCurveOverShooting: true,
                    color: const Color(0xFF4A90E2),
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        final isToday = index == 6;
                        final value = spot.y.toInt();
                        final reachedGoal = value >= widget.goal;

                        if (missingIndexes.contains(index)) {
                          return FlDotCirclePainter(
                            radius: 6,
                            strokeWidth: 2,
                            color: Colors.grey.shade200,
                            strokeColor: Colors.grey.shade400,
                          );
                        }

                        if (isToday) {
                          return FlDotCirclePainter(
                            radius: 9,
                            strokeWidth: 4,
                            color: reachedGoal
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF4A90E2),
                            strokeColor: Colors.white,
                          );
                        }

                        return FlDotCirclePainter(
                          radius: reachedGoal ? 7 : 5,
                          color: reachedGoal
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF4A90E2),
                          strokeWidth: 3,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4A90E2).withOpacity(0.2),
                          const Color(0xFF4A90E2).withOpacity(0.08),
                          const Color(0xFF4A90E2).withOpacity(0.02),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                    shadow: Shadow(
                      color: const Color(0xFF4A90E2).withOpacity(0.15),
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
