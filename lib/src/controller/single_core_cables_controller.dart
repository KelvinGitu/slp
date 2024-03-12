import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/repository/single_core_cables_repository.dart';

final singleCoreCablesControllerProvider = Provider(
  (ref) => SingleCoreCablesController(
    singleCoreCablesRepository: ref.watch(singleCoreCablesRepositoryProvider),
  ),
);

class SingleCoreCablesController {
  final SingleCoreCablesRepository _singleCoreCablesRepository;

  SingleCoreCablesController(
      {required SingleCoreCablesRepository singleCoreCablesRepository})
      : _singleCoreCablesRepository = singleCoreCablesRepository;
}
