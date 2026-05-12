import 'package:equatable/equatable.dart';

class NextDraw extends Equatable {
  final int? drawNo;
  final DateTime drawDate;
  final String? banglaDateLabel;
  final int daysUntil;
  final bool isEstimated;

  const NextDraw({
    required this.drawNo,
    required this.drawDate,
    required this.banglaDateLabel,
    required this.daysUntil,
    required this.isEstimated,
  });

  @override
  List<Object?> get props =>
      [drawNo, drawDate, banglaDateLabel, daysUntil, isEstimated];
}
