import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/dls/dls.dart';
import '../../../core/router/app_routes.dart';

class EmployeeShell extends StatelessWidget {
  final Widget child;
  const EmployeeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith(AppRoutes.employeeBookRidePath)) {
      currentIndex = 1;
    } else if (location.startsWith(AppRoutes.employeeMyTripsPath)) {
      currentIndex = 2;
    } else if (location.startsWith(AppRoutes.employeeDailySchedulePath)) {
      currentIndex = 3;
    } else if (location.startsWith(AppRoutes.employeeProfilePath)) {
      currentIndex = 4;
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
                context.go(AppRoutes.employeeHomePath);
              case 1:
                context.go(AppRoutes.employeeBookRidePath);
              case 2:
                context.go(AppRoutes.employeeMyTripsPath);
              case 3:
                context.go(AppRoutes.employeeDailySchedulePath);
              case 4:
                context.go(AppRoutes.employeeProfilePath);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              activeIcon: Icon(Icons.add_circle_rounded),
              label: 'Book',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'My Trips',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus_outlined),
              activeIcon: Icon(Icons.directions_bus_rounded),
              label: 'Roster',
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
