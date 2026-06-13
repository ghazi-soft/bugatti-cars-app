import '../models/order_model.dart';
import '../repositories/supabase_repository.dart';
import '../services/validation_service.dart';

class OrderRepository {
  final supabase = SupabaseRepository.client;

  // ============================================================
  // CREATE ORDER - مع التحقق من البيانات
  // ============================================================
  
  Future<Order> createOrder({
    required int carId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required double total,
    String? notes,
  }) async {
    // ============ التحقق من البيانات ============
    
    final validationError = ValidationService.validateOrderRequest(
      carId,
      firstName,
      lastName,
      email,
      phone,
    );
    
    if (validationError != null) {
      throw Exception(validationError);
    }

    // تنظيف البيانات
    final cleanFirstName = ValidationService.sanitizeInput(firstName);
    final cleanLastName = ValidationService.sanitizeInput(lastName);
    final cleanEmail = email.toLowerCase().trim();
    final cleanPhone = phone.trim();
    final cleanNotes = notes != null ? ValidationService.sanitizeInput(notes) : null;

    // التحقق من السعر
    if (total < 0 || total > 100_000_000) {
      throw Exception('السعر غير صحيح');
    }

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('المستخدم غير مسجل دخول');
      }

      // محاولة الحصول على المستخدم من قاعدة البيانات
      final userData = await supabase
          .from('users')
          .select('id')
          .eq('id', user.id)
          .single();

      final userId = int.tryParse(userData['id'].toString()) ?? 0;

      final orderData = {
        'user_id': userId,
        'car_id': carId,
        'first_name': cleanFirstName,
        'last_name': cleanLastName,
        'email': cleanEmail,
        'phone': cleanPhone,
        'notes': cleanNotes,
        'total': total,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      final data = await supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      return Order.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('فشل إنشاء الطلب: $e');
    }
  }

  // ============================================================
  // GET USER ORDERS
  // ============================================================
  
  Future<List<Order>> getUserOrders(int userId) async {
    try {
      final data = await supabase
          .from('orders')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => Order.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception('فشل تحميل الطلبات: $e');
    }
  }

  // ============================================================
  // GET ALL ORDERS (Admin Only)
  // ============================================================
  
  Future<List<Order>> getAllOrders() async {
    try {
      final data = await supabase
          .from('orders')
          .select('*')
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => Order.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception('فشل تحميل الطلبات: $e');
    }
  }

  // ============================================================
  // GET ORDER BY ID
  // ============================================================
  
  Future<Order> getOrderById(int orderId) async {
    try {
      final data = await supabase
          .from('orders')
          .select('*')
          .eq('id', orderId)
          .single();

      return Order.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('فشل تحميل الطلب: $e');
    }
  }

  // ============================================================
  // UPDATE ORDER STATUS (Admin Only)
  // ============================================================
  
  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      // التحقق من أن الحالة صحيحة
      const validStatuses = ['pending', 'confirmed', 'completed'];
      if (!validStatuses.contains(status)) {
        throw Exception('حالة طلب غير صحيحة');
      }

      await supabase
          .from('orders')
          .update({'status': status})
          .eq('id', orderId);
    } catch (e) {
      throw Exception('فشل تحديث الطلب: $e');
    }
  }

  // ============================================================
  // DELETE ORDER (Admin Only)
  // ============================================================
  
  Future<void> deleteOrder(int orderId) async {
    try {
      await supabase
          .from('orders')
          .delete()
          .eq('id', orderId);
    } catch (e) {
      throw Exception('فشل حذف الطلب: $e');
    }
  }

  // ============================================================
  // GET ORDERS BY STATUS
  // ============================================================
  
  Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      const validStatuses = ['pending', 'confirmed', 'completed'];
      if (!validStatuses.contains(status)) {
        throw Exception('حالة طلب غير صحيحة');
      }

      final data = await supabase
          .from('orders')
          .select('*')
          .eq('status', status)
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => Order.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception('فشل تحميل الطلبات: $e');
    }
  }

  // ============================================================
  // COUNT ORDERS BY STATUS
  // ============================================================
  
  Future<int> countOrdersByStatus(String status) async {
    try {
      const validStatuses = ['pending', 'confirmed', 'completed'];
      if (!validStatuses.contains(status)) {
        throw Exception('حالة طلب غير صحيحة');
      }

      final response = await supabase
          .from('orders')
          .select('*', const FetchOptions(count: CountOption.exact))
          .eq('status', status);

      return response.count;
    } catch (e) {
      return 0;
    }
  }
}