import '../../domain/entities/win.dart';

class WinModel extends Win {
  const WinModel({
    required super.id,
    required super.prizeRank,
    required super.prizeAmount,
    required super.bond,
    required super.draw,
    required super.claimWindowEndsAt,
    required super.notifiedAt,
    required super.createdAt,
  });

  factory WinModel.fromJson(Map<String, dynamic> json) {
    final bondJson = json['bond'];
    final drawJson = json['draw'];
    return WinModel(
      id: (json['id'] as num).toInt(),
      prizeRank: (json['prize_rank'] as num).toInt(),
      prizeAmount: (json['prize_amount'] as num).toInt(),
      bond: bondJson is Map<String, dynamic>
          ? WinBondInfo(
              id: (bondJson['id'] as num).toInt(),
              seriesCodeBn: bondJson['series_code_bn'] as String?,
              bondNumber: bondJson['bond_number'] as String,
            )
          : null,
      draw: drawJson is Map<String, dynamic>
          ? WinDrawInfo(
              no: (drawJson['no'] as num).toInt(),
              date: DateTime.parse(drawJson['date'] as String),
            )
          : null,
      claimWindowEndsAt: DateTime.parse(json['claim_window_ends_at'] as String),
      notifiedAt: json['notified_at'] != null
          ? DateTime.parse(json['notified_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
