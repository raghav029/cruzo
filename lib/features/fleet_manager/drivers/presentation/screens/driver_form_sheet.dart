import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/driver.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/driver_event.dart';

class DriverFormSheet extends StatefulWidget {
  final Driver? driver;
  const DriverFormSheet({super.key, this.driver});

  static Future<void> show(BuildContext context, {Driver? driver}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<DriverBloc>(),
        child: DriverFormSheet(driver: driver),
      ),
    );
  }

  @override
  State<DriverFormSheet> createState() => _DriverFormSheetState();
}

class _DriverFormSheetState extends State<DriverFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _license;
  DateTime? _licenseExpiry;
  DateTime? _insuranceExpiry;
  String _availability = 'AVAILABLE';
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    final d = widget.driver;
    _isEdit = d != null;
    final nameParts = d?.fullName.split(' ') ?? [];
    _firstName = TextEditingController(text: nameParts.isNotEmpty ? nameParts.first : '');
    _lastName = TextEditingController(text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');
    _email = TextEditingController(text: d?.email ?? '');
    _phone = TextEditingController(text: d?.phone ?? '');
    _license = TextEditingController(text: d?.licenseNumber ?? '');
    _availability = d?.availability ?? 'AVAILABLE';
    if (d?.licenseExpiry != null) _licenseExpiry = DateTime.parse(d!.licenseExpiry!);
    if (d?.insuranceExpiry != null) _insuranceExpiry = DateTime.parse(d!.insuranceExpiry!);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _license.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEdit) {
      final data = {
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'licenseNumber': _license.text.trim(),
        if (_licenseExpiry != null) 'licenseExpiry': _licenseExpiry!.toIso8601String().split('T').first,
        if (_insuranceExpiry != null) 'insuranceExpiry': _insuranceExpiry!.toIso8601String().split('T').first,
      };
      context.read<DriverBloc>().add(DriverCreateRequested(data));
    } else {
      final data = {
        'phone': _phone.text.trim(),
        'licenseNumber': _license.text.trim(),
        'availability': _availability,
        if (_licenseExpiry != null) 'licenseExpiry': _licenseExpiry!.toIso8601String().split('T').first,
        if (_insuranceExpiry != null) 'insuranceExpiry': _insuranceExpiry!.toIso8601String().split('T').first,
      };
      context.read<DriverBloc>().add(DriverUpdateRequested(widget.driver!.id, data));
    }
    Navigator.pop(context);
  }

  Future<void> _pickDate(bool isLicense) async {
    final initial = isLicense
        ? (_licenseExpiry ?? DateTime.now().add(const Duration(days: 365)))
        : (_insuranceExpiry ?? DateTime.now().add(const Duration(days: 365)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null) setState(() => isLicense ? _licenseExpiry = picked : _insuranceExpiry = picked);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(_isEdit ? 'Edit Driver' : 'Add Driver', style: AppTextStyles.h3),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isEdit) ...[
                        Row(children: [
                          Expanded(child: _field('First Name', _firstName, required: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _field('Last Name', _lastName, required: true)),
                        ]),
                        const SizedBox(height: 16),
                        _field('Email', _email, required: true, keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required';
                            if (!v.contains('@')) return 'Enter valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      _field('Phone', _phone, required: true, keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _field('License Number', _license, required: true, hint: 'e.g. MH0120230012345'),
                      const SizedBox(height: 16),
                      _label('License Expiry'),
                      const SizedBox(height: 8),
                      _datePicker(_licenseExpiry, () => _pickDate(true), required: true),
                      const SizedBox(height: 16),
                      _label('Insurance Expiry (optional)'),
                      const SizedBox(height: 8),
                      _datePicker(_insuranceExpiry, () => _pickDate(false)),
                      if (_isEdit) ...[
                        const SizedBox(height: 16),
                        _label('Availability'),
                        const SizedBox(height: 8),
                        _availabilitySelector(),
                      ],
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(_isEdit ? 'Save Changes' : 'Add Driver',
                              style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
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

  Widget _availabilitySelector() {
    const options = ['AVAILABLE', 'OFF_DUTY'];
    return Row(
      children: options.map((o) {
        final selected = _availability == o;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _availability = o),
            child: Container(
              margin: EdgeInsets.only(right: o != options.last ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: selected ? AppColors.primary : AppColors.grey200),
              ),
              alignment: Alignment.center,
              child: Text(
                o == 'AVAILABLE' ? 'Available' : 'Off Duty',
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: selected ? AppColors.white : AppColors.grey600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _datePicker(DateTime? date, VoidCallback onTap, {bool required = false}) {
    final missing = required && date == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: Border.all(color: missing ? AppColors.error : AppColors.grey300),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 16,
                color: missing ? AppColors.error : AppColors.grey400),
            const SizedBox(width: 10),
            Text(
              date != null ? '${date.day}/${date.month}/${date.year}' : 'Select date',
              style: TextStyle(
                color: date != null ? AppColors.grey900 : (missing ? AppColors.error : AppColors.grey400),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: AppTextStyles.label);

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
            hintStyle: const TextStyle(color: AppColors.grey400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.grey300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.grey300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
          ),
          validator: validator ?? (required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null),
        ),
      ],
    );
  }
}
