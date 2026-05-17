import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/dls/dls.dart';
import '../../../core/router/app_routes.dart';

class DriverShell extends StatelessWidget {
  final Widget child;
  const DriverShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith(AppRoutes.driverTripHistoryPath)) {
      currentIndex = 1;
    } else if (location.startsWith(AppRoutes.driverProfilePath)) {
      currentIndex = 2;
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg1,
      body: child,
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
                context.go(AppRoutes.driverTripHistoryPath);
              case 2:
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
