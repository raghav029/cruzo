import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/auth/bloc/auth_bloc.dart';
import '../../../../../core/auth/bloc/auth_event.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../../shared/widgets/change_password_sheet.dart';
import '../../../../../shared/widgets/edit_employee_profile_sheet.dart';
import '../view_models/employee_profile_view_model.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  late final EmployeeProfileViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<EmployeeProfileViewModel>();
    _vm.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.darkBg1,
          body: SafeArea(
            child: _vm.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : _vm.error != null
                    ? Center(child: Text(_vm.error!, style: AppTextStyles.body.copyWith(color: AppColors.bad)))
                    : _buildContent(context),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final p = _vm.profile ?? {};
    final name = p['fullName'] as String? ?? '—';
    final email = p['email'] as String? ?? '—';
    final phone = p['phone'] as String? ?? '—';
    final client = p['corporateClientName'] as String? ?? '—';
    final dept = p['department'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadH,
        vertical: AppSpacing.pagePadV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profile', style: AppTextStyles.h1.copyWith(color: AppColors.darkFg0)),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.accent),
                onPressed: () => EditEmployeeProfileSheet.show(
                  context,
                  currentPhone: phone == '—' ? null : phone,
                  currentDepartment: dept.isEmpty ? null : dept,
                  onSaved: _vm.setProfile,
                  onSubmit: _vm.updateProfile,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.accentBg,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: AppTextStyles.h1.copyWith(color: AppColors.accent),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(name, style: AppTextStyles.h2.copyWith(color: AppColors.darkFg0)),
                if (dept.isNotEmpty)
                  Text(dept, style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _Section(
            title: 'Contact',
            rows: [
              _Row(Icons.email_outlined, 'Email', email),
              _Row(Icons.phone_outlined, 'Phone', phone),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _Section(
            title: 'Organisation',
            rows: [
              _Row(Icons.business_outlined, 'Company', client),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ChangePasswordButton(),
          const SizedBox(height: AppSpacing.md),
          _LogoutButton(),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<_Row> rows;
  const _Section({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.cardPadH, AppSpacing.sm, AppSpacing.cardPadH, AppSpacing.xs),
            child: Text(title,
                style: AppTextStyles.label.copyWith(color: AppColors.darkFg3)),
          ),
          const Divider(height: 1, color: AppColors.darkLine),
          ...rows.map((r) => r),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadH, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.darkFg3),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.body.copyWith(color: AppColors.darkFg2)),
          const Spacer(),
          Text(value, style: AppTextStyles.body.copyWith(color: AppColors.darkFg0)),
        ],
      ),
    );
  }
}

class _ChangePasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => ChangePasswordSheet.show(context),
        icon: const Icon(Icons.lock_outline, color: AppColors.accent),
        label: Text('Change Password',
            style: AppTextStyles.body.copyWith(color: AppColors.accent)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.accent),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm)),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppColors.darkBg2,
              title: Text('Logout', style: AppTextStyles.h3.copyWith(color: AppColors.darkFg0)),
              content: Text('Are you sure?',
                  style: AppTextStyles.body.copyWith(color: AppColors.darkFg1)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: AppTextStyles.body.copyWith(color: AppColors.darkFg2)),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.bad),
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout, color: AppColors.bad),
        label: Text('Logout', style: AppTextStyles.body.copyWith(color: AppColors.bad)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.bad),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
        ),
      ),
    );
  }
}
