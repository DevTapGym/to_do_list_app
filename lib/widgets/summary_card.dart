import 'package:flutter/material.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
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
      padding: EdgeInsets.all(12),
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
              SizedBox(height: 6),
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
