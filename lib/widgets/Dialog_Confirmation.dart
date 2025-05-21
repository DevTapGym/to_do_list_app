import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [TextButton(
          child: Text(confirmText),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
        ),
        TextButton(
          child: Text(cancelText),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        
      ],
    );
  }
}
