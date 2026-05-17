import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/di/injection.dart';
import 'core/auth/bloc/auth_bloc.dart';
import 'core/auth/bloc/auth_event.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  final storedRole = await storage.read(key: 'user_role');
  if (storedRole != null && storedRole != 'CORPORATE_ADMIN') {
    await storage.deleteAll();
  }
  setupDI();
  runApp(const CruzoCorpAdminApp());
}

class CruzoCorpAdminApp extends StatefulWidget {
  const CruzoCorpAdminApp({super.key});

  @override
  State<CruzoCorpAdminApp> createState() => _CruzoCorpAdminAppState();
}

class _CruzoCorpAdminAppState extends State<CruzoCorpAdminApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;
  late final ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>()..add(const AuthCheckRequested());
    _router = createRouter(_authBloc);
    _themeService = getIt<ThemeService>();
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: AnimatedBuilder(
        animation: _themeService,
        builder: (context, _) {
          return MaterialApp.router(
            title: 'Cruzo Admin',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _themeService.mode,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
