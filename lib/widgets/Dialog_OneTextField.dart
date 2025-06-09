import 'package:flutter/material.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class OneTextFieldDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String buttonText;
  final String cancelText;
  final Function(String) onFunction;
  final AppColors colors;

  const OneTextFieldDialog({
    super.key,
    required this.onFunction,
    required this.colors,
    this.title = "Add Member",
    this.hintText = "Enter email",
    this.buttonText = "Add",
    this.cancelText = "Cancel",
  });

  @override
  State<OneTextFieldDialog> createState() => _OneTextFieldDialogState();
}

class _OneTextFieldDialogState extends State<OneTextFieldDialog> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.colors.itemBgColor,
      title: Text(
        widget.title,
        style: TextStyle(color: widget.colors.textColor),
      ),
      content: TextField(
        controller: emailController,
        style: TextStyle(color: widget.colors.textColor),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: widget.colors.textColor.withOpacity(0.6)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: widget.colors.textColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: widget.colors.textColor),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final email = emailController.text.trim();
            widget.onFunction(email);
          },
          child: Text(
            widget.buttonText,
            style: TextStyle(color: widget.colors.textColor),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            widget.cancelText,
            style: TextStyle(color: widget.colors.textColor),
          ),
        ),
      ],
    );
  }
}
