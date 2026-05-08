import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../domain/vehicle.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';

class VehicleFormSheet extends StatefulWidget {
  final Vehicle? vehicle;
  const VehicleFormSheet({super.key, this.vehicle});

  static Future<void> show(BuildContext context, {Vehicle? vehicle}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<VehicleBloc>(),
        child: VehicleFormSheet(vehicle: vehicle),
      ),
    );
  }

  @override
  State<VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends State<VehicleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _plate;
  late final TextEditingController _make;
  late final TextEditingController _model;
  late final TextEditingController _year;
  late final TextEditingController _color;
  String _vehicleType = 'SEDAN';
  DateTime? _insuranceExpiry;
  DateTime? _fitnessExpiry;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _plate = TextEditingController(text: v?.plateNumber ?? '');
    _make = TextEditingController(text: v?.make ?? '');
    _model = TextEditingController(text: v?.model ?? '');
    _year = TextEditingController(text: v?.year.toString() ?? '');
    _color = TextEditingController(text: v?.color ?? '');
    _vehicleType = v?.vehicleType ?? 'SEDAN';
    if (v?.insuranceExpiry != null)
      _insuranceExpiry = DateTime.parse(v!.insuranceExpiry!);
    if (v?.fitnessExpiry != null)
      _fitnessExpiry = DateTime.parse(v!.fitnessExpiry!);
  }

  @override
  void dispose() {
    _plate.dispose();
    _make.dispose();
    _model.dispose();
    _year.dispose();
    _color.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'plateNumber': _plate.text.trim(),
      'vehicleType': _vehicleType,
      'make': _make.text.trim(),
      'model': _model.text.trim(),
      'year': int.parse(_year.text.trim()),
      if (_color.text.isNotEmpty) 'color': _color.text.trim(),
      if (_insuranceExpiry != null)
        'insuranceExpiry': _insuranceExpiry!.toIso8601String().split('T').first,
      if (_fitnessExpiry != null)
        'fitnessExpiry': _fitnessExpiry!.toIso8601String().split('T').first,
    };
    if (widget.vehicle == null) {
      context.read<VehicleBloc>().add(VehicleCreateRequested(data));
    } else {
      context.read<VehicleBloc>().add(
        VehicleUpdateRequested(widget.vehicle!.id, data),
      );
    }
    Navigator.pop(context);
  }

  Future<void> _pickDate(bool isInsurance) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        if (isInsurance)
          _insuranceExpiry = picked;
        else
          _fitnessExpiry = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.vehicle != null;
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.darkBg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkBg3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    isEdit ? 'Edit Vehicle' : 'Add Vehicle',
                    style: AppTextStyles.h3.copyWith(color: AppColors.darkFg0),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field(
                        'Plate Number',
                        _plate,
                        hint: 'e.g. MH12AB1234',
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _label('Vehicle Type'),
                      const SizedBox(height: 8),
                      _typeSelector(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              'Make',
                              _make,
                              hint: 'e.g. Toyota',
                              required: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              'Model',
                              _model,
                              hint: 'e.g. Camry',
                              required: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              'Year',
                              _year,
                              hint: '2023',
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final y = int.tryParse(v ?? '');
                                if (y == null || y < 2000 || y > 2100)
                                  return 'Enter valid year';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field('Color', _color, hint: 'e.g. White'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _label('Insurance Expiry'),
                      const SizedBox(height: 8),
                      _datePicker(_insuranceExpiry, () => _pickDate(true)),
                      const SizedBox(height: 16),
                      _label('Fitness Expiry'),
                      const SizedBox(height: 8),
                      _datePicker(_fitnessExpiry, () => _pickDate(false)),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadii.md),
                            ),
                          ),
                          child: Text(
                            isEdit ? 'Save Changes' : 'Add Vehicle',
                            style: const TextStyle(
                              color: AppColors.accentFg,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeSelector() {
    const types = ['SEDAN', 'SUV', 'LUXURY'];
    return Row(
      children: types.map((t) {
        final selected = _vehicleType == t;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _vehicleType = t),
            child: Container(
              margin: EdgeInsets.only(right: t != types.last ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : AppColors.darkBg3,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.darkLine,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                t,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.accentFg : AppColors.darkFg2,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _datePicker(DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.darkLine),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          color: AppColors.darkBg3,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.darkFg3,
            ),
            const SizedBox(width: 10),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select date',
              style: TextStyle(
                color: date != null ? AppColors.darkFg0 : AppColors.darkFg3,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) =>
      Text(text, style: AppTextStyles.label.copyWith(color: AppColors.darkFg2));

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
          validator:
              validator ??
              (required
                  ? (v) => (v == null || v.trim().isEmpty)
                        ? '$label is required'
                        : null
                  : null),
        ),
      ],
    );
  }
}
