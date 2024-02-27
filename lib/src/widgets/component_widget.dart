// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:solar_project/models/components_model.dart';

class ComponentWidget extends StatelessWidget {
  final ComponentsModel component;
  final Widget navigate;
  const ComponentWidget({
    Key? key,
    required this.component,
    required this.navigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) {
              return navigate;
            }),
          ),
        );
      },
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(component.name),
            (component.isSelected == true) ? const Text('Yes') : Container(),
          ],
        ),
      ),
    );
  }
}
