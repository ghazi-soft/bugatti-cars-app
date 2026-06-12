import 'package:bugatti_cars/models/car_model.dart';
import 'supabase_service.dart';

class CarService {
  final SupabaseService supabase = SupabaseService();

  // جلب جميع السيارات
  Future<List<Car>> getAllCars() async {
    try {
      final response = await supabase.get('cars?select=*');
      final List<Car> cars = [];

      for (var car in response) {
        cars.add(Car.fromJson(car));
      }

      return cars;
    } catch (e) {
      throw Exception('Get Cars Error: $e');
    }
  }

  // جلب السيارات المتاحة فقط
  Future<List<Car>> getAvailableCars() async {
    try {
      final response = await supabase.get('cars?is_sold=eq.false&select=*');
      final List<Car> cars = [];

      for (var car in response) {
        cars.add(Car.fromJson(car));
      }

      return cars;
    } catch (e) {
      throw Exception('Get Available Cars Error: $e');
    }
  }

  // جلب سيارة واحدة
  Future<Car> getCarById(int carId) async {
    try {
      final response = await supabase.get('cars?id=eq.$carId');
      return Car.fromJson(response[0]);
    } catch (e) {
      throw Exception('Get Car Error: $e');
    }
  }

  // إضافة سيارة جديدة (أدمن فقط)
  Future<void> addCar(
    String brand,
    String model,
    int year,
    double price,
    String? description,
  ) async {
    try {
      await supabase.post('cars', {
        'brand': brand,
        'model': model,
        'year': year,
        'price': price,
        'description': description,
        'is_sold': false,
      });
    } catch (e) {
      throw Exception('Add Car Error: $e');
    }
  }

  // تعديل سيارة (أدمن فقط)
  Future<void> updateCar(
    int carId,
    String brand,
    String model,
    int year,
    double price,
    String? description,
    bool isSold,
  ) async {
    try {
      await supabase.update(
        'cars',
        {
          'brand': brand,
          'model': model,
          'year': year,
          'price': price,
          'description': description,
          'is_sold': isSold,
        },
        'id=eq.$carId',
      );
    } catch (e) {
      throw Exception('Update Car Error: $e');
    }
  }

  // حذف سيارة (أدمن فقط)
  Future<void> deleteCar(int carId) async {
    try {
      await supabase.delete('cars', 'id=eq.$carId');
    } catch (e) {
      throw Exception('Delete Car Error: $e');
    }
  }

  // البحث عن سيارات
  Future<List<Car>> searchCars(String query) async {
    try {
      final response = await supabase
          .get('cars?or=(brand.ilike.%$query%,model.ilike.%$query%)');
      final List<Car> cars = [];

      for (var car in response) {
        cars.add(Car.fromJson(car));
      }

      return cars;
    } catch (e) {
      throw Exception('Search Error: $e');
    }
  }
}
