import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/dls/dls.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/theme_service.dart';
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

// ── Desktop: sidebar left + topbar + content ──────────────────────────────────

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
                Expanded(
                  child: Container(color: AppColors.darkBg1, child: child),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Topbar ────────────────────────────────────────────────────────────────────

class _Topbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.darkBg1,
        border: Border(bottom: BorderSide(color: AppColors.darkLine)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Search
          _SearchBar(),
          const SizedBox(width: 12),
          // Theme toggle
          _ThemeToggle(),
          const Spacer(),
          // Notification bell
          _NotificationButton(),
          const SizedBox(width: 8),
          // Separator
          Container(width: 1, height: 20, color: AppColors.darkLine),
          const SizedBox(width: 12),
          // User chip
          _UserChip(),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search_rounded, size: 14, color: AppColors.darkFg3),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: AppTextStyles.body,
              decoration: const InputDecoration(
                hintText: 'Search trips, drivers, bookings…',
                hintStyle: TextStyle(color: AppColors.darkFg3, fontSize: 12.5),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.darkBg3,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.darkLine),
            ),
            child: const Text(
              '⌘K',
              style: TextStyle(
                fontSize: 10.5,
                color: AppColors.darkFg3,
                fontFamily: 'SF Mono',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final service = getIt<ThemeService>();
    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final isDark = service.isDark;
        return IconButton(
          icon: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: AppColors.darkFg2,
          ),
          onPressed: () => service.toggle(),
          tooltip: isDark ? 'Switch to light' : 'Switch to dark',
        );
      },
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 18,
              color: AppColors.darkFg2,
            ),
            onPressed: () {},
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Notification dot
          Positioned(
            top: 6,
            right: 5,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.bad,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.darkBg1, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.accentBg,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'RK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Raj Kumar',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkFg0,
                ),
              ),
              Text(
                'Fleet manager',
                style: TextStyle(fontSize: 10.5, color: AppColors.darkFg3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Mobile: AppBar + Drawer ───────────────────────────────────────────────────

class _MobileShell extends StatelessWidget {
  final Widget child;
  const _MobileShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg1,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0,
        foregroundColor: AppColors.darkFg0,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accent, AppColors.accentDim],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'C',
                  style: TextStyle(
                    color: Color(0xFF0D2421),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Cruzo',
              style: TextStyle(
                color: AppColors.darkFg0,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: AppColors.darkFg2,
                ),
                onPressed: () {},
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.bad,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.darkBg0, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.darkBg0,
        child: _SidebarContent(),
      ),
      body: child,
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      decoration: const BoxDecoration(
        color: AppColors.darkBg0,
        border: Border(right: BorderSide(color: AppColors.darkLine)),
      ),
      child: _SidebarContent(),
    );
  }
}

const _kNav = [
  (
    group: 'Operate',
    items: [
      (
        id: 'overview',
        label: 'Overview',
        icon: Icons.dashboard_rounded,
        route: AppRoutes.fleetDashboardPath,
        badge: 0,
        alert: false,
      ),
      (
        id: 'bookings',
        label: 'Bookings',
        icon: Icons.book_online_rounded,
        route: AppRoutes.fleetBookingsPath,
        badge: 4,
        alert: false,
      ),
      (
        id: 'dailytrips',
        label: 'Daily trips',
        icon: Icons.route_rounded,
        route: AppRoutes.fleetDailyTripsPath,
        badge: 0,
        alert: true,
      ),
      (
        id: 'schedules',
        label: 'Daily schedules',
        icon: Icons.repeat_rounded,
        route: AppRoutes.fleetDailySchedulesPath,
        badge: 0,
        alert: false,
      ),
    ],
  ),
  (
    group: 'Fleet',
    items: [
      (
        id: 'drivers',
        label: 'Drivers',
        icon: Icons.badge_outlined,
        route: AppRoutes.fleetDriversPath,
        badge: 0,
        alert: false,
      ),
      (
        id: 'vehicles',
        label: 'Vehicles',
        icon: Icons.directions_car_outlined,
        route: AppRoutes.fleetVehiclesPath,
        badge: 0,
        alert: false,
      ),
      (
        id: 'clients',
        label: 'Corporate clients',
        icon: Icons.business_rounded,
        route: AppRoutes.fleetClientsPath,
        badge: 0,
        alert: false,
      ),
    ],
  ),
  (
    group: 'Finance',
    items: [
      (
        id: 'invoices',
        label: 'Invoices',
        icon: Icons.receipt_long_outlined,
        route: AppRoutes.fleetInvoicesPath,
        badge: 0,
        alert: false,
      ),
      (
        id: 'reports',
        label: 'Reports',
        icon: Icons.bar_chart_rounded,
        route: AppRoutes.fleetReportsPath,
        badge: 0,
        alert: false,
      ),
    ],
  ),
  (
    group: 'Alerts',
    items: [
      (
        id: 'sos',
        label: 'SOS alerts',
        icon: Icons.sos_rounded,
        route: AppRoutes.fleetSosAlertsPath,
        badge: 0,
        alert: false,
      ),
      (
        id: 'documents',
        label: 'Documents',
        icon: Icons.description_outlined,
        route: AppRoutes.fleetDocumentsPath,
        badge: 0,
        alert: false,
      ),
    ],
  ),
];

class _SidebarContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accent, AppColors.accentDim],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withAlpha(60),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'C',
                    style: TextStyle(
                      color: Color(0xFF0D2421),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cruzo',
                    style: TextStyle(
                      color: AppColors.darkFg0,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Fleet console',
                    style: TextStyle(
                      color: AppColors.darkFg3.withAlpha(200),
                      fontSize: 10.5,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Nav groups
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              for (final group in _kNav) ...[
                _NavSection(label: group.group),
                for (final item in group.items)
                  _NavItem(
                    icon: item.icon,
                    label: item.label,
                    route: item.route,
                    location: location,
                    badge: item.badge,
                    alert: item.alert,
                  ),
              ],
            ],
          ),
        ),

        // Footer
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          height: 1,
          color: AppColors.darkLine,
        ),
        _NavItem(
          icon: Icons.logout_rounded,
          label: 'Logout',
          route: '',
          location: location,
          onTap: () => context.go(AppRoutes.loginPath),
        ),
        // Status line
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 16, 16),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.good,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.good.withAlpha(80),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'All systems operational',
                style: TextStyle(fontSize: 10.5, color: AppColors.darkFg3),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: AppColors.darkFg3,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String location;
  final int badge;
  final bool alert;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.location,
    this.badge = 0,
    this.alert = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = route.isNotEmpty && location.startsWith(route);

    return InkWell(
      onTap: onTap ?? () => context.go(route),
      highlightColor: AppColors.darkBg3.withAlpha(80),
      splashColor: AppColors.darkBg3.withAlpha(60),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        decoration: BoxDecoration(
          color: isActive ? AppColors.darkBg2 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isActive ? AppColors.darkFg0 : AppColors.darkFg2,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: isActive ? AppColors.darkFg0 : AppColors.darkFg2,
                        fontWeight: isActive
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (badge > 0) _Badge(label: '$badge', isAlert: false),
                  if (alert) _Badge(label: '!', isAlert: true),
                ],
              ),
            ),
            if (isActive)
              Positioned(
                left: 0,
                top: 7,
                bottom: 7,
                child: Container(
                  width: 3,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(3),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final bool isAlert;
  const _Badge({required this.label, required this.isAlert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: isAlert ? AppColors.bad.withAlpha(48) : AppColors.darkBg3,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: isAlert ? AppColors.bad : AppColors.darkFg2,
        ),
      ),
    );
  }
}
