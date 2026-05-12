import 'package:dartz/dartz.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/faq.dart';
import '../../domain/repositories/faqs_repository.dart';
import '../datasources/faqs_remote_datasource.dart';

class FaqsRepositoryImpl implements FaqsRepository {
  final FaqsRemoteDataSource _remote;
  FaqsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Faq>>> listFaqs() async {
    try {
      final faqs = await _remote.listFaqs();
      return Right(faqs);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
