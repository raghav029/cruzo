import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';

class AddAdminSheet extends StatefulWidget {
  final String clientId;
  final String companyName;

  const AddAdminSheet({super.key, required this.clientId, required this.companyName});

  static Future<void> show(BuildContext context,
      {required String clientId, required String companyName}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ClientBloc>(),
        child: AddAdminSheet(clientId: clientId, companyName: companyName),
      ),
    );
  }

  @override
  State<AddAdminSheet> createState() => _AddAdminSheetState();
}

class _AddAdminSheetState extends State<AddAdminSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ClientBloc>().add(ClientAdminCreateRequested(widget.clientId, {
      'fullName': _name.text.trim(),
      'email': _email.text.trim(),
      if (_phone.text.isNotEmpty) 'phone': _phone.text.trim(),
    }));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.darkBg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Corporate Admin', style: AppTextStyles.h3),
                    Text(widget.companyName, style: AppTextStyles.bodySm),
                  ],
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _field('Full Name', _name, required: true),
                  const SizedBox(height: 14),
                  _field('Email', _email, required: true,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter valid email';
                        return null;
                      }),
                  const SizedBox(height: 14),
                  _field('Phone (optional)', _phone, keyboardType: TextInputType.phone),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Create Admin Account',
                          style: TextStyle(color: AppColors.darkBg2, fontWeight: FontWeight.w600)),
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

  Widget _field(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintStyle: const TextStyle(color: AppColors.darkFg3, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
          validator: validator ?? (required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null),
        ),
      ],
    );
  }
}
