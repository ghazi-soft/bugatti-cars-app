import '../models/order_model.dart';
import '../repositories/supabase_repository.dart';

class OrderRepository {
  final supabase = SupabaseRepository.client;

  // ---------------- CREATE ORDER ----------------
  Future<Order> createOrder(Order order) async {
    try {
      final data = await supabase
          .from('orders')
          .insert(order.toJson())
          .select()
          .single();

      return Order.fromJson(
        Map<String, dynamic>.from(data),
      );
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // ---------------- USER ORDERS ----------------
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final data = await supabase
          .from('orders')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => Order.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to load user orders: $e');
    }
  }

  // ---------------- ALL ORDERS ----------------
  Future<List<Order>> getAllOrders() async {
    try {
      final data = await supabase
          .from('orders')
          .select('*')
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => Order.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  // ---------------- UPDATE STATUS ----------------
  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      await supabase
          .from('orders')
          .update({'status': status})
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  // ---------------- DELETE ORDER ----------------
  Future<void> deleteOrder(int orderId) async {
    try {
      await supabase
          .from('orders')
          .delete()
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }
}