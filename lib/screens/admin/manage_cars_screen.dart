import 'package:flutter/material.dart';
import '../../models/car_model.dart';
import '../../repositories/car_repository.dart';

class ManageCarsScreen extends StatefulWidget {
  const ManageCarsScreen({Key? key}) : super(key: key);

  @override
  State<ManageCarsScreen> createState() => _ManageCarsScreenState();
}

class _ManageCarsScreenState extends State<ManageCarsScreen> {
  final CarRepository carRepository = CarRepository();

  List<Car> cars = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    try {
      final fetchedCars = await carRepository.getAllCars();
      setState(() {
        cars = fetchedCars;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  void _showAddCarDialog() {
    showDialog(
      context: context,
      builder: (_) => const AddCarDialog(),
    ).then((value) {
      if (value == true) _loadCars();
    });
  }

  void _showEditCarDialog(Car car) {
    showDialog(
      context: context,
      builder: (_) => EditCarDialog(car: car),
    ).then((value) {
      if (value == true) _loadCars();
    });
  }

  Future<void> _deleteCar(int id) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف السيارة'),
        content: const Text('هل أنت متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await carRepository.deleteCar(id);
                Navigator.pop(context);
                _loadCars();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم الحذف')),
                );
              } catch (e) {
                Navigator.pop(context);
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة السيارات'),
        backgroundColor: Colors.red,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCarDialog,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cars.isEmpty
              ? const Center(child: Text('لا توجد سيارات'))
              : ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    return _buildCarItem(cars[index]);
                  },
                ),
    );
  }

  Widget _buildCarItem(Car car) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(car.fullName),
        subtitle: Text('${car.year} - ${car.priceFormatted}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditCarDialog(car),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCar(car.id),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= ADD CAR ================= */

class AddCarDialog extends StatefulWidget {
  const AddCarDialog({Key? key}) : super(key: key);

  @override
  State<AddCarDialog> createState() => _AddCarDialogState();
}

class _AddCarDialogState extends State<AddCarDialog> {
  final CarRepository carRepository = CarRepository();

  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isLoading = false;

  Future<void> _addCar() async {
    if (brandController.text.isEmpty ||
        modelController.text.isEmpty ||
        yearController.text.isEmpty ||
        priceController.text.isEmpty) {
      return;
    }

    setState(() => isLoading = true);

    try {
      await carRepository.addCar(
        Car(
          id: 0,
          brand: brandController.text,
          model: modelController.text,
          year: int.parse(yearController.text),
          price: double.parse(priceController.text),
          description: descriptionController.text,
          isSold: false,
          fuel: 'Unknown',
          transmission: 'Unknown',
          kilometers: 0,
          color: 'Unknown',
          location: 'Unknown',
          createdAt: DateTime.now(),
          imageUrls: [],
        ),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة سيارة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: brandController),
          TextField(controller: modelController),
          TextField(controller: yearController),
          TextField(controller: priceController),
          TextField(controller: descriptionController),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _addCar,
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}

/* ================= EDIT CAR ================= */

class EditCarDialog extends StatefulWidget {
  final Car car;

  const EditCarDialog({Key? key, required this.car}) : super(key: key);

  @override
  State<EditCarDialog> createState() => _EditCarDialogState();
}

class _EditCarDialogState extends State<EditCarDialog> {
  final CarRepository carRepository = CarRepository();

  late TextEditingController brandController;
  late TextEditingController modelController;
  late TextEditingController yearController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;

  bool isSold = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    brandController = TextEditingController(text: widget.car.brand);
    modelController = TextEditingController(text: widget.car.model);
    yearController = TextEditingController(text: '${widget.car.year}');
    priceController = TextEditingController(text: '${widget.car.price}');
    descriptionController =
        TextEditingController(text: widget.car.description ?? '');

    isSold = widget.car.isSold;
  }

  Future<void> _updateCar() async {
    setState(() => isLoading = true);

    try {
      await carRepository.updateCar(
        Car(
          id: widget.car.id,
          brand: brandController.text,
          model: modelController.text,
          year: int.parse(yearController.text),
          price: double.parse(priceController.text),
          description: descriptionController.text,
          isSold: isSold,
          fuel: widget.car.fuel,
          transmission: widget.car.transmission,
          kilometers: widget.car.kilometers,
          color: widget.car.color,
          location: widget.car.location,
          createdAt: widget.car.createdAt,
          imageUrls: widget.car.imageUrls,
        ),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعديل السيارة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: brandController),
          TextField(controller: modelController),
          TextField(controller: yearController),
          TextField(controller: priceController),
          TextField(controller: descriptionController),
          CheckboxListTile(
            value: isSold,
            onChanged: (v) => setState(() => isSold = v ?? false),
            title: const Text('مباعة'),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _updateCar,
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}