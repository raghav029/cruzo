import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/auth/bloc/auth_bloc.dart';
import '../../../../../core/auth/bloc/auth_event.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../../shared/widgets/change_password_sheet.dart';
import '../view_models/corp_admin_profile_view_model.dart';

class CorpAdminProfileScreen extends StatefulWidget {
  const CorpAdminProfileScreen({super.key, required this.viewModel});
  final CorpAdminProfileViewModel viewModel;

  @override
  State<CorpAdminProfileScreen> createState() => _CorpAdminProfileScreenState();
}

class _CorpAdminProfileScreenState extends State<CorpAdminProfileScreen> {
  late final CorpAdminProfileViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = widget.viewModel;
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
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent))
                : _vm.error != null
                    ? Center(
                        child: Text(_vm.error!,
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.bad)))
                    : _buildContent(context),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadH,
        vertical: AppSpacing.pagePadV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile',
              style: AppTextStyles.h1.copyWith(color: AppColors.darkFg0)),
          const SizedBox(height: AppSpacing.xl),

          // Avatar + name
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.accentBg,
                  child: Text(
                    _vm.clientName.isNotEmpty
                        ? _vm.clientName[0].toUpperCase()
                        : '?',
                    style:
                        AppTextStyles.h1.copyWith(color: AppColors.accent),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(_vm.clientName,
                    style:
                        AppTextStyles.h2.copyWith(color: AppColors.darkFg0)),
                if (_vm.userName != '—')
                  Text(_vm.userName,
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.darkFg2)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Company info
          _Section(
            title: 'Company',
            rows: [
              _Row(Icons.business_outlined, 'Name', _vm.clientName),
              if (_vm.clientIndustry.isNotEmpty)
                _Row(Icons.category_outlined, 'Industry', _vm.clientIndustry),
              if (_vm.clientAddress.isNotEmpty)
                _Row(Icons.location_on_outlined, 'Address', _vm.clientAddress),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Contact info
          _Section(
            title: 'Contact',
            rows: [
              _Row(Icons.email_outlined, 'Email', _vm.clientEmail),
              _Row(Icons.phone_outlined, 'Phone', _vm.clientPhone),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Change Password
          _ChangePasswordButton(),
          const SizedBox(height: AppSpacing.md),

          // Logout
          _LogoutButton(),
        ],
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<_Row> rows;
  const _Section({required this.title, required this.rows, super.key});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
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
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.darkFg3, letterSpacing: 0.8)),
          ),
          const Divider(color: AppColors.darkLine, height: 1),
          ...rows,
        ],
      ),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

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
          Icon(icon, size: 16, color: AppColors.darkFg3),
          const SizedBox(width: AppSpacing.sm),
          Text('$label  ',
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.darkFg3)),
          Expanded(
            child: Text(value,
                style:
                    AppTextStyles.bodySm.copyWith(color: AppColors.darkFg1),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ── Buttons ───────────────────────────────────────────────────────────────────

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
              title: Text('Logout',
                  style:
                      AppTextStyles.h3.copyWith(color: AppColors.darkFg0)),
              content: Text('Are you sure?',
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.darkFg1)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.darkFg2)),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.bad),
                  onPressed: () {
                    Navigator.pop(context);
                    context
                        .read<AuthBloc>()
                        .add(const AuthLogoutRequested());
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout, color: AppColors.bad),
        label: Text('Logout',
            style: AppTextStyles.body.copyWith(color: AppColors.bad)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.bad),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm)),
        ),
      ),
    );
  }
}
