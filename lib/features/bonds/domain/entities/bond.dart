import 'package:equatable/equatable.dart';

import 'series.dart';

class Bond extends Equatable {
  final int id;

  /// Optional — admins may backfill the series later from the
  /// bond_number → series mapping. User-submitted bonds always
  /// land here with `series == null`.
  final Series? series;

  final String bondNumber;
  final DateTime? createdAt;

  const Bond({
    required this.id,
    required this.series,
    required this.bondNumber,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, series, bondNumber, createdAt];
}
