import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/bloc/auth/auth_bloc.dart';
import 'package:to_do_list_app/bloc/auth/auth_state.dart';
import 'package:to_do_list_app/providers/theme_provider.dart';
import 'package:to_do_list_app/services/summary_service.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int completedTasks = 0;
  int pendingTasks = 0;
  int todayTasks = 0;
  int thisWeekTasks = 0;
  int thisWeekCompletedTasks = 0;
  int currentStreak = 0;
  int longestStreak = 0;
  double completionRate = 0.0;
  bool isLoading = true;

  List<Map<String, dynamic>> weeklyTaskData = [];
  int weekOffset = 0; // Theo dõi tuần đang xem (0: tuần hiện tại, -10 đến 10)

  final SummaryService summaryService = SummaryService();

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() {
      isLoading = true;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.authResponse != null) {
      try {
        final userId = authState.authResponse!.user.id;
        final now = DateTime.now();

        final total = await summaryService.countTasksInDay(userId, now);
        final completed = await summaryService.countCompletedTasksInDay(
          userId,
          now,
        );
        final pending = await summaryService.countUncompletedTasksInDay(
          userId,
          now,
        );
        final weekTotal = await summaryService.countTasksInWeek(userId, now);
        final weekCompleted = await summaryService.countCompletedTasksInWeek(
          userId,
          now,
        );
        final streakData = await summaryService.getStreak(userId);

        await _fetchWeeklyData(userId, now);

        setState(() {
          todayTasks = total;
          completedTasks = completed;
          pendingTasks = pending;
          thisWeekTasks = weekTotal;
          thisWeekCompletedTasks = weekCompleted;
          completionRate = total > 0 ? completed / total : 0.0;
          currentStreak = streakData['currentStreak'] ?? 0;
          longestStreak = streakData['longestStreak'] ?? 0;
          isLoading = false;
        });
      } catch (e) {
        print('Lỗi khi lấy dữ liệu thống kê: $e');
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchWeeklyData(int userId, DateTime now) async {
    weeklyTaskData.clear();
    final startOfWeek = now.subtract(
      Duration(days: now.weekday - 1 + weekOffset * 7),
    );
    for (int i = 0; i < 7; ++i) {
      final date = startOfWeek.add(Duration(days: i));
      final dayTotal = await summaryService.countTasksInDay(userId, date);
      final dayCompleted = await summaryService.countCompletedTasksInDay(
        userId,
        date,
      );
      final dayPending = await summaryService.countUncompletedTasksInDay(
        userId,
        date,
      );
      weeklyTaskData.add({
        'date': date,
        'completed': dayCompleted,
        'pending': dayPending,
        'total': dayTotal,
      });
    }
  }

  void _changeWeek(int direction) {
    final newOffset = weekOffset + direction;
    if (newOffset >= -10 && newOffset <= 10) {
      setState(() {
        weekOffset = newOffset;
        isLoading = true;
      });
      _fetchSummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final colors = AppThemeConfig.getColors(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final weekStartDate = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1 + weekOffset * 7),
    );
    final weekLabel =
        'Week of ${DateFormat('yyyy-MM-dd').format(weekStartDate)}';

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: colors.bgColor),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.textColor,
                    ),
                  ),
                ),
              ),
              Text(
                'Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SummaryCard(
                    title: "Completed",
                    value: "$completedTasks",
                    icon: Icons.check_circle,
                    borderColor: isDark ? Colors.green.shade600 : Colors.green,
                    iconColor: isDark ? Colors.green : Colors.greenAccent,
                  ),
                  SummaryCard(
                    title: "Pending",
                    value: "$pendingTasks",
                    icon: Icons.access_time,
                    borderColor: Colors.amber,
                    iconColor: isDark ? Colors.amberAccent : Colors.amber,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SummaryCard(
                    title: "Longest Streak",
                    value: "$longestStreak",
                    icon: Icons.local_fire_department,
                    borderColor:
                        isDark ? Colors.orange.shade900 : Colors.orange,
                    iconColor: isDark ? Colors.orange : Colors.orangeAccent,
                  ),
                  SummaryCard(
                    title: "This Week",
                    value: "$thisWeekTasks",
                    icon: Icons.show_chart,
                    borderColor: isDark ? Colors.blue.shade600 : Colors.blue,
                    iconColor: isDark ? Colors.blue : Colors.blueAccent,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colors.itemBgColor,
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 36,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Current Streak',
                          style: TextStyle(
                            color: colors.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentStreak days',
                      style: TextStyle(
                        color: colors.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep completing tasks daily to maintain your streak!',
                      style: TextStyle(
                        color: colors.subtitleColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  ProgressCard(
                    title: "Completion Rate",
                    subTitle: "You've completed $completedTasks tasks in total",
                    progressText:
                        "${(completionRate * 100).toStringAsFixed(0)}%",
                    progressValue: completionRate,
                  ),
                  const SizedBox(height: 12),
                  ProgressCard(
                    title: "Progress this week",
                    subTitle: "Weekly task completion summary",
                    progressText: "$thisWeekCompletedTasks/$thisWeekTasks",
                    progressValue:
                        thisWeekTasks > 0
                            ? thisWeekCompletedTasks / thisWeekTasks
                            : 0.0,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Weekly Task Chart',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_left,
                          size: 36,
                          color:
                              weekOffset > -10
                                  ? colors.textColor
                                  : colors.textColor.withOpacity(0.3),
                        ),
                        onPressed:
                            weekOffset < 10 ? () => _changeWeek(1) : null,
                      ),
                      Text(
                        weekLabel,
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.subtitleColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_right,
                          size: 36,
                          color:
                              weekOffset < 10
                                  ? colors.textColor
                                  : colors.textColor.withOpacity(0.3),
                        ),
                        onPressed:
                            weekOffset > -10 ? () => _changeWeek(-1) : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 250,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.itemBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        weeklyTaskData.every((data) => data['total'] == 0)
                            ? Center(
                              child: Text(
                                'No tasks this week',
                                style: TextStyle(
                                  color: colors.textColor,
                                  fontSize: 16,
                                ),
                              ),
                            )
                            : BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY:
                                    weeklyTaskData
                                        .map(
                                          (e) =>
                                              (e['completed'] + e['pending'])
                                                  .toDouble(),
                                        )
                                        .reduce((a, b) => a > b ? a : b) *
                                    1.2,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem: (
                                      group,
                                      groupIndex,
                                      rod,
                                      rodIndex,
                                    ) {
                                      final day = DateFormat('EEE').format(
                                        weeklyTaskData[groupIndex]['date'],
                                      );
                                      final value = rod.toY.toInt();
                                      final type =
                                          rodIndex == 0
                                              ? 'Completed'
                                              : 'Pending';
                                      return BarTooltipItem(
                                        '$day\n$type: $value',
                                        TextStyle(
                                          color: colors.textColor,
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index >= 0 &&
                                            index < weeklyTaskData.length) {
                                          return Text(
                                            DateFormat('EEE').format(
                                              weeklyTaskData[index]['date'],
                                            ),
                                            style: TextStyle(
                                              color: colors.textColor,
                                              fontSize: 12,
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                            color: colors.textColor,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: const FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups:
                                    weeklyTaskData.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final data = entry.value;
                                      return BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: data['completed'].toDouble(),
                                            color: Colors.green,
                                            width: 10,
                                          ),
                                          BarChartRodData(
                                            toY: data['pending'].toDouble(),
                                            color: Colors.amber,
                                            width: 10,
                                          ),
                                        ],
                                        barsSpace: 4,
                                      );
                                    }).toList(),
                              ),
                            ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(width: 12, height: 12, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: colors.textColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          Container(width: 12, height: 12, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            'Pending',
                            style: TextStyle(
                              color: colors.textColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color borderColor;
  final Color iconColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.borderColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);

    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.itemBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: colors.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(color: colors.subtitleColor, fontSize: 16),
              ),
            ],
          ),
          Icon(icon, color: iconColor, size: 36),
        ],
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final String title;
  final String? subTitle;
  final String progressText;
  final double progressValue;

  const ProgressCard({
    super.key,
    required this.title,
    this.subTitle,
    required this.progressText,
    required this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.itemBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
              Text(
                progressText,
                style: const TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: colors.textColor,
            valueColor: const AlwaysStoppedAnimation<Color>(
              Colors.deepPurpleAccent,
            ),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          if (subTitle != null)
            Text(
              subTitle!,
              style: TextStyle(color: colors.subtitleColor, fontSize: 14),
            ),
        ],
      ),
    );
  }
}
