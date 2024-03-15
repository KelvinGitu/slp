// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/prices.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class EarthRodAndCable extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const EarthRodAndCable({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EarthRodState();
}

class _EarthRodState extends ConsumerState<EarthRodAndCable> {
  final TextEditingController rodsController = TextEditingController();
  final TextEditingController cableController = TextEditingController();

  late List<String> arguments;

  bool validate = false;

  bool validate2 = false;

  @override
  void initState() {
    arguments = [widget.applicationId, widget.component];
    super.initState();
  }

  @override
  void dispose() {
    rodsController.dispose();
    cableController.dispose();
    super.dispose();
  }

  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
          widget.component,
          selected,
          widget.applicationId,
        );
  }

  void updateComponentCost(int cost) {
    ref.watch(solarControllerProvider).updateApplicationComponentCost(
          widget.component,
          cost,
          widget.applicationId,
        );
  }

  void updateApplicationQuotation() {
    ref.watch(solarControllerProvider).updateApplicationQuotation(
          widget.applicationId,
        );
  }

  void updateComponentLength(int length) {
    ref.watch(solarControllerProvider).updateApplicationComponentLength(
          widget.component,
          length * 2,
          widget.applicationId,
        );
  }

  void updateComponentQuanity(int quantity) {
    ref.watch(solarControllerProvider).updateApplicationComponentQuantity(
          widget.component,
          quantity,
          widget.applicationId,
        );
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: (component.isSelected == false)
                ? ListView(
                    children: [
                      // const Text(
                      //   'Measures of determination',
                      //   style: TextStyle(
                      //       fontSize: 16, fontWeight: FontWeight.w500),
                      // ),
                      // const SizedBox(height: 10),
                      // Container(
                      //   height: 100,
                      //   width: MediaQuery.of(context).size.width,
                      //   padding: const EdgeInsets.all(15),
                      //   decoration: BoxDecoration(
                      //     color: Colors.grey.withOpacity(0.3),
                      //     borderRadius: BorderRadius.circular(10),
                      //   ),
                      //   child: ListView.builder(
                      //     itemCount: component.measurement.length,
                      //     itemBuilder: ((context, index) {
                      //       return Text(component.measurement[index]);
                      //     }),
                      //   ),
                      // ),
                      // const SizedBox(height: 15),
                      const Text(
                        'How many earth rods does the installation require?',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: rodsController,
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: InputDecoration(
                          hintText: 'No. of rods',
                          hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6)),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.2),
                          errorText: validate ? "Value Can't Be Empty" : null,
                        ),
                      ),
                      const Text(
                        '*Price per unit = KES ${Prices.earthRod}',
                        style: TextStyle(fontSize: 10, color: Colors.red),
                      ),
                      
                      const SizedBox(height: 15),
                      const Text(
                        'Earthing also requires a 16mm\u00b2 earthing cable. Measure the diatance between panel and earth rod, or metre box if accessible',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: cableController,
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: InputDecoration(
                          hintText: 'Distance in metres',
                          hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6)),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.2),
                          errorText: validate2 ? "Value Can't Be Empty" : null,
                        ),
                      ),
                      const Text(
                        '*Price per metre = KES ${Prices.earthCable}',
                        style: TextStyle(fontSize: 10, color: Colors.red),
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConfirmSelectionButton(
                            onPressed: () {
                              setState(() {
                                validate = rodsController.text.isEmpty;
                                validate2 = cableController.text.isEmpty;
                              });
                              (validate == true || validate2 == true)
                                  ? null
                                  : updateComponentLength(
                                      int.parse(cableController.text));
                              (validate == true || validate2 == true)
                                  ? null
                                  : updateComponentQuanity(
                                      int.parse(rodsController.text));
                              (validate == true || validate2 == true)
                                  ? null
                                  : updateComponentCost(
                                      int.parse(rodsController.text) * Prices.earthRod +
                                          int.parse(cableController.text) * Prices.earthCable);
                              (validate == true || validate2 == true)
                                  ? null
                                  : updateSelectedStatus(true);
                              (validate == true || validate2 == true)
                                  ? null
                                  : updateApplicationQuotation();
                            },
                            message: 'Confirm Selection'),
                      )
                    ],
                  )
                : Column(
                    children: [
                      Container(),
                      Text(
                        'No of earth rods: ${component.quantity}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Length of 16mm\u00b2 earthing cable: ${component.length}m',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Total cost: KES ${component.cost}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConfirmSelectionButton(
                            onPressed: () {
                              updateComponentCost(0);
                              updateSelectedStatus(false);
                              updateComponentLength(0);
                              updateComponentQuanity(0);
                            },
                            message: 'Edit Selecction'),
                      )
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
