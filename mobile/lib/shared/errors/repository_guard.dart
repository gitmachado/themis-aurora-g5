import 'package:fpdart/fpdart.dart';

import 'failure_mapper.dart';
import 'failures.dart';

Future<Either<Failure, T>> guardRepository<T>(
  Future<T> Function() action,
) async {
  try {
    return right(await action());
  } catch (error) {
    return left(mapExceptionToFailure(error));
  }
}

Future<Either<Failure, Unit>> guardRepositoryUnit(
  Future<void> Function() action,
) async {
  try {
    await action();
    return right(unit);
  } catch (error) {
    return left(mapExceptionToFailure(error));
  }
}
