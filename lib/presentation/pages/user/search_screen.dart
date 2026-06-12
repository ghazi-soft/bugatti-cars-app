import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/car_card.dart';
import '../../../widgets/custom_widgets.dart' as custom;

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carListAsync = ref.watch(carListProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: custom.SearchBar(
          controller: _searchController,
          onChanged: (value) => setState(() {}),
          hint: 'ابحث عن الماركة أو الموديل...',
        ),
      ),
      body: carListAsync.when(
        data: (cars) {
          final query = _searchController.text.toLowerCase();
          final results = query.isEmpty 
              ? [] 
              : cars.where((car) => 
                  car.brand.toLowerCase().contains(query) || 
                  car.model.toLowerCase().contains(query)
                ).toList();

          if (query.isEmpty) {
            return const custom.EmptyWidget(
              message: 'ابدأ البحث عن سيارتك المفضلة',
              icon: Icons.search,
            );
          }

          if (results.isEmpty) {
            return const custom.EmptyWidget(
              message: 'عذراً، لم نجد نتائج تطابق بحثك',
              icon: Icons.sentiment_dissatisfied,
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
            itemCount: results.length,
            itemBuilder: (context, index) {
              final car = results[index];
              return CarCard(
                imageUrl: car.imageUrls.isNotEmpty ? car.imageUrls.first : '',
                carName: car.brand,
                carModel: car.model,
                price: car.priceFormatted,
                isFavorite: favorites.contains(car.id),
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
