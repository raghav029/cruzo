import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../domain/corporate_client.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';

class ClientFormSheet extends StatefulWidget {
  final CorporateClient? client;
  const ClientFormSheet({super.key, this.client});

  static Future<void> show(BuildContext context, {CorporateClient? client}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ClientBloc>(),
        child: ClientFormSheet(client: client),
      ),
    );
  }

  @override
  State<ClientFormSheet> createState() => _ClientFormSheetState();
}

class _ClientFormSheetState extends State<ClientFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _gst;
  late final TextEditingController _address;
  late final TextEditingController _email;
  late final TextEditingController _creditLimit;
  String _billingCycle = 'MONTHLY';
  bool _active = true;
  late final TextEditingController _maxBookingValue;
  List<String> _allowedVehicleTypes = [];

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    _name = TextEditingController(text: c?.companyName ?? '');
    _gst = TextEditingController(text: c?.gstNumber ?? '');
    _address = TextEditingController(text: c?.billingAddress ?? '');
    _email = TextEditingController(text: c?.billingEmail ?? '');
    _creditLimit = TextEditingController(
        text: c != null && c.creditLimit > 0 ? c.creditLimit.toStringAsFixed(0) : '');
    _billingCycle = c?.billingCycle ?? 'MONTHLY';
    _active = c?.active ?? true;
    _maxBookingValue = TextEditingController(
        text: c?.maxBookingValue != null ? c!.maxBookingValue!.toStringAsFixed(0) : '');
    _allowedVehicleTypes = c?.allowedVehicleTypes ?? [];
  }

  @override
  void dispose() {
    _name.dispose();
    _gst.dispose();
    _address.dispose();
    _email.dispose();
    _creditLimit.dispose();
    _maxBookingValue.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'companyName': _name.text.trim(),
      if (_gst.text.isNotEmpty) 'gstNumber': _gst.text.trim(),
      if (_address.text.isNotEmpty) 'billingAddress': _address.text.trim(),
      'billingEmail': _email.text.trim(),
      'billingCycle': _billingCycle,
      'creditLimit': double.tryParse(_creditLimit.text.trim()) ?? 0,
      if (_maxBookingValue.text.isNotEmpty)
        'maxBookingValue': double.tryParse(_maxBookingValue.text.trim()),
      'allowedVehicleTypes': _allowedVehicleTypes.isEmpty
          ? null
          : _allowedVehicleTypes.join(','),
      if (widget.client != null) 'active': _active,
    };
    if (widget.client == null) {
      context.read<ClientBloc>().add(ClientCreateRequested(data));
    } else {
      context.read<ClientBloc>().add(ClientUpdateRequested(widget.client!.id, data));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.client != null;
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
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.darkBg3, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(isEdit ? 'Edit Client' : 'Add Client', style: AppTextStyles.h3),
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
                      _field('Company Name', _name, required: true),
                      const SizedBox(height: 16),
                      _field('GST Number', _gst, hint: 'e.g. 27AAPFU0939F1ZV'),
                      const SizedBox(height: 16),
                      _field('Billing Email', _email, required: true,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Billing email is required';
                            if (!v.contains('@')) return 'Enter valid email';
                            return null;
                          }),
                      const SizedBox(height: 16),
                      _field('Billing Address', _address, hint: 'Full billing address', maxLines: 2),
                      const SizedBox(height: 16),
                      _field('Credit Limit (₹)', _creditLimit, hint: '0',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                              return 'Enter valid amount';
                            }
                            return null;
                          }),
                      const SizedBox(height: 16),
                      _label('Billing Cycle'),
                      const SizedBox(height: 8),
                      _cycleSelector(),
                      if (isEdit) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Account Active', style: AppTextStyles.label),
                                Text('Employees can book when active', style: AppTextStyles.caption),
                              ],
                            ),
                            Switch(
                              value: _active,
                              onChanged: (v) => setState(() => _active = v),
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text('Travel Policy',
                          style: AppTextStyles.label.copyWith(color: AppColors.darkFg3)),
                      const SizedBox(height: 4),
                      Text('Leave blank for no restrictions',
                          style: AppTextStyles.caption.copyWith(color: AppColors.darkFg3)),
                      const SizedBox(height: 8),
                      _field('Max Booking Value (₹)', _maxBookingValue, hint: 'e.g. 5000',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                              return 'Enter valid amount';
                            }
                            return null;
                          }),
                      const SizedBox(height: 12),
                      Text('Allowed Vehicle Types',
                          style: AppTextStyles.label.copyWith(color: AppColors.darkFg3)),
                      const SizedBox(height: 4),
                      Text('Tap to toggle. None selected = all allowed.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.darkFg3)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: ['SEDAN', 'SUV', 'LUXURY'].map((type) {
                          final selected = _allowedVehicleTypes.contains(type);
                          return FilterChip(
                            label: Text(type,
                                style: AppTextStyles.bodySm.copyWith(
                                    color: selected ? AppColors.accent : AppColors.darkFg2)),
                            selected: selected,
                            onSelected: (v) => setState(() {
                              if (v) {
                                _allowedVehicleTypes.add(type);
                              } else {
                                _allowedVehicleTypes.remove(type);
                              }
                            }),
                            backgroundColor: AppColors.darkBg3,
                            selectedColor: AppColors.accentBg,
                            checkmarkColor: AppColors.accent,
                            side: BorderSide(
                                color: selected ? AppColors.accent : AppColors.darkLine),
                          );
                        }).toList(),
                      ),
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
                          child: Text(isEdit ? 'Save Changes' : 'Add Client',
                              style: const TextStyle(color: AppColors.darkBg2, fontWeight: FontWeight.w600)),
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

  Widget _cycleSelector() {
    return Row(
      children: ['MONTHLY', 'WEEKLY'].map((c) {
        final selected = _billingCycle == c;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _billingCycle = c),
            child: Container(
              margin: EdgeInsets.only(right: c == 'MONTHLY' ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.darkBg3,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: selected ? AppColors.primary : AppColors.darkLine),
              ),
              alignment: Alignment.center,
              child: Text(
                c == 'MONTHLY' ? 'Monthly' : 'Weekly',
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: selected ? AppColors.darkBg2 : AppColors.darkFg2,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _label(String text) => Text(text, style: AppTextStyles.label);

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    bool required = false,
    int maxLines = 1,
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
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.darkFg3, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
          validator: validator ?? (required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null),
        ),
      ],
    );
  }
}
