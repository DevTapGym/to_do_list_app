import 'package:flutter/material.dart';

class Actionbutton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  const Actionbutton({super.key, this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        onPressed: onPressed ?? () {},
      ),
    );
  }
}

class CategoryChip extends StatefulWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback? onPressed; // Callback khi nhấn vào chip

  const CategoryChip({
    super.key,
    required this.label,
    required this.color,
    this.isSelected = false,
    this.onPressed,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CategoryChipState createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
  }

  void _toggleSelect() {
    setState(() {
      _isSelected = !_isSelected;
    });

    if (widget.onPressed != null) {
      widget.onPressed!(); // Chỉ gọi khi onPressed được truyền vào
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: _isSelected ? widget.color.withOpacity(0.3) : Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.color, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
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

class CategoryList extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final Function(String) onCategorySelected;

  const CategoryList({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CategoryChip(
                    label: category['label'],
                    color: category['color'],
                    onPressed: () => onCategorySelected(category['label']),
                  ),
                );
              }).toList(),
        ),
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
                color: isSelected ? Colors.deepPurpleAccent : Colors.grey,
                width: 2,
              ),
              color: isSelected ? Colors.deepPurpleAccent : Colors.transparent,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildPriorityButton("High", Colors.red),
        _buildPriorityButton("Medium", Colors.orange),
        _buildPriorityButton("Low", Colors.green),
      ],
    );
  }

  Widget _buildPriorityButton(String label, Color color) {
    bool isSelected = selectedPriority == label;
    return GestureDetector(
      onTap: () => selectPriority(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
          color: isSelected ? color : Colors.transparent,
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
