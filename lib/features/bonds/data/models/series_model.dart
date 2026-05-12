import '../../domain/entities/series.dart';

class SeriesModel extends Series {
  const SeriesModel({
    required super.id,
    required super.codeBn,
    required super.codeTranslit,
  });

  factory SeriesModel.fromJson(Map<String, dynamic> json) {
    return SeriesModel(
      id: (json['id'] as num).toInt(),
      codeBn: json['code_bn'] as String,
      codeTranslit: json['code_translit'] as String,
    );
  }
}
