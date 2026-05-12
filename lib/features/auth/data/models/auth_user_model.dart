import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.mobile,
    required super.bondQuota,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      mobile: json['mobile'] as String?,
      bondQuota: (json['bond_quota'] as num?)?.toInt() ?? 5,
    );
  }
}
