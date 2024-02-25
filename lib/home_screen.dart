import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/controller/solar_controller.dart';
import 'package:solar_project/pages/panel_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allComponents = ref.watch(getAllComponentsStreamProvider);

    return Scaffold(
      appBar: AppBar(),
      body: allComponents.when(
        data: (allComponents) {
          return ListView(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) {
                        return PanelScreen(component: allComponents[0].name);
                      }),
                    ),
                  );
                },
                child: SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(allComponents[0].name),
                      (allComponents[0].isSelected == true)
                          ? const Text('Yes')
                          : Container(),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) {
                        return PanelScreen(component: allComponents[1].name);
                      }),
                    ),
                  );
                },
                child: SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(allComponents[1].name),
                      (allComponents[1].isSelected == true)
                          ? const Text('Yes')
                          : Container(),
                    ],
                  ),
                ),
              ),
            ],
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
