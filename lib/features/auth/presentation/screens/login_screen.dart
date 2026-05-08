import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cruzo/core/router/app_routes.dart';
import '../../../../core/auth/bloc/auth_bloc.dart';
import '../../../../core/auth/bloc/auth_event.dart';
import '../../../../core/auth/bloc/auth_state.dart';
import '../../../../core/theme/dls/dls.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final route = switch (state.role) {
            AppRole.fleetManager => AppRoutes.fleetDashboardPath,
            AppRole.employee => AppRoutes.employeeHomePath,
            AppRole.driver => AppRoutes.driverMyTripPath,
            _ => AppRoutes.fleetDashboardPath,
          };
          context.go(route);
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.bad,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBg0,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand mark — matches .brand-mark in CSS
                  Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.accent, AppColors.accentDim],
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        boxShadow: AppShadows.brandMark,
                      ),
                      child: const Center(
                        child: Text(
                          'C',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentFg,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p12),
                  const Center(
                    child: Text(
                      'Cruzo',
                      style: AppTypography.brandName,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p4),
                  Center(
                    child: Text(
                      'Fleet console',
                      style: AppTypography.captionSm.copyWith(
                        color: AppColors.darkFg3,
                        letterSpacing: 0.04 * 10.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p48),

                  // Sign-in card — .card pattern from CSS
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.cardPadH),
                    decoration: BoxDecoration(
                      color: AppColors.darkBg2,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: AppColors.darkLine),
                      boxShadow: AppShadows.shadow1Dark,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card header — .card-head pattern
                          Text(
                            'Sign in to your account',
                            style: AppTypography.sectionTitle.copyWith(
                              color: AppColors.darkFg0,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.p4),
                          Text(
                            'Corporate Car Booking Platform',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.darkFg3,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.p24),

                          // Email field
                          _FieldLabel(label: 'Email'),
                          const SizedBox(height: AppSpacing.p5),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: AppTypography.body.copyWith(
                                color: AppColors.darkFg0),
                            decoration: const InputDecoration(
                              hintText: 'you@company.com',
                              prefixIcon: Icon(Icons.email_outlined, size: 16),
                            ),
                            validator: (v) => v == null || !v.contains('@')
                                ? 'Enter a valid email'
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.p16),

                          // Password field
                          _FieldLabel(label: 'Password'),
                          const SizedBox(height: AppSpacing.p5),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            style: AppTypography.body.copyWith(
                                color: AppColors.darkFg0),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline, size: 16),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 16,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Enter your password' : null,
                          ),
                          const SizedBox(height: AppSpacing.p28),

                          // Primary button — .btn.primary pattern
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final loading = state is AuthLoading;
                              return ElevatedButton(
                                onPressed: loading ? null : _submit,
                                child: loading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.accentFg,
                                        ),
                                      )
                                    : const Text('Sign in'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  const SizedBox(height: AppSpacing.p24),
                  Center(
                    child: Text(
                      'v1.0.0 · Cruzo Fleet',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.darkFg3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.labelXs.copyWith(
        color: AppColors.darkFg2,
        letterSpacing: 0,
      ),
    );
  }
}
