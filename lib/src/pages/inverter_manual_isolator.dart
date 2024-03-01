// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/solar_controller.dart';

class InverterManualIsolator extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const InverterManualIsolator({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _InverterManualIsolatorState();
}

class _InverterManualIsolatorState
    extends ConsumerState<InverterManualIsolator> {
  final TextEditingController ratingController = TextEditingController();

  late List<String> arguments;

  bool validate = false;

  bool showRating = false;

  bool ratingSelected = false;

  @override
  void initState() {
    arguments = [widget.applicationId, widget.component];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      saveIsolatorsToApplication();
    });
    super.initState();
  }

  void saveIsolatorsToApplication() {
    ref.watch(solarControllerProvider).saveIsolatorSwitchToApplication(
          applicationId: widget.applicationId,
          component: widget.component,
        );
  }

  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationSelectedStatus(
          widget.component,
          selected,
          widget.applicationId,
        );
  }

  void updateComponentCost(int cost) {
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

  void updateComponentCapacity(int capacity) {
    ref.watch(solarControllerProvider).updateComponentCapacity(
          widget.component,
          capacity,
          widget.applicationId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final component =
        ref.watch(getApplicationComponentStreamProvider(arguments));
    final isolatorSwitch =
        ref.watch(getIsolatorSwitchStreamProvider(arguments));
    return component.when(
      data: (component) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              component.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          body: (component.isSelected == false)
              ? ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Measures of determination',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
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
                          return Text(component.measurement[index]);
                        }),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'What is the solar panel rating?',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ratingController,
                      onChanged: (value) {
                        setState(() {
                          showRating = true;
                          ratingSelected = false;
                        });
                      },
                      keyboardType: const TextInputType.numberWithOptions(),
                      decoration: InputDecoration(
                        hintText: 'Rating in KVA',
                        hintStyle: TextStyle(
                            fontSize: 14, color: Colors.black.withOpacity(0.6)),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.2),
                        errorText: validate ? "Value Can't Be Empty" : null,
                      ),
                    ),
                    (showRating == true &&
                            ratingController.text.isEmpty == false &&
                            ratingSelected == false)
                        ? isolatorSwitch.when(
                            data: (isolatorSwitch) {
                              return SizedBox(
                                height: 200,
                                child: Column(
                                  children: [
                                    const Text(
                                      'Recommended switches',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 10),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 40),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Rating',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w300),
                                          ),
                                          Text(
                                            'Cost (KES)',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w300),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40),
                                        itemCount: isolatorSwitch.length,
                                        itemBuilder: (context, index) {
                                          final isolator =
                                              isolatorSwitch[index];
                                          final num =
                                              int.parse(ratingController.text);
                                          return (isolator.rating >= num)
                                              ? InkWell(
                                                  onTap: () {
                                                    updateComponentCapacity(
                                                        isolator.rating);
                                                    updateComponentCost(
                                                        isolator.cost);
                                                    setState(() {
                                                      ratingSelected = true;
                                                    });
                                                  },
                                                  child: SizedBox(
                                                    height: 30,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "${isolator.rating}A",
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        Text(isolator.cost
                                                            .toString()),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            error: (error, stacktrace) =>
                                Text(error.toString()),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : (ratingSelected == true)
                            ? Text(
                                'Preffered capacity: ${component.capacity}Ah',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              )
                            : Container(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            validate = ratingController.text.isEmpty;
                          });
                          (validate == true) ? null : updateSelectedStatus(true);
                      
                          (validate == true)
                              ? null
                              : updateApplicationQuotation();
                        },
                        child: const Text('Confirm Selection'),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(),
                      Text(
                        'The switch selected has a rating of : ${component.capacity}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Total cost: KES ${component.cost}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 15),
                      OutlinedButton(
                          onPressed: () {
                            updateSelectedStatus(false);
                          },
                          child: const Text('Edit selection'))
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
