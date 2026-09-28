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
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(component.name,
                    textAlign: (component.name.length >= 20)
                        ? TextAlign.left
                        : TextAlign.start)),
            (component.isSelected == true && component.isRequired == true)
                ? const Text(
                    'Done',
                    style: TextStyle(color: Colors.orange),
                  )
                : (component.isRequired == false)
                    ? const Text(
                        'NR',
                        style: TextStyle(color: Colors.purple),
                      )
                    : Container(),
          ],
        ),
      ),
    );
  }
}
