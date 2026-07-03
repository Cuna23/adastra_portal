class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final int? departmentId;
  final String? departmentName;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.departmentId,
    this.departmentName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      status: json['status'],
      departmentId: json['department_id'] ?? json['department']?['id'],
      departmentName: json['department']?['department_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'department_id': departmentId,
    };
  }
}