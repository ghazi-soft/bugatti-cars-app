class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role; // 'user' or 'admin'
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  // تحويل من JSON إلى Object (يدعم كلا من Supabase و Go API)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseId(json['id']),
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
    );
  }

  // تحويل من Object إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // الاسم الكامل
  String get fullName => '$firstName $lastName'.trim();

  // هل هو أدمن؟
  bool get isAdmin => role == 'admin';

  // Helper لتحويل معرف المستخدم إلى int
  static int _parseId(dynamic id) {
    if (id is int) return id;
    if (id is String) return int.tryParse(id) ?? 0;
    return 0;
  }

  // Helper لتحويل التاريخ
  static DateTime _parseDateTime(dynamic date) {
    if (date is DateTime) return date;
    if (date is String && date.isNotEmpty) {
      return DateTime.tryParse(date) ?? DateTime.now();
    }
    return DateTime.now();
  }
}