class ContactMessage {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String? subject;
  final String message;
  final DateTime createdAt;

  ContactMessage({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.subject,
    required this.message,
    required this.createdAt,
  });

  factory ContactMessage.fromJson(Map<String, dynamic> json) {
    return ContactMessage(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      subject: json['subject'],
      message: json['message'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'subject': subject,
      'message': message,
    };
  }
}
