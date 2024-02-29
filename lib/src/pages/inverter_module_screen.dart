// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/solar_controller.dart';

class InverterModuleScreen extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const InverterModuleScreen({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _InverterModelScreenState();
}

class _InverterModelScreenState extends ConsumerState<InverterModuleScreen> {
  final TextEditingController powerController = TextEditingController();

  late List<String> arguments;

  late bool validate = false;

  @override
  void initState() {
    arguments = [widget.applicationId, widget.component];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final component =
        ref.watch(getApplicationComponentStreamProvider(arguments));
    return component.when(
      data: (component) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              component.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Measures of determination',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    )),
                const SizedBox(height: 10),
                Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.builder(
                    itemCount: component.measurement.length,
                    itemBuilder: ((context, index) {
                      return SizedBox(
                          height: 30,
                          child: Text(component.measurement[index]));
                    }),
                  ),
                ),
                const SizedBox(height: 10),
                (component.isSelected == false)
                    ? const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'What is the energy output from the panels of choice?',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      )
                    : Container(),
                const SizedBox(height: 10),
                (component.isSelected == false)
                    ? TextField(
                        controller: powerController,
                        onSubmitted: (value) {
                          // calculatePanelCost();
                        },
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: InputDecoration(
                          hintText: 'Energy Output in W/m²',
                          hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6)),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.2),
                          errorText: validate ? "Value Can't Be Empty" : null,
                        ),
                      )
                    : Container(),
                const SizedBox(height: 40),
                OutlinedButton(
                    onPressed: () {
                      setState(() {
                        validate = powerController.text.isEmpty;
                      });
                      (validate == true) ? null : null;
                    },
                    child: const Text('Confirm Selection'))
              ],
            ),
          ),
        );
      },
      error: (error, stacktrace) => Text(error.toString()),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
