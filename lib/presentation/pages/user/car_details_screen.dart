import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/custom_widgets.dart' as custom;
import '../../../models/car_model.dart';
import '../../../models/order_model.dart';

class CarDetailsScreen extends ConsumerStatefulWidget {
  final int carId;
  const CarDetailsScreen({Key? key, required this.carId}) : super(key: key);

  @override
  ConsumerState<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends ConsumerState<CarDetailsScreen> {
  bool _isOrdering = false;

  @override
  Widget build(BuildContext context) {
    final carAsync = ref.watch(carListProvider).whenData(
          (cars) => cars.firstWhere((c) => c.id == widget.carId),
        );

    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      body: carAsync.when(
        data: (car) => _buildContent(car, favorites.contains(car.id)),
        loading: () => const custom.LoadingWidget(),
        error: (err, stack) => custom.ErrorWidget(error: err.toString()),
      ),
    );
  }

  Widget _buildContent(Car car, bool isFavorite) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 350,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (car.imageUrls.isNotEmpty)
                  Image.network(car.imageUrls.first, fit: BoxFit.cover)
                else
                  Container(
                    color: AppColors.surface,
                    child: const Icon(Icons.directions_car, size: 100),
                  ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.background],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? AppColors.error : Colors.white,
              ),
              onPressed: () =>
                  ref.read(favoritesProvider.notifier).toggleFavorite(car.id),
            ),
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(car.brand,
                            style: AppTextStyles.displaySmall
                                .copyWith(color: AppColors.primary)),
                        Text(car.model,
                            style: AppTextStyles.headlineMedium),
                      ],
                    ),
                    GlassContainer(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      borderRadius: BorderRadius.circular(12),
                      child: Text(
                        car.statusText,
                        style: TextStyle(
                          color: car.isSold
                              ? AppColors.error
                              : AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingLarge),

                Text(
                  car.priceFormatted,
                  style: AppTextStyles.displayMedium
                      .copyWith(color: AppColors.primary),
                ),

                const SizedBox(height: AppDimensions.spacingLarge),

                _buildSpecsGrid(car),

                const SizedBox(height: AppDimensions.spacingLarge),

                Text('الوصف',
                    style: AppTextStyles.headlineSmall),

                const SizedBox(height: AppDimensions.spacingSmall),

                Text(
                  car.description ??
                      'لا يوجد وصف متاح لهذه السيارة حالياً.',
                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: custom.CustomButton(
                    label: 'طلب السيارة',
                    isLoading: _isOrdering,
                    onPressed: () => _showOrderSheet(car),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecsGrid(Car car) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildSpecItem(Icons.calendar_today, 'السنة', car.year.toString()),
        _buildSpecItem(Icons.speed, 'المسافة', '${car.kilometers} كم'),
        _buildSpecItem(Icons.local_gas_station, 'الوقود', car.fuel),
        _buildSpecItem(Icons.settings, 'ناقل الحركة', car.transmission),
      ],
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              Text(value,
                  style: AppTextStyles.titleLarge
                      .copyWith(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showOrderSheet(Car car) async {
    setState(() => _isOrdering = true);

    try {
      final user = ref.read(userProvider).value;

      if (user == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      final order = Order(
        id: 0,
        userId: user.id,
        carId: car.id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phone: '',
        notes: 'طلب سيارة ${car.brand} ${car.model}',
        total: car.price,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await ref.read(orderRepositoryProvider).createOrder(order);

      await ref.read(orderListProvider.notifier).loadOrders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال الطلب بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }

    setState(() => _isOrdering = false);
  }
}