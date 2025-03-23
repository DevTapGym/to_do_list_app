import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.black),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SummaryCard(
                  title: "Completed",
                  value: "0",
                  icon: Icons.check_circle,
                  borderColor: Colors.green,
                  iconColor: Colors.greenAccent,
                ),
                SummaryCard(
                  title: "Pending",
                  value: "0",
                  icon: Icons.access_time,
                  borderColor: Colors.orange,
                  iconColor: Colors.orangeAccent,
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SummaryCard(
                  title: "Today",
                  value: "0",
                  icon: Icons.bar_chart,
                  borderColor: Colors.purple,
                  iconColor: Colors.purpleAccent,
                ),
                SummaryCard(
                  title: "This week",
                  value: "0",
                  icon: Icons.show_chart,
                  borderColor: Colors.blue,
                  iconColor: Colors.blueAccent,
                ),
              ],
            ),
            SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color.fromARGB(255, 30, 30, 30),
              ),
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 36,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Current Streak',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '3 days',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Keep completing tasks daily to maintain your streak!',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Column(
              children: [
                ProgressCard(
                  title: "Completion Rate",
                  subTitle: "You've completed 0 tasks in total",
                  progressText: "0%",
                  progressValue: 0.0,
                ),
                SizedBox(height: 12),
                ProgressCard(
                  title: "Today's Progress",
                  progressText: "0/0",
                  progressValue: 0.0,
                ),
              ],
            ),
          ],
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
    return Container(
      width: 180,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 30, 30, 30),
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
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(title, style: TextStyle(color: Colors.grey, fontSize: 16)),
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
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 30, 30, 30),
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
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                progressText,
                style: TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
            minHeight: 6,
          ),

          SizedBox(height: 8),

          if (subTitle != null)
            Text(subTitle!, style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}
