import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/next_draw.dart';

abstract class DrawsRepository {
  Future<Either<Failure, NextDraw>> getNextDraw();
}
