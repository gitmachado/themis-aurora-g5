import 'package:fpdart/fpdart.dart';

import 'failures.dart';

extension EitherFailureX<T> on Either<Failure, T> {
  T getOrThrow() {
    return match((failure) => throw failure, (value) => value);
  }
}
