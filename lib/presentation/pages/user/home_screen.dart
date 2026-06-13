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
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

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
            case 1:
              Navigator.of(context).pushNamed(AppRoutes.search);
              break;
            case 2:
              Navigator.of(context).pushNamed(AppRoutes.favorites);
              break;
            case 3:
              Navigator.of(context).pushNamed(AppRoutes.orders);
              break;
            case 4:
              Navigator.of(context).pushNamed(AppRoutes.profile);
              break;
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
    final latestCars = cars.skip(3).take(4).toList();
    final query = _searchController.text.toLowerCase();
    final filteredCars = cars.where((car) {
      final term = '${car.brand} ${car.model} ${car.year}'.toLowerCase();
      return query.isEmpty || term.contains(query);
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(),
          const SizedBox(height: AppDimensions.spacingLarge),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
            child: custom.SearchBar(
              controller: _searchController,
              hint: 'ابحث عن الماركة أو الموديل...',
              onChanged: (value) => setState(() {}),
              onClear: () => setState(() {}),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الفئات', style: AppTextStyles.headlineSmall),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.about),
                  child: const Text('من نحن'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 80,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('All'),
                _buildCategoryChip('رياضية'),
                _buildCategoryChip('فاخرة'),
                _buildCategoryChip('كهربائية'),
                _buildCategoryChip('كلاسيكية'),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
            child: Text('السيارات المميزة', style: AppTextStyles.headlineSmall),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          SizedBox(
            height: 300,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
              scrollDirection: Axis.horizontal,
              itemCount: featuredCars.length,
              itemBuilder: (context, index) {
                final car = featuredCars[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: SizedBox(
                    width: 260,
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
          const SizedBox(height: AppDimensions.spacingLarge),
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
          const SizedBox(height: AppDimensions.spacingMedium),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
            child: filteredCars.isEmpty
                ? const Center(
                    child: Text('لا توجد سيارات مطابقة', style: TextStyle(color: AppColors.textSecondary)),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisExtent: 320,
                      childAspectRatio: 0.9,
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
                        onFavoriteToggle: () => ref.read(favoritesProvider.notifier).toggleFavorite(car.id),
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.carDetails, arguments: car.id),
                      );
                    },
                  ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('أقوى تجربة لشراء السيارات الفاخرة', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            'سيارتك القادمة هنا. تصميم راقٍ، أداء قوي، وعروض مميزة تمنحك قيادة فخمة من اللحظة الأولى.',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cars),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
                ),
                child: const Text('ابدأ رحلتك الآن 🚗'),
              ),
              const SizedBox(width: AppDimensions.spacingMedium),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.contactUs),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('اتصل بنا'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final selected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.spacingSmall),
      child: ChoiceChip(
        label: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: selected ? AppColors.dark : AppColors.textPrimary)),
        selected: selected,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.surface,
        onSelected: (_) => setState(() => _selectedCategory = label),
      ),
    );
  }
}
