import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/providers/theme_provider.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class CategoryChip extends StatelessWidget {
  final int id;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback? onPressed;

  const CategoryChip({
    super.key,
    required this.id,
    required this.label,
    required this.color,
    required this.isSelected,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : colors.itemBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: colors.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryList extends StatefulWidget {
  final List<CategoryChip> categories;
  final Function(List<CategoryChip>) onCategoryUpdated;
  final Function(List<int>) onCategorySelected;
  final bool isMultiSelect;
  final bool showAddButton;
  final VoidCallback? onAddButtonPressed;

  const CategoryList({
    super.key,
    required this.categories,
    required this.onCategoryUpdated,
    required this.onCategorySelected,
    this.isMultiSelect = true,
    this.showAddButton = true,
    this.onAddButtonPressed,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  List<int> selectedCategoryIds = [];

  void _toggleCategory(int id) {
    setState(() {
      if (widget.isMultiSelect) {
        if (selectedCategoryIds.contains(id)) {
          selectedCategoryIds.remove(id);
        } else {
          selectedCategoryIds.add(id);
        }
      } else {
        selectedCategoryIds = [id];
      }
    });

    widget.onCategorySelected(selectedCategoryIds);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length + (widget.showAddButton ? 1 : 0),
        itemBuilder: (context, index) {
          if (widget.showAddButton && index == widget.categories.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: widget.onAddButtonPressed,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.itemBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: colors.textColor, size: 24),
                ),
              ),
            );
          }
          final category = widget.categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CategoryChip(
              id: category.id,
              label: category.label,
              color: category.color,
              isSelected: selectedCategoryIds.contains(category.id),
              onPressed: () => _toggleCategory(category.id),
            ),
          );
        },
      ),
    );
  }
}

class WeekdaySelector extends StatefulWidget {
  final Function(List<int>) onSelectionChanged;

  const WeekdaySelector({super.key, required this.onSelectionChanged});

  @override
  // ignore: library_private_types_in_public_api
  _WeekdaySelectorState createState() => _WeekdaySelectorState();
}

class _WeekdaySelectorState extends State<WeekdaySelector> {
  List<int> selectedDays = [];

  final List<String> days = ["2", "3", "4", "5", "6", "7", "C"];

  void toggleSelection(int index) {
    setState(() {
      if (selectedDays.contains(index)) {
        selectedDays.remove(index);
      } else {
        selectedDays.add(index);
      }
      widget.onSelectionChanged(selectedDays);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(days.length, (index) {
        bool isSelected = selectedDays.contains(index);
        return GestureDetector(
          onTap: () => toggleSelection(index),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? colors.primaryColor : Colors.grey,
                width: 2,
              ),
              color: isSelected ? colors.primaryColor : colors.itemBgColor,
            ),
            alignment: Alignment.center,
            child: Text(
              days[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class PrioritySelector extends StatefulWidget {
  final Function(String) onPrioritySelected;

  const PrioritySelector({super.key, required this.onPrioritySelected});

  @override
  // ignore: library_private_types_in_public_api
  _PrioritySelectorState createState() => _PrioritySelectorState();
}

class _PrioritySelectorState extends State<PrioritySelector> {
  String selectedPriority = "";

  void selectPriority(String priority) {
    setState(() {
      selectedPriority = priority;
    });
    widget.onPrioritySelected(priority);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    bool isDark = themeProvider.isDarkMode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildPriorityButton("High", isDark ? Colors.red : Colors.red.shade700),
        _buildPriorityButton(
          "Medium",
          isDark ? Colors.orange : Colors.orange.shade700,
        ),
        _buildPriorityButton(
          "Low",
          isDark ? Colors.blue : Colors.blue.shade700,
        ),
      ],
    );
  }

  Widget _buildPriorityButton(String label, Color color) {
    bool isSelected = selectedPriority == label;
    final colors = AppThemeConfig.getColors(context);

    return GestureDetector(
      onTap: () => selectPriority(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
          color: isSelected ? color : colors.itemBgColor,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
