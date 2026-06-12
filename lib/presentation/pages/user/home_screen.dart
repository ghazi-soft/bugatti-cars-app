import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/custom_widgets.dart' as custom;
import '../../../widgets/glass_container.dart';
import '../../../widgets/car_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final carListAsync = ref.watch(carListProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        elevation: 0,
        title: Text(
          'Bugatti Cars',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.primary),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          ),
        ],
      ),
      body: carListAsync.when(
        data: (cars) => _buildBody(cars, favorites),
        loading: () => const custom.LoadingWidget(),
        error: (err, stack) => custom.ErrorWidget(error: err.toString()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 1: Navigator.of(context).pushNamed(AppRoutes.search); break;
            case 2: Navigator.of(context).pushNamed(AppRoutes.favorites); break;
            case 3: Navigator.of(context).pushNamed(AppRoutes.orders); break;
            case 4: Navigator.of(context).pushNamed(AppRoutes.profile); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'البحث'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'المفضلة'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'الطلبات'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }

  Widget _buildBody(List cars, List favorites) {
    final featuredCars = cars.take(3).toList();
    final latestCars = cars.skip(3).take(5).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.search),
              child: custom.SearchBar(
                controller: TextEditingController(),
                hint: 'ابحث عن سيارة أحلامك...',
                onChanged: (v) {},
              ),
            ),
          ),
          // Featured Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
            child: Text('السيارات المميزة', style: AppTextStyles.headlineSmall),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
              itemCount: featuredCars.length,
              itemBuilder: (context, index) {
                final car = featuredCars[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 250,
                    child: CarCard(
                      imageUrl: car.imageUrls.isNotEmpty ? car.imageUrls.first : '',
                      carName: car.brand,
                      carModel: car.model,
                      price: car.priceFormatted,
                      isFavorite: favorites.contains(car.id),
                      onFavoriteToggle: () => ref.read(favoritesProvider.notifier).toggleFavorite(car.id),
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.carDetails, arguments: car.id),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
            child: Text('الفئات', style: AppTextStyles.headlineSmall),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCatItem('رياضية', Icons.speed),
                _buildCatItem('فاخرة', Icons.star_outline),
                _buildCatItem('كهربائية', Icons.electric_car),
                _buildCatItem('كلاسيكية', Icons.history),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Latest Cars
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('أحدث السيارات', style: AppTextStyles.headlineSmall),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cars),
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
            itemCount: latestCars.length,
            itemBuilder: (context, index) {
              final car = latestCars[index];
              return CarCard(
                imageUrl: car.imageUrls.isNotEmpty ? car.imageUrls.first : '',
                carName: car.brand,
                carModel: car.model,
                price: car.priceFormatted,
                isFavorite: favorites.contains(car.id),
                onFavoriteToggle: () => ref.read(favoritesProvider.notifier).toggleFavorite(car.id),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.carDetails, arguments: car.id),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCatItem(String title, IconData icon) {
    return Column(
      children: [
        GlassContainer(
          width: 65,
          height: 65,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(16),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(title, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
