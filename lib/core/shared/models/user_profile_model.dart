import 'package:equatable/equatable.dart';

/// نموذج بيانات المستخدم في شاشة الإعدادات (User Profile Model)
class UserProfileModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl];
}

