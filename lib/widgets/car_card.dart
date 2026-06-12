import 'package:flutter/material.dart';
import 'package:bugatti_cars/core/design_system.dart';
import 'package:bugatti_cars/widgets/glass_container.dart';

import '../core/constants.dart';

class CarCard extends StatelessWidget {
  final String imageUrl;
  final String carName;
  final String carModel;
  final String price;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const CarCard({
    Key? key,
    required this.imageUrl,
    required this.carName,
    required this.carModel,
    required this.price,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  }) : super(key: key);

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: AppColors.surface,
      child: Icon(Icons.directions_car, color: AppColors.textTertiary, size: AppDimensions.iconExtraLarge),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          carName,
                          style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onFavoriteToggle != null)
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? AppColors.error : AppColors.textSecondary,
                          ),
                          onPressed: onFavoriteToggle,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(
                    carModel,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      price,
                      style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
