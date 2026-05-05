import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/router/app_routes.dart';

class FleetShell extends StatelessWidget {
  final Widget child;
  const FleetShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 800) return _DesktopShell(child: child);
    return _MobileShell(child: child);
  }
}

class _DesktopShell extends StatelessWidget {
  final Widget child;
  const _DesktopShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {
  final Widget child;
  const _MobileShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cruzo Fleet', style: AppTextStyles.h4)),
      drawer: Drawer(child: _SidebarContent()),
      body: child,
    );
  }
}

class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppColors.sidebarBg,
      child: _SidebarContent(),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Column(
      children: [
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Cruzo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Fleet Manager',
            style: AppTextStyles.caption.copyWith(color: AppColors.sidebarText),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _NavItem(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                route: AppRoutes.fleetDashboardPath,
                currentLocation: location,
              ),
              _NavSection(label: 'OPERATIONS'),
              _NavItem(
                icon: Icons.book_online_rounded,
                label: 'Bookings',
                route: AppRoutes.fleetBookingsPath,
                currentLocation: location,
              ),
              _NavItem(
                icon: Icons.calendar_today_rounded,
                label: 'Daily Trips',
                route: AppRoutes.fleetDailyTripsPath,
                currentLocation: location,
              ),
              _NavItem(
                icon: Icons.repeat_rounded,
                label: 'Daily Schedules',
                route: AppRoutes.fleetDailySchedulesPath,
                currentLocation: location,
              ),
              _NavSection(label: 'FLEET'),
              _NavItem(
                icon: Icons.directions_car_outlined,
                label: 'Vehicles',
                route: AppRoutes.fleetVehiclesPath,
                currentLocation: location,
              ),
              _NavItem(
                icon: Icons.badge_outlined,
                label: 'Drivers',
                route: AppRoutes.fleetDriversPath,
                currentLocation: location,
              ),
              _NavItem(
                icon: Icons.business_rounded,
                label: 'Corporate Clients',
                route: AppRoutes.fleetClientsPath,
                currentLocation: location,
              ),
              _NavSection(label: 'FINANCE'),
              _NavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Invoices',
                route: AppRoutes.fleetInvoicesPath,
                currentLocation: location,
              ),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Reports',
                route: AppRoutes.fleetReportsPath,
                currentLocation: location,
              ),
              _NavSection(label: 'ALERTS'),
              _NavItem(
                icon: Icons.sos_rounded,
                label: 'SOS Alerts',
                route: AppRoutes.fleetSosAlertsPath,
                currentLocation: location,
              ),
              _NavItem(
                icon: Icons.description_outlined,
                label: 'Documents',
                route: AppRoutes.fleetDocumentsPath,
                currentLocation: location,
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.sidebarActive),
        _NavItem(
          icon: Icons.logout_rounded,
          label: 'Logout',
          route: '',
          currentLocation: location,
          onTap: () => context.go(AppRoutes.loginPath),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _NavSection extends StatelessWidget {
  final String label;
  const _NavSection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 4),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.sidebarText.withAlpha(128),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentLocation;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentLocation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = route.isNotEmpty && currentLocation.startsWith(route);

    return InkWell(
      onTap: onTap ?? () => context.go(route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.sidebarActive : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? AppColors.sidebarTextActive
                  : AppColors.sidebarText,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isActive
                    ? AppColors.sidebarTextActive
                    : AppColors.sidebarText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
