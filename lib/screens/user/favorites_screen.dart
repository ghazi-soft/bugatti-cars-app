import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../models/car_model.dart';
import '../user/car_details_screen.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  List<Car> favoriteCars = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = ref.read(favoritesProvider);
    if (ids.isEmpty) {
      setState(() {
        favoriteCars = [];
        isLoading = false;
      });
      return;
    }

    try {
      final repo = ref.read(carRepositoryProvider);
      final cars = <Car>[];
      for (final id in ids) {
        try {
          cars.add(await repo.getCarById(id));
        } catch (_) {
          continue;
        }
      }
      setState(() {
        favoriteCars = cars;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        backgroundColor: const Color(0xFF0F172A),
      ),
      backgroundColor: const Color(0xFF111827),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? const Center(
                  child: Text(
                    'لم تضف سيارات مفضلة بعد.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favoriteCars.length,
                  itemBuilder: (context, index) {
                    final car = favoriteCars[index];
                    return Card(
                      color: const Color(0xFF1F2937),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarDetailsScreen(carId: car.id),
                            ),
                          );
                        },
                        leading: const Icon(Icons.favorite, color: Color(0xFFD4AF37)),
                        title: Text('${car.brand} ${car.model}', style: const TextStyle(color: Colors.white)),
                        subtitle: Text(car.priceFormatted, style: const TextStyle(color: Colors.white70)),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                          onPressed: () async {
                            await ref.read(favoritesProvider.notifier).toggleFavorite(car.id);
                            _loadFavorites();
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
