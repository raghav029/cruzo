import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/auth/bloc/auth_bloc.dart';
import '../../../../../core/auth/bloc/auth_event.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../../shared/widgets/app_error_view.dart';
import '../../../../../shared/widgets/change_password_sheet.dart';
import '../../../../../shared/widgets/edit_driver_profile_sheet.dart';
import '../view_models/driver_profile_view_model.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  late final DriverProfileViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<DriverProfileViewModel>();
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
                    ? AppErrorView(message: _vm.error!, onRetry: _vm.load)
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
    final license = p['licenseNumber'] as String? ?? '—';
    final licenseExpiry = p['licenseExpiry'] as String? ?? '—';
    final insuranceExpiry = p['insuranceExpiry'] as String? ?? '—';
    final availability = p['availability'] as String? ?? 'OFF_DUTY';

    final (availColor, availBg) = switch (availability) {
      'AVAILABLE' => (AppColors.good, AppColors.goodBg),
      'ON_TRIP' => (AppColors.accent, AppColors.accentBg),
      _ => (AppColors.darkFg3, AppColors.darkBg3),
    };

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
                onPressed: () => _showEditSheet(context, phone),
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
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: availBg,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    availability.replaceAll('_', ' '),
                    style: AppTextStyles.label.copyWith(color: availColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: 'Quick Links',
            rows: [
              _NavRow(
                icon: Icons.bar_chart_rounded,
                label: 'My Stats & Earnings',
                onTap: () => context.pushNamed(AppRoutes.driverStats),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _Section(
            title: 'Contact',
            rows: [
              _InfoRow(Icons.email_outlined, 'Email', email),
              _InfoRow(Icons.phone_outlined, 'Phone', phone),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _Section(
            title: 'License & Documents',
            rows: [
              _InfoRow(Icons.badge_outlined, 'License No.', license),
              _InfoRow(Icons.calendar_today_outlined, 'License Expiry', licenseExpiry),
              _InfoRow(Icons.shield_outlined, 'Insurance Expiry', insuranceExpiry),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _Section(
            title: 'Account',
            rows: [
              _NavRow(
                icon: Icons.edit_outlined,
                label: 'Edit Profile',
                onTap: () => _showEditSheet(context, phone),
              ),
              _NavRow(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () => ChangePasswordSheet.show(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _LogoutButton(),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, String phone) {
    EditDriverProfileSheet.show(
      context,
      currentPhone: phone == '—' ? null : phone,
      onSaved: _vm.setProfile,
      onSubmit: _vm.updateProfile,
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> rows;
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
          ...rows,
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadH, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.accent),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(label,
                  style: AppTextStyles.body.copyWith(color: AppColors.darkFg0)),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.darkFg3),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

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
