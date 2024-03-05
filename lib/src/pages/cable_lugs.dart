// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/solar_controller.dart';

class CableLugs extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const CableLugs({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CableLugsState();
}

class _CableLugsState extends ConsumerState<CableLugs> {
  final TextEditingController cableLengthController = TextEditingController();
  final TextEditingController cable2LengthController = TextEditingController();
  final TextEditingController cable3LengthController = TextEditingController();

  late List<String> arguments;

  late List<String> batteryArguments;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // savePVCablesToApplication();
    });

    arguments = [widget.applicationId, widget.component];
    batteryArguments = [widget.applicationId, 'Batteries'];

    super.initState();
  }

  @override
  void dispose() {
    cableLengthController.dispose();
    cable2LengthController.dispose();
    cable3LengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final component =
        ref.watch(getApplicationComponentStreamProvider(arguments));
    // final batteryComponent =
    //     ref.watch(getApplicationComponentStreamProvider(batteryArguments));

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
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Measures of determination',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
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
                      const Text('Battery Cable Lugs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                      
                    ],
                  )
                : Container(),
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
