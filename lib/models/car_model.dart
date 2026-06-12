class Car {
  final int id;
  final String brand;
  final String model;
  final int year;
  final double price;
  final String? description;
  final bool isSold;
  final String fuel;
  final String transmission;
  final int kilometers;
  final String color;
  final String location;
  final DateTime createdAt;
  final List<String> imageUrls;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    this.description,
    required this.isSold,
    required this.fuel,
    required this.transmission,
    required this.kilometers,
    required this.color,
    required this.location,
    required this.createdAt,
    this.imageUrls = const [],
  });

  // تحويل من JSON إلى Object
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] ?? 0,
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'],
      isSold: json['is_sold'] ?? false,
      fuel: json['fuel'] ?? 'Unknown',
      transmission: json['transmission'] ?? 'Unknown',
      kilometers: json['kilometers'] ?? 0,
      color: json['color'] ?? 'Unknown',
      location: json['location'] ?? 'Unknown',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : [],
    );
  }

  // تحويل من Object إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'description': description,
      'is_sold': isSold,
      'fuel': fuel,
      'transmission': transmission,
      'kilometers': kilometers,
      'color': color,
      'location': location,
      'image_urls': imageUrls,
    };
  }

  // اسم السيارة الكامل
  String get fullName => '$brand $model';

  // حالة البيع
  String get statusText => isSold ? 'مباعة' : 'متاحة';

  // السعر بصيغة جميلة
  String get priceFormatted => '\$${price.toStringAsFixed(2)}';
}
