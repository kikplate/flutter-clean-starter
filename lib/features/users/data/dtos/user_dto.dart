import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_dto.g.dart';

@JsonSerializable(createToJson: false)
class UserDto {
  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

  User toEntity() => User(
        id: id,
        name: name,
        email: email,
        phone: phone,
      );
}
