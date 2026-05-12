import 'package:equatable/equatable.dart';

class Series extends Equatable {
  final int id;
  final String codeBn;
  final String codeTranslit;

  const Series({
    required this.id,
    required this.codeBn,
    required this.codeTranslit,
  });

  @override
  List<Object?> get props => [id, codeBn, codeTranslit];
}
