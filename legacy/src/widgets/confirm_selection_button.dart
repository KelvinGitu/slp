// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ConfirmSelectionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String message;
  const ConfirmSelectionButton({
    Key? key,
    required this.onPressed,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 35,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(message),
      ),
    );
  }
}
