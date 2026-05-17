import 'package:flutter/material.dart';
import '../../core/theme/dls/dls.dart';

class EditDriverProfileSheet extends StatefulWidget {
  final String? currentPhone;
  final void Function(Map<String, dynamic> updated) onSaved;
  final Future<Map<String, dynamic>> Function(Map<String, dynamic>) onSubmit;

  const EditDriverProfileSheet({
    super.key,
    this.currentPhone,
    required this.onSaved,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required String? currentPhone,
    required void Function(Map<String, dynamic> updated) onSaved,
    required Future<Map<String, dynamic>> Function(Map<String, dynamic>) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditDriverProfileSheet(
        currentPhone: currentPhone,
        onSaved: onSaved,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<EditDriverProfileSheet> createState() => _EditDriverProfileSheetState();
}

class _EditDriverProfileSheetState extends State<EditDriverProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.currentPhone ?? '');
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final updated = await widget.onSubmit({
        if (_phoneCtrl.text.trim().isNotEmpty) 'phone': _phoneCtrl.text.trim(),
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
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
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
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.body.copyWith(color: AppColors.darkFg0),
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 7) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Phone',
                  labelStyle:
                      AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
                  prefixIcon: const Icon(Icons.phone_outlined,
                      size: 18, color: AppColors.darkFg3),
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
