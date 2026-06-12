import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_model.dart';
import '../repositories/supabase_repository.dart';

class CarRepository {
  final supabase = SupabaseRepository.client;

  // ---------------- GET ALL CARS ----------------
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

  // ---------------- SEARCH CARS ----------------
  Future<List<Car>> searchCars(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final data = await supabase
          .from('cars')
          .select('*')
          .or('brand.ilike.%$query%,model.ilike.%$query%')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (data as List)
          .map((e) => Car.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return await getCachedCars();
    }
  }

  // ---------------- GET CAR BY ID ----------------
  Future<Car> getCarById(int carId) async {
    try {
      final data = await supabase
          .from('cars')
          .select('*')
          .eq('id', carId)
          .single();

      return Car.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('Failed to fetch car: $e');
    }
  }

  // ---------------- ADD CAR ----------------
  Future<void> addCar(Car car) async {
    try {
      await supabase.from('cars').insert(car.toJson());
    } catch (e) {
      throw Exception('Failed to add car: $e');
    }
  }

  // ---------------- UPDATE CAR ----------------
  Future<void> updateCar(Car car) async {
    try {
      await supabase
          .from('cars')
          .update(car.toJson())
          .eq('id', car.id);
    } catch (e) {
      throw Exception('Failed to update car: $e');
    }
  }

  // ---------------- DELETE CAR ----------------
  Future<void> deleteCar(int carId) async {
    try {
      await supabase
          .from('cars')
          .delete()
          .eq('id', carId);
    } catch (e) {
      throw Exception('Failed to delete car: $e');
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