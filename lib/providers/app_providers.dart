import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/car_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/chat_message_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/car_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/chat_repository.dart';
import '../repositories/contact_repository.dart';
import '../repositories/user_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final carRepositoryProvider = Provider<CarRepository>((ref) => CarRepository());
final orderRepositoryProvider = Provider<OrderRepository>((ref) => OrderRepository());
final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository());
final contactRepositoryProvider = Provider<ContactRepository>((ref) => ContactRepository());
final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());

// ---------------- USER ----------------

final userProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<User?>>(
  (ref) => UserNotifier(ref),
);

class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  UserNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadUser();
  }

  final Ref ref;

  Future<void> loadUser() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await loadUser();
  }
}

// ---------------- CARS ----------------

final carListProvider =
    StateNotifierProvider<CarListNotifier, AsyncValue<List<Car>>>(
  (ref) => CarListNotifier(ref),
);

class CarListNotifier extends StateNotifier<AsyncValue<List<Car>>> {
  CarListNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadCars();
  }

  final Ref ref;

  int _page = 0;
  final int _pageSize = 12;
  bool _hasMore = true;

  Future<void> loadCars({bool refresh = false}) async {
    if (refresh) {
      _page = 0;
      _hasMore = true;
      state = const AsyncValue.loading();
    }

    if (!_hasMore) return;

    try {
      final repository = ref.read(carRepositoryProvider);

      final cars = await repository.getAllCars(
        limit: _pageSize,
        offset: _page * _pageSize,
      );

      _page++;

      if (cars.length < _pageSize) {
        _hasMore = false;
      }

      final current = state.value ?? <Car>[];
      state = AsyncValue.data([...current, ...cars]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshCars() async {
    _page = 0;
    _hasMore = true;
    state = const AsyncValue.loading();
    await loadCars(refresh: true);
  }
}

// ---------------- ORDERS ----------------

final orderListProvider =
    StateNotifierProvider<OrderListNotifier, AsyncValue<List<Order>>>(
  (ref) => OrderListNotifier(ref),
);

class OrderListNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  OrderListNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadOrders();
  }

  final Ref ref;

  Future<void> loadOrders() async {
    try {
      final user = ref.read(userProvider).value;

      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final repository = ref.read(orderRepositoryProvider);

      List<Order> orders;

      if (user.isAdmin) {
        orders = await repository.getAllOrders();
      } else {
        orders = await repository.getUserOrders(user.id);
      }

      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshOrders() async {
    state = const AsyncValue.loading();
    await loadOrders();
  }
}

// ---------------- CHAT ----------------

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, AsyncValue<List<ChatMessage>>>(
  (ref) => ChatMessagesNotifier(ref),
);

class ChatMessagesNotifier
    extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  ChatMessagesNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;

  Stream<List<ChatMessage>>? _stream;

  Future<void> loadMessages({int? orderId}) async {
    try {
      state = const AsyncValue.loading();

      final repository = ref.read(chatRepositoryProvider);
      final messages = await repository.getMessages(orderId: orderId);

      state = AsyncValue.data(messages);

      _subscribe(orderId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _subscribe(int? orderId) {
    final repository = ref.read(chatRepositoryProvider);

    _stream?.drain();

    _stream = repository.streamMessages(orderId: orderId);

    _stream!.listen((messages) {
      state = AsyncValue.data(messages);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// ---------------- FAVORITES ----------------

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<int>>(
  (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<List<int>> {
  FavoritesNotifier() : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString('favorite_car_ids');

    if (raw != null) {
      final ids = (jsonDecode(raw) as List)
          .map((e) => e as int)
          .toList();

      state = ids;
    }
  }

  Future<void> toggleFavorite(int carId) async {
    final updated = [...state];

    if (updated.contains(carId)) {
      updated.remove(carId);
    } else {
      updated.add(carId);
    }

    state = updated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorite_car_ids', jsonEncode(state));
  }
}