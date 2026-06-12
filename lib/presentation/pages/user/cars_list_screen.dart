import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/car_card.dart';
import '../../../widgets/custom_widgets.dart' as custom;

class CarsListScreen extends ConsumerStatefulWidget {
  const CarsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CarsListScreen> createState() => _CarsListScreenState();
}

class _CarsListScreenState extends ConsumerState<CarsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedBrand = 'All';
  String _sortBy = 'Newest';

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
        title: const Text('أسطول السيارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: custom.SearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              hint: 'ابحث عن سيارة أحلامك...',
            ),
          ),
          Expanded(
            child: carListAsync.when(
              data: (cars) {
                final filteredCars = cars.where((car) {
                  final matchesSearch = car.fullName.toLowerCase().contains(_searchController.text.toLowerCase());
                  final matchesBrand = _selectedBrand == 'All' || car.brand == _selectedBrand;
                  return matchesSearch && matchesBrand;
                }).toList();

                if (filteredCars.isEmpty) {
                  return const custom.EmptyWidget(
                    message: 'لم نجد سيارات تطابق بحثك',
                    icon: Icons.search_off,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(carListProvider.notifier).refreshCars(),
                  color: AppColors.primary,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: AppDimensions.spacingMedium,
                      mainAxisSpacing: AppDimensions.spacingMedium,
                    ),
                    itemCount: filteredCars.length,
                    itemBuilder: (context, index) {
                      final car = filteredCars[index];
                      return CarCard(
                        imageUrl: car.imageUrls.isNotEmpty ? car.imageUrls.first : '',
                        carName: car.brand,
                        carModel: car.model,
                        price: car.priceFormatted,
                        isFavorite: favorites.contains(car.id),
                        onFavoriteToggle: () {
                          ref.read(favoritesProvider.notifier).toggleFavorite(car.id);
                        },
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.carDetails,
                            arguments: car.id,
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const custom.LoadingWidget(message: 'جاري تحميل الأسطول...'),
              error: (err, stack) => custom.ErrorWidget(
                error: err.toString(),
                onRetry: () => ref.read(carListProvider.notifier).refreshCars(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.dark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الفلاتر', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  Text('الماركة', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Bugatti', 'Tesla', 'BMW', 'Mercedes'].map((brand) {
                      final isSelected = _selectedBrand == brand;
                      return ChoiceChip(
                        label: Text(brand),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() => _selectedBrand = brand);
                          setState(() {});
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: isSelected ? AppColors.dark : AppColors.textPrimary),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  custom.CustomButton(
                    label: 'تطبيق الفلاتر',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
