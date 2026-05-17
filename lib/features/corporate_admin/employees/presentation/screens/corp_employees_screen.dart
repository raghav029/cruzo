import 'package:flutter/material.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../view_models/corp_employees_view_model.dart';
import '../../domain/corp_employee.dart';

class CorpEmployeesScreen extends StatefulWidget {
  final CorpEmployeesViewModel viewModel;
  const CorpEmployeesScreen({super.key, required this.viewModel});

  @override
  State<CorpEmployeesScreen> createState() => _CorpEmployeesScreenState();
}

class _CorpEmployeesScreenState extends State<CorpEmployeesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        return Scaffold(
          backgroundColor: AppColors.darkBg1,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.accent,
            icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            label: Text('Add Employee',
                style: AppTextStyles.body.copyWith(color: Colors.white)),
            onPressed: () => _showAddEmployeeSheet(context, vm),
          ),
          body: Builder(
            builder: (context) {
              if (vm.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }
              if (vm.error != null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          color: AppColors.bad, size: 48),
                      const SizedBox(height: AppSpacing.sm),
                      Text(vm.error!,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.darkFg2),
                          textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: vm.load,
                        child: Text('Retry',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.accent)),
                      ),
                    ],
                  ),
                );
              }
              if (vm.employees.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline,
                          color: AppColors.darkFg3, size: 64),
                      const SizedBox(height: AppSpacing.md),
                      Text('No employees yet',
                          style: AppTextStyles.h3
                              .copyWith(color: AppColors.darkFg2)),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Tap + to add your first employee',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.darkFg3)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.accent,
                onRefresh: vm.load,
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: vm.employees.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) =>
                      _EmployeeTile(employee: vm.employees[i]),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showAddEmployeeSheet(
      BuildContext context, CorpEmployeesViewModel vm) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkBg0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _AddEmployeeSheet(viewModel: vm),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  final CorpEmployee employee;
  const _EmployeeTile({required this.employee});

  @override
  Widget build(BuildContext context) {
    final status = employee.status?.toLowerCase() ?? '';
    final statusColor = switch (status) {
      'active' => AppColors.good,
      'inactive' => AppColors.bad,
      _ => AppColors.darkFg3,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkBg0,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accent.withAlpha(40),
            child: Text(
              employee.fullName.isNotEmpty
                  ? employee.fullName[0].toUpperCase()
                  : '?',
              style: AppTextStyles.h3.copyWith(color: AppColors.accent),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.fullName,
                    style:
                        AppTextStyles.body.copyWith(color: AppColors.darkFg0)),
                const SizedBox(height: 2),
                Text(employee.email,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.darkFg2)),
                if (employee.department != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      employee.department!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.accent),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (employee.status != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                employee.status!,
                style:
                    AppTextStyles.caption.copyWith(color: statusColor),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddEmployeeSheet extends StatefulWidget {
  final CorpEmployeesViewModel viewModel;
  const _AddEmployeeSheet({required this.viewModel});

  @override
  State<_AddEmployeeSheet> createState() => _AddEmployeeSheetState();
}

class _AddEmployeeSheetState extends State<_AddEmployeeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _designCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _deptCtrl.dispose();
    _designCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final ok = await widget.viewModel.addEmployee(
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      dept: _deptCtrl.text.trim().isEmpty ? null : _deptCtrl.text.trim(),
      designation:
          _designCtrl.text.trim().isEmpty ? null : _designCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee added successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.addError ?? 'Failed to add employee'),
          backgroundColor: AppColors.bad,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Add Employee',
                    style:
                        AppTextStyles.h3.copyWith(color: AppColors.darkFg0)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.darkFg3),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _firstCtrl,
                    label: 'First Name *',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Field(
                    controller: _lastCtrl,
                    label: 'Last Name *',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _Field(
              controller: _emailCtrl,
              label: 'Email *',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _Field(
              controller: _phoneCtrl,
              label: 'Phone *',
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            _Field(controller: _deptCtrl, label: 'Department'),
            const SizedBox(height: AppSpacing.sm),
            _Field(controller: _designCtrl, label: 'Designation'),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Add Employee',
                      style: AppTextStyles.body
                          .copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.body.copyWith(color: AppColors.darkFg0),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg3),
        filled: true,
        fillColor: AppColors.darkBg1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
    );
  }
}
