import '../../domain/entities/next_draw.dart';

class NextDrawModel extends NextDraw {
  const NextDrawModel({
    required super.drawNo,
    required super.drawDate,
    required super.banglaDateLabel,
    required super.daysUntil,
    required super.isEstimated,
  });

  factory NextDrawModel.fromJson(Map<String, dynamic> json) {
    return NextDrawModel(
      drawNo: (json['draw_no'] as num?)?.toInt(),
      drawDate: DateTime.parse(json['draw_date'] as String),
      banglaDateLabel: json['bangla_date_label'] as String?,
      daysUntil: (json['days_until'] as num).toInt(),
      isEstimated: json['is_estimated'] as bool? ?? true,
    );
  }
}
