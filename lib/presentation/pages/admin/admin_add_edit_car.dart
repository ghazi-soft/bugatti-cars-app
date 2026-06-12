import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/custom_widgets.dart' as custom;
import '../../../models/car_model.dart';

class AdminAddEditCarScreen extends ConsumerStatefulWidget {
  final int? carId;
  const AdminAddEditCarScreen({Key? key, this.carId}) : super(key: key);

  @override
  ConsumerState<AdminAddEditCarScreen> createState() => _AdminAddEditCarScreenState();
}

class _AdminAddEditCarScreenState extends ConsumerState<AdminAddEditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _kmController;
  late TextEditingController _colorController;
  late TextEditingController _locationController;
  bool _isSold = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController();
    _modelController = TextEditingController();
    _yearController = TextEditingController();
    _priceController = TextEditingController();
    _descController = TextEditingController();
    _kmController = TextEditingController();
    _colorController = TextEditingController();
    _locationController = TextEditingController();

    if (widget.carId != null) {
      _loadCarData();
    }
  }

  void _loadCarData() async {
    final cars = ref.read(carListProvider).value;
    if (cars != null) {
      final car = cars.firstWhere((c) => c.id == widget.carId);
      _brandController.text = car.brand;
      _modelController.text = car.model;
      _yearController.text = car.year.toString();
      _priceController.text = car.price.toString();
      _descController.text = car.description ?? '';
      _kmController.text = car.kilometers.toString();
      _colorController.text = car.color;
      _locationController.text = car.location;
      setState(() => _isSold = car.isSold);
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _kmController.dispose();
    _colorController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final car = Car(
      id: widget.carId ?? 0,
      brand: _brandController.text,
      model: _modelController.text,
      year: int.parse(_yearController.text),
      price: double.parse(_priceController.text),
      description: _descController.text,
      isSold: _isSold,
      fuel: 'Petrol',
      transmission: 'Automatic',
      kilometers: int.parse(_kmController.text),
      color: _colorController.text,
      location: _locationController.text,
      createdAt: DateTime.now(),
      imageUrls: [],
    );

    try {
      if (widget.carId == null) {
        await ref.read(carRepositoryProvider).addCar(car);
      } else {
        await ref.read(carRepositoryProvider).updateCar(car);
      }
      ref.read(carListProvider.notifier).refreshCars();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.carId == null ? 'إضافة سيارة' : 'تعديل سيارة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              custom.CustomTextField(label: 'الماركة', controller: _brandController, validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              const SizedBox(height: 16),
              custom.CustomTextField(label: 'الموديل', controller: _modelController, validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: custom.CustomTextField(label: 'السنة', controller: _yearController, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: custom.CustomTextField(label: 'السعر', controller: _priceController, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              custom.CustomTextField(label: 'الكيلومترات', controller: _kmController, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              custom.CustomTextField(label: 'اللون', controller: _colorController),
              const SizedBox(height: 16),
              custom.CustomTextField(label: 'الموقع', controller: _locationController),
              const SizedBox(height: 16),
              custom.CustomTextField(label: 'الوصف', controller: _descController, maxLines: 4),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('تم البيع'),
                value: _isSold,
                onChanged: (val) => setState(() => _isSold = val),
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 32),
              custom.CustomButton(
                label: widget.carId == null ? 'إضافة السيارة' : 'حفظ التعديلات',
                isLoading: _isSaving,
                onPressed: _saveCar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
