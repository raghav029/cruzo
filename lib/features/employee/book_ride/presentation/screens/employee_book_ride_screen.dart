import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../../core/di/injection.dart';
import '../bloc/book_ride_bloc.dart';
import '../bloc/book_ride_event.dart';
import '../bloc/book_ride_state.dart';
import '../view_models/book_ride_init_view_model.dart';

class EmployeeBookRideScreen extends StatefulWidget {
  const EmployeeBookRideScreen({super.key});

  @override
  State<EmployeeBookRideScreen> createState() => _EmployeeBookRideScreenState();
}

class _EmployeeBookRideScreenState extends State<EmployeeBookRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupCtrl = TextEditingController();
  final _dropCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _vehicleType = 'SEDAN';
  DateTime? _scheduledAt;
  late final BookRideInitViewModel _initVm;

  @override
  void initState() {
    super.initState();
    _initVm = getIt<BookRideInitViewModel>();
    _initVm.load();
  }

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final minDate = now.add(const Duration(hours: 2, minutes: 5));
    final date = await showDatePicker(
      context: context,
      initialDate: minDate,
      firstDate: minDate,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => _datePicker(ctx, child),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(minDate),
      builder: (ctx, child) => _datePicker(ctx, child),
    );
    if (time == null || !mounted) return;
    setState(() {
      _scheduledAt = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Widget _datePicker(BuildContext ctx, Widget? child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.darkBg2,
        ),
      ),
      child: child!,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_initVm.corporateClientId == null) {
      _showError('Employee profile not loaded. Try again.');
      return;
    }
    if (_scheduledAt == null) {
      _showError('Select pickup date & time');
      return;
    }
    if (_scheduledAt!.isBefore(
        DateTime.now().add(const Duration(hours: 2)))) {
      _showError('Pickup must be at least 2 hours from now');
      return;
    }
    context.read<BookRideBloc>().add(BookRideSubmitted(
          corporateClientId: _initVm.corporateClientId!,
          pickupAddress: _pickupCtrl.text.trim(),
          dropAddress: _dropCtrl.text.trim(),
          vehicleType: _vehicleType,
          scheduledAt: _scheduledAt!,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        ));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.bad,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _initVm,
      builder: (context, _) => BlocListener<BookRideBloc, BookRideState>(
      listener: (context, state) {
        if (state is BookRideSuccess) {
          _pickupCtrl.clear();
          _dropCtrl.clear();
          _notesCtrl.clear();
          setState(() {
            _scheduledAt = null;
            _vehicleType = 'SEDAN';
          });
          context.read<BookRideBloc>().add(const BookRideReset());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking submitted! Awaiting approval.'),
              backgroundColor: AppColors.good,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state is BookRideFailure) {
          _showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBg1,
        body: SafeArea(
          child: _initVm.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
              : _initVm.error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, color: AppColors.bad, size: 48),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _initVm.error!,
                              style: AppTextStyles.body.copyWith(color: AppColors.darkFg2),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextButton(
                              onPressed: _initVm.load,
                              child: Text('Retry', style: AppTextStyles.body.copyWith(color: AppColors.accent)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadH,
                    AppSpacing.pagePadV,
                    AppSpacing.pagePadH,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Book a Ride', style: AppTextStyles.h1),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Fill in your trip details',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.darkFg2)),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadH),
                sliver: SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pickup
                        _Label('Pickup Address'),
                        const SizedBox(height: AppSpacing.xs),
                        _Field(
                          controller: _pickupCtrl,
                          hint: 'e.g. Gate 1, Andheri West',
                          icon: Icons.my_location_rounded,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Pickup address required'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Drop
                        _Label('Drop Address'),
                        const SizedBox(height: AppSpacing.xs),
                        _Field(
                          controller: _dropCtrl,
                          hint: 'e.g. Office Park, BKC',
                          icon: Icons.location_on_rounded,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Drop address required'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Vehicle type
                        _Label('Vehicle Type'),
                        const SizedBox(height: AppSpacing.xs),
                        _VehicleTypePicker(
                          selected: _vehicleType,
                          onChanged: (v) => setState(() => _vehicleType = v),
                          disabledTypes: _initVm.allowedVehicleTypes != null
                              ? ['SEDAN', 'SUV', 'LUXURY']
                                  .where((t) => !_initVm.allowedVehicleTypes!.contains(t))
                                  .toList()
                              : const [],
                        ),
                        if (_initVm.maxBookingValue != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.info_outline, size: 14, color: AppColors.darkFg3),
                              const SizedBox(width: 4),
                              Text(
                                'Max fare: ₹${_initVm.maxBookingValue!.toStringAsFixed(0)} (travel policy)',
                                style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg3),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),

                        // Date & time
                        _Label('Pickup Date & Time'),
                        const SizedBox(height: AppSpacing.xs),
                        GestureDetector(
                          onTap: _pickDateTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.cardPadH,
                              vertical: AppSpacing.cardPadV,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.darkBg2,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.sm),
                              border:
                                  Border.all(color: AppColors.darkLine),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 16, color: AppColors.darkFg3),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  _scheduledAt != null
                                      ? _formatDt(_scheduledAt!)
                                      : 'Select date & time',
                                  style: AppTextStyles.body.copyWith(
                                    color: _scheduledAt != null
                                        ? AppColors.darkFg0
                                        : AppColors.darkFg3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Notes
                        _Label('Notes (optional)'),
                        const SizedBox(height: AppSpacing.xs),
                        _Field(
                          controller: _notesCtrl,
                          hint: 'Any special instructions...',
                          icon: Icons.notes_rounded,
                          maxLines: 3,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Submit
                        BlocBuilder<BookRideBloc, BookRideState>(
                          builder: (context, state) {
                            final loading = state is BookRideSubmitting;
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: loading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor:
                                      const Color(0xFF0D2421),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.sm),
                                  ),
                                ),
                                child: loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF0D2421),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text('Submit Booking',
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0D2421),
                                        )),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  String _formatDt(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m $ampm';
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.label.copyWith(color: AppColors.darkFg2),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: AppTextStyles.body.copyWith(color: AppColors.darkFg0),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            AppTextStyles.body.copyWith(color: AppColors.darkFg3),
        prefixIcon: Icon(icon, size: 16, color: AppColors.darkFg3),
        filled: true,
        fillColor: AppColors.darkBg2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadH,
          vertical: AppSpacing.cardPadV,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.darkLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.darkLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.bad),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.bad),
        ),
      ),
    );
  }
}


class _VehicleTypePicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final List<String> disabledTypes;

  const _VehicleTypePicker({
    required this.selected,
    required this.onChanged,
    this.disabledTypes = const [],
  });

  @override
  Widget build(BuildContext context) {
    const types = ['SEDAN', 'SUV', 'LUXURY'];
    const icons = [
      Icons.directions_car_rounded,
      Icons.directions_car_filled_rounded,
      Icons.star_rounded,
    ];

    return Row(
      children: List.generate(types.length, (i) {
        final isSelected = selected == types[i];
        final isDisabled = disabledTypes.contains(types[i]);
        return Expanded(
          child: GestureDetector(
            onTap: isDisabled ? null : () => onChanged(types[i]),
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? AppSpacing.sm : 0),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDisabled
                    ? AppColors.darkBg1
                    : isSelected
                        ? AppColors.accent.withAlpha(30)
                        : AppColors.darkBg2,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(
                  color: isDisabled
                      ? AppColors.darkLine.withAlpha(80)
                      : isSelected ? AppColors.accent : AppColors.darkLine,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icons[i],
                      color: isDisabled
                          ? AppColors.darkFg3.withAlpha(80)
                          : isSelected
                              ? AppColors.accent
                              : AppColors.darkFg3,
                      size: 20),
                  const SizedBox(height: 4),
                  Text(types[i],
                      style: AppTextStyles.caption.copyWith(
                        color: isDisabled
                            ? AppColors.darkFg3.withAlpha(80)
                            : isSelected
                                ? AppColors.accent
                                : AppColors.darkFg3,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      )),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _FieldLoading extends StatelessWidget {
  const _FieldLoading();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
              color: AppColors.accent, strokeWidth: 2),
        ),
      ),
    );
  }
}
