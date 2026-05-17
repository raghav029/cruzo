import 'package:flutter/material.dart';
import '../../core/theme/dls/dls.dart';

class EditEmployeeProfileSheet extends StatefulWidget {
  final String? currentPhone;
  final String? currentDepartment;
  final void Function(Map<String, dynamic> updated) onSaved;
  final Future<Map<String, dynamic>> Function(Map<String, dynamic>) onSubmit;

  const EditEmployeeProfileSheet({
    super.key,
    this.currentPhone,
    this.currentDepartment,
    required this.onSaved,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required String? currentPhone,
    required String? currentDepartment,
    required void Function(Map<String, dynamic> updated) onSaved,
    required Future<Map<String, dynamic>> Function(Map<String, dynamic>) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditEmployeeProfileSheet(
        currentPhone: currentPhone,
        currentDepartment: currentDepartment,
        onSaved: onSaved,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<EditEmployeeProfileSheet> createState() =>
      _EditEmployeeProfileSheetState();
}

class _EditEmployeeProfileSheetState extends State<EditEmployeeProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _deptCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.currentPhone ?? '');
    _deptCtrl = TextEditingController(text: widget.currentDepartment ?? '');
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final updated = await widget.onSubmit({
        if (_phoneCtrl.text.trim().isNotEmpty) 'phone': _phoneCtrl.text.trim(),
        if (_deptCtrl.text.trim().isNotEmpty) 'department': _deptCtrl.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved(updated);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profile updated.'),
        backgroundColor: AppColors.good,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppColors.bad,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.darkBg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.darkBg3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Edit Profile',
                  style: AppTextStyles.h3.copyWith(color: AppColors.darkFg0)),
              const SizedBox(height: 20),
              _Field(
                controller: _phoneCtrl,
                label: 'Phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 7) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _Field(
                controller: _deptCtrl,
                label: 'Department',
                icon: Icons.business_center_outlined,
                validator: (_) => null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Save Changes',
                          style: AppTextStyles.body
                              .copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.body.copyWith(color: AppColors.darkFg0),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
        prefixIcon: Icon(icon, size: 18, color: AppColors.darkFg3),
        filled: true,
        fillColor: AppColors.darkBg3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.darkLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.darkLine),
        ),
      ),
    );
  }
}
