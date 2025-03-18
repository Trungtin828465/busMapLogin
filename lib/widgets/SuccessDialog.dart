import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String message;

  const SuccessDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text('Success', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Đóng hộp thoại
          },
          child: const Text('OK', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
