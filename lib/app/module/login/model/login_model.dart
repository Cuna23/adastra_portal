class User {
  final int id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'user',
    );
  }
}

class AuthResponse {
  final bool success;
  final String? token;
  final String? role;
  final User? user;
  final String? message;

  AuthResponse({
    required this.success,
    this.token,
    this.role,
    this.user,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      token: json['token'],
      role: json['role'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      message: json['message'],
    );
  }
}