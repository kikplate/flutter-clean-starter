/// Domain entity for a user (JSONPlaceholder subset).
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
}
