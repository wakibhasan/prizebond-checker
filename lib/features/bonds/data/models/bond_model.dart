import '../../domain/entities/bond.dart';
import 'series_model.dart';

class BondModel extends Bond {
  const BondModel({
    required super.id,
    required super.series,
    required super.bondNumber,
    required super.createdAt,
  });

  factory BondModel.fromJson(Map<String, dynamic> json) {
    final rawSeries = json['series'];
    return BondModel(
      id: (json['id'] as num).toInt(),
      series: rawSeries is Map<String, dynamic>
          ? SeriesModel.fromJson(rawSeries)
          : null,
      bondNumber: json['bond_number'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
