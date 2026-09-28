import 'package:fpdart/fpdart.dart';
import 'package:solartide/core/error/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
