import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/faq.dart';

abstract class FaqsRepository {
  Future<Either<Failure, List<Faq>>> listFaqs();
}
