// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class YesNoButton extends ConsumerWidget {
  final VoidCallback onPressed;
  final String yesNo;
  final Color background;
  const YesNoButton({
    super.key,
    required this.onPressed,
    required this.yesNo,
    required this.background,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 25,
      width: 120,
      child: OutlinedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          backgroundColor: background,
        ),
        child: Text(yesNo),
      ),
    );
  }
}
