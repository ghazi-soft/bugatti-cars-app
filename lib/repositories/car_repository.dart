import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_model.dart';
import '../repositories/supabase_repository.dart';
import '../services/validation_service.dart';

class CarRepository {
  final supabase = SupabaseRepository.client;

  // ============================================================
  // GET ALL CARS
  // ============================================================
  
  Future<List<Car>> getAllCars({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final data = await supabase
          .from('cars')
          .select('*')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final cars = (data as List)
          .map((e) => Car.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      await _cacheCars(cars);
      return cars;
    } catch (e) {
      return await getCachedCars();
    }
  }

  // ============================================================
  // SEARCH CARS
  // ============================================================
  
  Future<List<Car>> searchCars(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final cleanQuery = ValidationService.sanitizeInput(query);
      
      final data = await supabase
          .from('cars')
          .select('*')
          .or('brand.ilike.%$cleanQuery%,model.ilike.%$cleanQuery%')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (data as List)
          .map((e) => Car.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return await getCachedCars();
    }
  }

  // ============================================================
  // GET CAR BY ID
  // ============================================================
  
  Future<Car> getCarById(int carId) async {
    try {
      if (carId <= 0) {
        throw Exception('معرف السيارة غير صحيح');
      }

      final data = await supabase
          .from('cars')
          .select('*')
          .eq('id', carId)
          .single();

      return Car.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('فشل تحميل السيارة: $e');
    }
  }

  // ============================================================
  // CREATE CAR (Admin Only)
  // ============================================================
  
  Future<Car> createCar({
    required String brand,
    required String model,
    required int year,
    required double price,
    required String description,
  }) async {
    // ============ التحقق من البيانات (نفس قواعس Go) ============
    
    final cleanBrand = ValidationService.sanitizeInput(brand);
    final cleanModel = ValidationService.sanitizeInput(model);
    final cleanDescription = ValidationService.sanitizeInput(description);

    // التحقق من الماركة
    final brandError = ValidationService.validateCarName(cleanBrand, 'الماركة');
    if (brandError != null) throw Exception(brandError);

    // التحقق من الموديل
    final modelError = ValidationService.validateCarName(cleanModel, 'الموديل');
    if (modelError != null) throw Exception(modelError);

    // التحقق من السنة
    final yearError = ValidationService.validateCarYear(year);
    if (yearError != null) throw Exception(yearError);

    // التحقق من السعر
    final priceError = ValidationService.validateCarPrice(price);
    if (priceError != null) throw Exception(priceError);

    // التحقق من الوصف
    final descError = ValidationService.validateCarDescription(cleanDescription);
    if (descError != null) throw Exception(descError);

    try {
      final data = await supabase
          .from('cars')
          .insert({
            'brand': cleanBrand,
            'model': cleanModel,
            'year': year,
            'price': price,
            'description': cleanDescription,
            'is_sold': false,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Car.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('فشل إضافة السيارة: $e');
    }
  }

  // ============================================================
  // UPDATE CAR (Admin Only)
  // ============================================================
  
  Future<Car> updateCar({
    required int id,
    required String brand,
    required String model,
    required int year,
    required double price,
    required String description,
    required bool isSold,
  }) async {
    // ============ التحقق من البيانات (نفس قواعس Go) ============
    
    if (id <= 0) {
      throw Exception('معرف السيارة غير صحيح');
    }

    final cleanBrand = ValidationService.sanitizeInput(brand);
    final cleanModel = ValidationService.sanitizeInput(model);
    final cleanDescription = ValidationService.sanitizeInput(description);

    // التحقق من الماركة
    final brandError = ValidationService.validateCarName(cleanBrand, 'الماركة');
    if (brandError != null) throw Exception(brandError);

    // التحقق من الموديل
    final modelError = ValidationService.validateCarName(cleanModel, 'الموديل');
    if (modelError != null) throw Exception(modelError);

    // التحقق من السنة
    final yearError = ValidationService.validateCarYear(year);
    if (yearError != null) throw Exception(yearError);

    // التحقق من السعر
    final priceError = ValidationService.validateCarPrice(price);
    if (priceError != null) throw Exception(priceError);

    // التحقق من الوصف
    final descError = ValidationService.validateCarDescription(cleanDescription);
    if (descError != null) throw Exception(descError);

    try {
      final data = await supabase
          .from('cars')
          .update({
            'brand': cleanBrand,
            'model': cleanModel,
            'year': year,
            'price': price,
            'description': cleanDescription,
            'is_sold': isSold,
          })
          .eq('id', id)
          .select()
          .single();

      return Car.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('فشل تحديث السيارة: $e');
    }
  }

  // ============================================================
  // DELETE CAR (Admin Only)
  // ============================================================
  
  Future<void> deleteCar(int carId) async {
    try {
      if (carId <= 0) {
        throw Exception('معرف السيارة غير صحيح');
      }

      // حذف الصور أولاً
      await supabase
          .from('car_images')
          .delete()
          .eq('car_id', carId);

      // ثم حذف السيارة
      await supabase
          .from('cars')
          .delete()
          .eq('id', carId);
    } catch (e) {
      throw Exception('فشل حذف السيارة: $e');
    }
  }

  // ============================================================
  // ADD CAR IMAGE (Admin Only)
  // ============================================================
  
  Future<void> addCarImage(int carId, String imageUrl) async {
    try {
      if (carId <= 0) {
        throw Exception('معرف السيارة غير صحيح');
      }

      if (imageUrl.isEmpty) {
        throw Exception('رابط الصورة مطلوب');
      }

      // التحقق من أن السيارة موجودة
      await getCarById(carId);

      await supabase
          .from('car_images')
          .insert({
            'car_id': carId,
            'image_url': imageUrl,
            'created_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('فشل إضافة الصورة: $e');
    }
  }

  // ============================================================
  // DELETE CAR IMAGE (Admin Only)
  // ============================================================
  
  Future<void> deleteCarImage(int imageId) async {
    try {
      if (imageId <= 0) {
        throw Exception('معرف الصورة غير صحيح');
      }

      await supabase
          .from('car_images')
          .delete()
          .eq('id', imageId);
    } catch (e) {
      throw Exception('فشل حذف الصورة: $e');
    }
  }

  // ============================================================
  // CACHED CARS
  // ============================================================
  
  Future<List<Car>> getCachedCars() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final carsJson = prefs.getString('cached_cars');
      if (carsJson == null) return [];

      final List<dynamic> decoded = jsonDecode(carsJson);
      return decoded
          .map((e) => Car.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _cacheCars(List<Car> cars) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final carsJson = jsonEncode(cars.map((c) => c.toJson()).toList());
      await prefs.setString('cached_cars', carsJson);
    } catch (e) {
      // تجاهل الأخطاء في التخزين المؤقت
    }
  }
}
  }

  // ---------------- CACHE ----------------
  Future<List<Car>> getCachedCars() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString('cached_cars');
    if (raw == null || raw.isEmpty) return [];

    final data = jsonDecode(raw) as List;

    return data
        .map((e) => Car.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> _cacheCars(List<Car> cars) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'cached_cars',
      jsonEncode(cars.map((e) => e.toJson()).toList()),
    );
  }
}