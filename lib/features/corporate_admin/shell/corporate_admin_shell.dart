import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/dls/dls.dart';
import '../../../core/auth/bloc/auth_bloc.dart';
import '../../../core/auth/bloc/auth_event.dart';
import '../../../core/auth/bloc/auth_state.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/di/injection.dart';
import '../../../shared/widgets/change_password_sheet.dart';
import '../../../shared/widgets/edit_employee_profile_sheet.dart';
import '../../employee/profile/data/repositories/employee_profile_repository.dart';

const _kCorpNav = [
  (id: 'bookings', label: 'Bookings', icon: Icons.book_online_rounded, route: AppRoutes.corpAdminBookingsPath),
  (id: 'invoices', label: 'Invoices', icon: Icons.receipt_long_rounded, route: AppRoutes.corpAdminInvoicesPath),
  (id: 'reports', label: 'Reports', icon: Icons.bar_chart_rounded, route: AppRoutes.corpAdminReportsPath),
  (id: 'employees', label: 'Employees', icon: Icons.people_rounded, route: AppRoutes.corpAdminEmployeesPath),
];

class CorporateAdminShell extends StatelessWidget {
  final Widget child;
  const CorporateAdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 800) return _DesktopShell(child: child);
    return _MobileShell(child: child);
  }
}

// ── Desktop ───────────────────────────────────────────────────────────────────

class _DesktopShell extends StatelessWidget {
  final Widget child;
  const _DesktopShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      body: Row(
        children: [
          _Sidebar(),
          Expanded(
            child: Column(
              children: [
                _Topbar(),
                Expanded(child: Container(color: AppColors.darkBg1, child: child)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Topbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final name = auth is AuthAuthenticated ? auth.name : 'Corporate Admin';
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.darkBg1,
        border: Border(bottom: BorderSide(color: AppColors.darkLine)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text('Corporate Admin Portal',
              style: AppTextStyles.h3.copyWith(color: AppColors.darkFg2)),
          const Spacer(),
          Text(name, style: AppTextStyles.body.copyWith(color: AppColors.darkFg1)),
          const SizedBox(width: AppSpacing.md),
          const _EditProfileButton(),
          IconButton(
            icon: const Icon(Icons.lock_outline, size: 18, color: AppColors.darkFg2),
            tooltip: 'Change Password',
            onPressed: () => ChangePasswordSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.darkFg2),
            tooltip: 'Logout',
            onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Container(
      width: 220,
      color: AppColors.darkBg0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.darkLine)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppRadii.xs),
                  ),
                  child: const Icon(Icons.directions_car_rounded,
                      size: 16, color: Colors.black),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('Cruzo', style: AppTextStyles.h3.copyWith(color: AppColors.darkFg0)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('MENU',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.darkFg3, letterSpacing: 1.2)),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final item in _kCorpNav)
            _NavItem(
              item: item,
              isActive: location.startsWith(item.route),
              onTap: () => context.go(item.route),
            ),
          const Spacer(),
          const Divider(color: AppColors.darkLine, height: 1),
          _EditProfileTile(),
          ListTile(
            dense: true,
            leading: const Icon(Icons.lock_outline,
                size: 16, color: AppColors.darkFg3),
            title: Text('Change Password',
                style: AppTextStyles.body.copyWith(color: AppColors.darkFg2)),
            onTap: () => ChangePasswordSheet.show(context),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.logout_rounded,
                size: 16, color: AppColors.darkFg3),
            title: Text('Logout',
                style: AppTextStyles.body.copyWith(color: AppColors.darkFg2)),
            onTap: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final ({String id, String label, IconData icon, String route}) item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.item, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withAlpha(25) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Row(
          children: [
            Icon(item.icon,
                size: 16,
                color: isActive ? AppColors.accent : AppColors.darkFg3),
            const SizedBox(width: AppSpacing.sm),
            Text(item.label,
                style: AppTextStyles.body.copyWith(
                    color: isActive ? AppColors.darkFg0 : AppColors.darkFg2,
                    fontWeight: isActive ? FontWeight.w600 : null)),
          ],
        ),
      ),
    );
  }
}

// ── Edit Profile helpers ──────────────────────────────────────────────────────

Future<void> _showEditProfile(BuildContext context) async {
  try {
    final data = await getIt<EmployeeProfileRepository>().fetchProfile();
    if (!context.mounted) return;
    await EditEmployeeProfileSheet.show(
      context,
      currentPhone: data['phone'] as String?,
      currentDepartment: data['department'] as String?,
      onSaved: (_) {},
      onSubmit: getIt<EmployeeProfileRepository>().updateProfile,
    );
  } catch (_) {}
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.darkFg2),
      tooltip: 'Edit Profile',
      onPressed: () => _showEditProfile(context),
    );
  }
}

class _EditProfileTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.edit_outlined, size: 16, color: AppColors.darkFg3),
      title: Text('Edit Profile',
          style: AppTextStyles.body.copyWith(color: AppColors.darkFg2)),
      onTap: () => _showEditProfile(context),
    );
  }
}

// ── Mobile ────────────────────────────────────────────────────────────────────

class _MobileShell extends StatelessWidget {
  final Widget child;
  const _MobileShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex =
        _kCorpNav.indexWhere((e) => location.startsWith(e.route)).clamp(0, _kCorpNav.length - 1);

    return Scaffold(
      backgroundColor: AppColors.darkBg1,
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.darkBg0,
        indicatorColor: AppColors.accent.withAlpha(40),
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(_kCorpNav[i].route),
        destinations: _kCorpNav
            .map((e) => NavigationDestination(
                  icon: Icon(e.icon, color: AppColors.darkFg3),
                  selectedIcon: Icon(e.icon, color: AppColors.accent),
                  label: e.label,
                ))
            .toList(),
      ),
    );
  }
}
