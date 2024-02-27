import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expandable/expandable.dart';

class ExpandableWidget extends ConsumerWidget {
  final Widget expandableWidget;
  const ExpandableWidget({required this.expandableWidget, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      child: ExpandablePanel(
        header: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Components checklist',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        collapsed: Container(),
        expanded: expandableWidget,
      ),
    );
  }
}
