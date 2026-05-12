import 'package:equatable/equatable.dart';

class Faq extends Equatable {
  final int id;
  final String? category;
  final String question;
  final String answer;
  final int sortOrder;

  const Faq({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [id, category, question, answer, sortOrder];
}
