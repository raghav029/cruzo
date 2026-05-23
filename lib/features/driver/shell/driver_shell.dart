import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/dls/dls.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/di/injection.dart';
import '../../fleet_manager/sos_alerts/domain/sos_alert_repo.dart';

class DriverShell extends StatelessWidget {
  final Widget child;
  const DriverShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith(AppRoutes.driverStatsPath)) {
      currentIndex = 1;
    } else if (location.startsWith(AppRoutes.driverTripHistoryPath)) {
      currentIndex = 2;
    } else if (location.startsWith(AppRoutes.driverProfilePath)) {
      currentIndex = 3;
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg1,
      body: child,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        mini: true,
        onPressed: () => _showSosDialog(context),
        child: const Icon(Icons.sos_rounded, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.darkBg0,
          border: Border(top: BorderSide(color: AppColors.darkLine)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.darkFg3,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          onTap: (i) {
            switch (i) {
              case 0:
                context.go(AppRoutes.driverMyTripPath);
              case 1:
                context.go(AppRoutes.driverStatsPath);
              case 2:
                context.go(AppRoutes.driverTripHistoryPath);
              case 3:
                context.go(AppRoutes.driverProfilePath);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car_outlined),
              activeIcon: Icon(Icons.directions_car_rounded),
              label: 'My Trip',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

void _showSosDialog(BuildContext context) {
  final ctrl = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.darkBg2,
      title: Text(
        'Send SOS Alert',
        style: AppTextStyles.h3.copyWith(color: AppColors.darkFg0),
      ),
      content: TextField(
        controller: ctrl,
        style: AppTextStyles.body.copyWith(color: AppColors.darkFg0),
        decoration: InputDecoration(
          hintText: 'Describe your emergency (optional)',
          hintStyle: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg3),
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
        maxLines: 2,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            'Cancel',
            style: AppTextStyles.body.copyWith(color: AppColors.darkFg2),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.pop(ctx);
            await getIt<SosAlertRepo>().send(
              ctrl.text.trim().isEmpty
                  ? 'SOS from driver'
                  : ctrl.text.trim(),
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SOS alert sent'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Send SOS'),
        ),
      ],
    ),
  );
}
