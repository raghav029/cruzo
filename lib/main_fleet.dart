import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/auth/bloc/auth_bloc.dart';
import 'core/auth/bloc/auth_event.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:cruzo/features/fleet_manager/dashboard/presentation/bloc/dashboard_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDI();
  runApp(const CruzoFleetApp());
}

class CruzoFleetApp extends StatefulWidget {
  const CruzoFleetApp({super.key});

  @override
  State<CruzoFleetApp> createState() => _CruzoFleetAppState();
}

class _CruzoFleetAppState extends State<CruzoFleetApp> {
  late final AuthBloc _authBloc;
  late final _router;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>()..add(const AuthCheckRequested());
    _router = createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider(create: (_) => getIt<DashboardBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Cruzo Fleet',
        theme: AppTheme.light,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
