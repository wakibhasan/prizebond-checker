import 'package:equatable/equatable.dart';

class Win extends Equatable {
  final int id;
  final int prizeRank;
  final int prizeAmount;
  final WinBondInfo? bond;
  final WinDrawInfo? draw;
  final DateTime claimWindowEndsAt;
  final DateTime? notifiedAt;
  final DateTime? createdAt;

  const Win({
    required this.id,
    required this.prizeRank,
    required this.prizeAmount,
    required this.bond,
    required this.draw,
    required this.claimWindowEndsAt,
    required this.notifiedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        prizeRank,
        prizeAmount,
        bond,
        draw,
        claimWindowEndsAt,
        notifiedAt,
        createdAt,
      ];
}

class WinBondInfo extends Equatable {
  final int id;
  final String? seriesCodeBn;
  final String bondNumber;

  const WinBondInfo({
    required this.id,
    required this.seriesCodeBn,
    required this.bondNumber,
  });

  @override
  List<Object?> get props => [id, seriesCodeBn, bondNumber];
}

class WinDrawInfo extends Equatable {
  final int no;
  final DateTime date;

  const WinDrawInfo({required this.no, required this.date});

  @override
  List<Object?> get props => [no, date];
}
