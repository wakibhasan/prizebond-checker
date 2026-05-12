import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/win.dart';

abstract class WinsRepository {
  Future<Either<Failure, List<Win>>> listWins();
}
