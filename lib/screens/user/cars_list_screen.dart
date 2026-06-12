import 'package:flutter/material.dart';
import '../../models/car_model.dart';
import '../../repositories/car_repository.dart';

class CarsListScreen extends StatefulWidget {
  const CarsListScreen({Key? key}) : super(key: key);

  @override
  State<CarsListScreen> createState() => _CarsListScreenState();
}

class _CarsListScreenState extends State<CarsListScreen> {
  final CarRepository carRepository = CarRepository();
  List<Car> cars = [];
  List<Car> filteredCars = [];
  bool isLoading = true;
  final searchController = TextEditingController();
  String sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCars() async {
    try {
      final fetchedCars = await carRepository.getAllCars();
      setState(() {
        cars = fetchedCars;
        _filterAndSortCars();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  void _filterAndSortCars() {
    final term = searchController.text.toLowerCase();

    List<Car> filtered = cars.where((car) {
      return car.brand.toLowerCase().contains(term) ||
          car.model.toLowerCase().contains(term) ||
          car.year.toString().contains(term);
    }).toList();

    // Sort
    if (sortBy == 'price-low') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortBy == 'price-high') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortBy == 'newest') {
      filtered.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
    }

    setState(() {
      filteredCars = filtered;
    });
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جميع السيارات'),
        backgroundColor: Colors.red[700],
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Search and Filter
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        // Search
                        TextField(
                          controller: searchController,
                          onChanged: (_) => _filterAndSortCars(),
                          decoration: InputDecoration(
                            hintText: 'ابحث عن الماركة أو الموديل...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Sort
                        DropdownButton<String>(
                          value: sortBy,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'newest',
                              child: Text('الأحدث'),
                            ),
                            DropdownMenuItem(
                              value: 'price-low',
                              child: Text('السعر: من الأقل للأعلى'),
                            ),
                            DropdownMenuItem(
                              value: 'price-high',
                              child: Text('السعر: من الأعلى للأقل'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                sortBy = value;
                              });
                              _filterAndSortCars();
                            }
                          },
                        ),
                        const SizedBox(height: 15),

                        // Results count
                        Text(
                          'عدد النتائج: ${filteredCars.length} سيارة',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cars Grid
                  if (filteredCars.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('لم يتم العثور على سيارات'),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredCars.length,
                        itemBuilder: (context, index) {
                          final car = filteredCars[index];
                          return _buildCarCard(car);
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildCarCard(Car car) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/car-details', arguments: car.id);
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: Colors.grey[300],
              ),
              child: Stack(
                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 40,
                    color: Colors.grey,
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: car.isSold ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        car.isSold ? '❌ مباع' : '✅ متاح',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${car.brand} ${car.model}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${car.year}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatPrice(car.price),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
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