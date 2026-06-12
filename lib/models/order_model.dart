class Order {
  final int id;
  final String userId;
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
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      carId: json['car_id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      notes: json['notes'],
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
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
  String get fullName => '$firstName $lastName';

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

  // لون الحالة
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
}
