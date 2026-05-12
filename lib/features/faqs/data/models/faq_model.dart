import '../../domain/entities/faq.dart';

class FaqModel extends Faq {
  const FaqModel({
    required super.id,
    required super.category,
    required super.question,
    required super.answer,
    required super.sortOrder,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: (json['id'] as num).toInt(),
      category: json['category'] as String?,
      question: json['question'] as String,
      answer: json['answer'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}
