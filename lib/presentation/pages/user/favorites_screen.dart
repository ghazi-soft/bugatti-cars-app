import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/car_card.dart';
import '../../../widgets/custom_widgets.dart' as custom;

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final carListAsync = ref.watch(carListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
      ),
      body: carListAsync.when(
        data: (cars) {
          final favoriteCars = cars.where((car) => favorites.contains(car.id)).toList();

          if (favoriteCars.isEmpty) {
            return const custom.EmptyWidget(
              message: 'قائمة مفضلاتك فارغة حالياً',
              icon: Icons.favorite_border,
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: AppDimensions.spacingMedium,
              mainAxisSpacing: AppDimensions.spacingMedium,
            ),
            itemCount: favoriteCars.length,
            itemBuilder: (context, index) {
              final car = favoriteCars[index];
              return CarCard(
                imageUrl: car.imageUrls.isNotEmpty ? car.imageUrls.first : '',
                carName: car.brand,
                carModel: car.model,
                price: car.priceFormatted,
                isFavorite: true,
                onFavoriteToggle: () => ref.read(favoritesProvider.notifier).toggleFavorite(car.id),
                onTap: () => Navigator.pushNamed(context, AppRoutes.carDetails, arguments: car.id),
              );
            },
          );
        },
        loading: () => const custom.LoadingWidget(),
        error: (err, stack) => custom.ErrorWidget(error: err.toString()),
      ),
    );
  }
}
