// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/solar_controller.dart';

class PanelScreen extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const PanelScreen({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PanelScreenState();
}

class _PanelScreenState extends ConsumerState<PanelScreen> {
  final TextEditingController panelsController = TextEditingController();

  late List<String> arguments;

  bool validate = false;

  @override
  void initState() {
    arguments = [widget.applicationId, widget.component];
    super.initState();
  }

  @override
  void dispose() {
    panelsController.dispose();
    super.dispose();
  }

  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationSelectedStatus(
          widget.component,
          selected,
          widget.applicationId,
        );
  }

  void updateComponentCost() {
    int cost = int.parse(panelsController.text) * 10000;
    ref.watch(solarControllerProvider).updateComponentCost(
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

  void updateComponentQuantity() {
    ref.watch(solarControllerProvider).updateComponentQuantity(
          widget.component,
          int.parse(panelsController.text),
          widget.applicationId,
        );
  }

  void updateApplicationComponentsCostListRemove(int componentCost) {
    ref
        .watch(solarControllerProvider)
        .updateApplicationComponentsCostListRemove(
            widget.applicationId, componentCost);
  }

  void updateApplicationComponentsCostListAdd(int componentCost) {
    ref.watch(solarControllerProvider).updateApplicationComponentsCostListAdd(
        widget.applicationId, componentCost);
  }

  int cost = 0;

  Future<int> calculatePanelCost() async {
    cost = int.parse(panelsController.text) * 10000;
    return cost;
  }

  @override
  Widget build(BuildContext context) {
    final panelComponent =
        ref.watch(getApplicationComponentStreamProvider(arguments));
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panels',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: panelComponent.when(
        data: (panel) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: 
            Column(
              children: [
                (panel.isSelected == false)?
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Measures of determination',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ): Container(),
                const SizedBox(height: 10),
                (panel.isSelected == false)?
                Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.builder(
                    itemCount: panel.measurement.length,
                    itemBuilder: ((context, index) {
                      return Text(panel.measurement[index]);
                    }),
                  ),
                ): Container(),
                const SizedBox(height: 10),
                (panel.isSelected == false)
                    ? const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'How many panels does the client want?',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      )
                    : Container(),
                const SizedBox(height: 10),
                (panel.isSelected == false)
                    ? TextField(
                        controller: panelsController,
                        onSubmitted: (value) {
                          calculatePanelCost();
                        },
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: InputDecoration(
                          hintText: 'No. of panels',
                          hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6)),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.2),
                          errorText: validate ? "Value Can't Be Empty" : null,
                        ),
                      )
                    : Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'No of panels chosen: ${panel.quantity}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                (panel.isSelected == false)
                    ? const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '*approximate price: 1 panel = KES 10,000',
                          style: TextStyle(fontSize: 10, color: Colors.orange),
                        ))
                    : Container(),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Approximate cost: KES ${panel.cost}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 20),
                (panel.isSelected == false)
                    ? OutlinedButton(
                        onPressed: () {
                          setState(() {
                            validate = panelsController.text.isEmpty;
                          });
                          (validate == true) ? null : updateComponentCost();
                          (validate == true) ? null : updateComponentQuantity();
                          (validate == true)
                              ? null
                              : updateSelectedStatus(true);
                          (validate == true)
                              ? null
                              : updateApplicationQuotation();
                        },
                        child: const Text('Confirm selection'),
                      )
                    : Column(
                      children: [
                        OutlinedButton(
                            onPressed: () {
                              updateSelectedStatus(false);
                            },
                            child: const Text('Edit selection'),
                          ),
                          const SizedBox(height: 10),
                           const Text('* Any changes made here must also be made for the MC4 connecctors', style: TextStyle(fontSize: 10, color: Colors.red,),)
                      ],
                    ),
              ],
            ),
          );
        },
        error: (error, stacktrace) => Text(error.toString()),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
