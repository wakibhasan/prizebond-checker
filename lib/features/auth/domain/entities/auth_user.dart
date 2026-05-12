import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? mobile;
  final int bondQuota;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.bondQuota,
  });

  bool get hasMobile => mobile != null && mobile!.isNotEmpty;

  AuthUser copyWith({
    int? id,
    String? name,
    String? email,
    String? mobile,
    int? bondQuota,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      bondQuota: bondQuota ?? this.bondQuota,
    );
  }

  @override
  List<Object?> get props => [id, name, email, mobile, bondQuota];
}
