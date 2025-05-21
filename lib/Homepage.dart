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

class _WaterTrackScreenState extends State<WaterTrackScreen> {
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
                const SizedBox(height: 20),
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
                          padding: const EdgeInsets.all(13.0),
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
                                    userData.lastLog.isNotEmpty
                                        ? "${userData.lastLog.values.first}ml"
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
                            children: [
                              Text(
                                "Target:",
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey,
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
                      log: userData.Log,
                      currentDate: userData.currentDate,
                      goal: userData.goal,
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
  final List<int> log;
  final DateTime currentDate;
  final int goal;
  final void Function(int startIndex, int endIndex)? onRangeSelected;

  const WeeklyWaterTrackingChart({
    super.key,
    required this.log,
    required this.currentDate,
    required this.goal,
    this.onRangeSelected,
  });

  @override
  _WeeklyWaterTrackingChartState createState() =>
      _WeeklyWaterTrackingChartState();
}

class _WeeklyWaterTrackingChartState extends State<WeeklyWaterTrackingChart> {
  int? _dragStart;
  int? _dragEnd;

  @override
  Widget build(BuildContext context) {
    final last7Days = List.generate(
      7,
      (i) => widget.currentDate.subtract(Duration(days: 6 - i)),
    );

    final maxLogged = widget.log.isNotEmpty
        ? widget.log.reduce((a, b) => a > b ? a : b)
        : widget.goal;
    final baseMaxY = (maxLogged > widget.goal ? maxLogged : widget.goal)
        .clamp(0, double.infinity);
    final maxY = (baseMaxY == 0 ? 1000 : baseMaxY) * 1.1;

    final spots = <FlSpot>[];
    final missingIndexes = <int>{};
    for (var i = 0; i < 7; i++) {
      final date = last7Days[i];
      final daysAgo = widget.currentDate.difference(date).inDays;
      final logIndex = widget.log.length - 1 - daysAgo;
      final isMissing = logIndex < 0 || logIndex >= widget.log.length;
      if (isMissing) missingIndexes.add(i);
      final value =
          isMissing ? 0 : widget.log[logIndex].clamp(0, double.infinity);
      spots.add(FlSpot(i.toDouble(), value.toDouble()));
    }

    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return GestureDetector(
      onLongPressStart: (details) => setState(() => _dragStart = null),
      onLongPressMoveUpdate: (details) {},
      onLongPressEnd: (details) {
        if (_dragStart != null &&
            _dragEnd != null &&
            widget.onRangeSelected != null) {
          final start = _dragStart!.clamp(0, 6);
          final end = _dragEnd!.clamp(0, 6);
          widget.onRangeSelected!(start, end);
        }
        setState(() {
          _dragStart = _dragEnd = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
              drawVerticalLine: false,
            ),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: widget.goal.toDouble().clamp(0, double.infinity),
                  color: Colors.redAccent,
                  strokeWidth: 2,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    labelResolver: (_) => 'Goal: ${widget.goal}ml',
                  ),
                ),
              ],
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (value, _) {
                    final idx = value.toInt();
                    if (idx >= 0 && idx < last7Days.length) {
                      final wd = last7Days[idx].weekday;
                      final isToday = last7Days[idx].day ==
                              widget.currentDate.day &&
                          last7Days[idx].month == widget.currentDate.month &&
                          last7Days[idx].year == widget.currentDate.year;
                      return Text(
                        weekdayNames[wd - 1],
                        style: TextStyle(
                          color: isToday
                              ? Colors.blueAccent
                              : Colors.grey.shade600,
                          fontSize: 10,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchCallback: (touch, response) {},
              touchTooltipData: LineTouchTooltipData(
                tooltipRoundedRadius: 8,
                getTooltipItems: (spots) => spots.map((spot) {
                  final index = spot.x.toInt();
                  final date = last7Days[index];
                  final weekday = weekdayNames[date.weekday - 1];
                  return LineTooltipItem(
                    '$weekday\n${spot.y.toInt()}ml',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) {
                    if (missingIndexes.contains(index)) {
                      return FlDotCirclePainter(
                        radius: 4,
                        strokeWidth: 2,
                        color: Colors.grey,
                        strokeColor: Colors.grey,
                      );
                    }
                    return FlDotCirclePainter(radius: 0);
                  },
                ),
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
      ),
    );
  }
}
