class Order {
  final int id;
  final int userId;
  final int carId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? notes;
  final double total;
  final String status; // 'pending', 'confirmed', 'completed'
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.carId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.notes,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  // تحويل من JSON إلى Object
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: _parseInt(json['id']),
      userId: _parseInt(json['userId'] ?? json['user_id']),
      carId: _parseInt(json['carId'] ?? json['car_id']),
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      notes: json['notes'],
      total: _parseDouble(json['total']),
      status: json['status'] ?? 'pending',
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
    );
  }

  // تحويل من Object إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'car_id': carId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'notes': notes,
      'total': total,
      'status': status,
    };
  }

  // الاسم الكامل
  String get fullName => '$firstName $lastName'.trim();

  // حالة الطلب بالعربي
  String get statusText {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'completed':
        return 'مكتمل';
      default:
        return status;
    }
  }

  // لون الحالة (ARGB)
  String get statusColor {
    switch (status) {
      case 'pending':
        return 'FFFF9800'; // Orange
      case 'confirmed':
        return 'FF2196F3'; // Blue
      case 'completed':
        return 'FF4CAF50'; // Green
      default:
        return 'FF9E9E9E'; // Grey
    }
  }

  // السعر بصيغة جميلة
  String get totalFormatted => '\$${total.toStringAsFixed(2)}';

  // Helpers
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date is DateTime) return date;
    if (date is String && date.isNotEmpty) {
      return DateTime.tryParse(date) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
