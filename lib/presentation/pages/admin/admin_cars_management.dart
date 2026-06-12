import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/custom_widgets.dart' as custom;

class AdminCarsManagement extends ConsumerWidget {
  const AdminCarsManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carListAsync = ref.watch(carListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة السيارات')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.adminAddCar),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.dark),
      ),
      body: carListAsync.when(
        data: (cars) {
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.surface,
                    ),
                    child: car.imageUrls.isNotEmpty 
                        ? Image.network(car.imageUrls.first, fit: BoxFit.cover)
                        : const Icon(Icons.directions_car),
                  ),
                  title: Text(car.fullName, style: AppTextStyles.titleLarge),
                  subtitle: Text('${car.year} | ${car.priceFormatted}', style: AppTextStyles.bodySmall),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.info),
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.adminEditCar, arguments: car.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => _showDeleteConfirm(context, ref, car.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const custom.LoadingWidget(),
        error: (err, stack) => custom.ErrorWidget(error: err.toString()),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('حذف السيارة'),
        content: const Text('هل أنت متأكد من حذف هذه السيارة؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              await ref.read(carRepositoryProvider).deleteCar(id);
              ref.read(carListProvider.notifier).refreshCars();
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
