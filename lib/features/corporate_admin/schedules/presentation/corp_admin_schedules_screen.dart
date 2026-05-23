import 'package:flutter/material.dart';
import 'package:cruzo/core/network/result.dart';
import 'package:cruzo/core/theme/dls/dls.dart';
import 'corp_admin_schedules_view_model.dart';
import 'package:cruzo/features/fleet_manager/daily_schedules/domain/daily_schedule_models.dart';

class CorpAdminSchedulesScreen extends StatefulWidget {
  const CorpAdminSchedulesScreen({super.key, required this.viewModel});
  final CorpAdminSchedulesViewModel viewModel;

  @override
  State<CorpAdminSchedulesScreen> createState() => _CorpAdminSchedulesScreenState();
}

class _CorpAdminSchedulesScreenState extends State<CorpAdminSchedulesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        return Scaffold(
          backgroundColor: AppColors.darkBg1,
          appBar: AppBar(
            backgroundColor: AppColors.darkBg1,
            elevation: 0,
            title: Text('Daily Schedules', style: AppTextStyles.h2.copyWith(color: AppColors.darkFg1)),
            iconTheme: const IconThemeData(color: AppColors.darkFg1),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.accent,
            onPressed: () => _showCreateSheet(context),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text('New Schedule', style: AppTextStyles.body.copyWith(color: Colors.white)),
          ),
          body: _buildBody(context, vm),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CorpAdminSchedulesViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }
    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.error!, style: AppTextStyles.body.copyWith(color: AppColors.darkFg3)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: vm.load,
              child: Text('Retry', style: AppTextStyles.body.copyWith(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    if (vm.schedules.isEmpty) {
      return Center(
        child: Text('No schedules yet', style: AppTextStyles.body.copyWith(color: AppColors.darkFg3)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: vm.schedules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final s = vm.schedules[i];
        return _ScheduleCard(
          schedule: s,
          onTap: () => _showPassengersSheet(context, s),
        );
      },
    );
  }

  void _showPassengersSheet(BuildContext context, DailySchedule schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkBg0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        builder: (ctx, scrollController) => _PassengersSheet(
          schedule: schedule,
          viewModel: widget.viewModel,
          scrollController: scrollController,
          onEnroll: () => _showEnrollSheet(context, schedule),
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkBg0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _CreateScheduleSheet(viewModel: widget.viewModel),
    );
  }

  void _showEnrollSheet(BuildContext context, DailySchedule schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkBg0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _EnrollSheet(schedule: schedule, viewModel: widget.viewModel),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.schedule, required this.onTap});
  final DailySchedule schedule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dayAbbr = {
      'MON': 'Mon', 'TUE': 'Tue', 'WED': 'Wed',
      'THU': 'Thu', 'FRI': 'Fri', 'SAT': 'Sat', 'SUN': 'Sun',
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkBg0,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(schedule.name, style: AppTextStyles.h2.copyWith(color: AppColors.darkFg1)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: schedule.isActive
                        ? AppColors.accent.withOpacity(0.2)
                        : AppColors.darkLine.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    schedule.isActive ? 'Active' : 'Inactive',
                    style: AppTextStyles.caption.copyWith(
                      color: schedule.isActive ? AppColors.accent : AppColors.darkFg3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: schedule.recurrenceDays.map((d) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.darkBg1,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.darkLine),
                  ),
                  child: Text(
                    dayAbbr[d] ?? d,
                    style: AppTextStyles.caption.copyWith(color: AppColors.darkFg2),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: AppColors.darkFg3),
                const SizedBox(width: 4),
                Text(schedule.pickupTime, style: AppTextStyles.caption.copyWith(color: AppColors.darkFg2)),
                const SizedBox(width: 16),
                const Icon(Icons.people_outline, size: 14, color: AppColors.darkFg3),
                const SizedBox(width: 4),
                Text(
                  '${schedule.enrolledPassengerCount}/${schedule.maxCapacity}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.darkFg2),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.darkFg3),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    schedule.dropAddress,
                    style: AppTextStyles.caption.copyWith(color: AppColors.darkFg3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PassengersSheet extends StatefulWidget {
  const _PassengersSheet({
    required this.schedule,
    required this.viewModel,
    required this.scrollController,
    required this.onEnroll,
  });
  final DailySchedule schedule;
  final CorpAdminSchedulesViewModel viewModel;
  final ScrollController scrollController;
  final VoidCallback onEnroll;

  @override
  State<_PassengersSheet> createState() => _PassengersSheetState();
}

class _PassengersSheetState extends State<_PassengersSheet> {
  List<DailySchedulePassenger>? _passengers;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.viewModel.loadPassengers(widget.schedule.id);
    switch (result) {
      case Success(:final value):
        setState(() { _passengers = value; _loading = false; });
      case Failure(:final message):
        setState(() { _error = message; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkLine,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.schedule.name,
                  style: AppTextStyles.h2.copyWith(color: AppColors.darkFg1),
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                onPressed: () async {
                  widget.onEnroll();
                  await Future.delayed(const Duration(milliseconds: 500));
                  _load();
                },
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                label: Text('Enroll Employee', style: AppTextStyles.caption.copyWith(color: AppColors.accent)),
              ),
            ],
          ),
          Divider(color: AppColors.darkLine, height: 24),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: AppTextStyles.body.copyWith(color: AppColors.darkFg3)),
      );
    }
    if (_passengers == null || _passengers!.isEmpty) {
      return Center(
        child: Text('No employees enrolled yet',
            style: AppTextStyles.body.copyWith(color: AppColors.darkFg3)),
      );
    }
    return ListView.separated(
      controller: widget.scrollController,
      itemCount: _passengers!.length,
      separatorBuilder: (_, __) => Divider(color: AppColors.darkLine, height: 1),
      itemBuilder: (context, i) {
        final p = _passengers![i];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(p.employeeName, style: AppTextStyles.body.copyWith(color: AppColors.darkFg1)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.employeeEmail, style: AppTextStyles.caption.copyWith(color: AppColors.darkFg2)),
              Text(p.pickupAddress, style: AppTextStyles.caption.copyWith(color: AppColors.darkFg3)),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
            onPressed: () async {
              final ok = await widget.viewModel.removePassenger(widget.schedule.id, p.id);
              if (ok) _load();
            },
          ),
        );
      },
    );
  }
}

class _CreateScheduleSheet extends StatefulWidget {
  const _CreateScheduleSheet({required this.viewModel});
  final CorpAdminSchedulesViewModel viewModel;

  @override
  State<_CreateScheduleSheet> createState() => _CreateScheduleSheetState();
}

class _CreateScheduleSheetState extends State<_CreateScheduleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dropCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '4');
  final _timeCtrl = TextEditingController();

  String _vehicleType = 'SEDAN';
  final List<String> _days = [];
  bool _isPooled = false;

  static const _allDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dropCtrl.dispose();
    _capacityCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      _timeCtrl.text = '$h:$m';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one day')),
      );
      return;
    }
    final ok = await widget.viewModel.createSchedule(
      name: _nameCtrl.text.trim(),
      vehicleType: _vehicleType,
      recurrenceDays: _days,
      pickupTime: _timeCtrl.text.trim(),
      dropAddress: _dropCtrl.text.trim(),
      isPooled: _isPooled,
      maxCapacity: _isPooled ? int.tryParse(_capacityCtrl.text) ?? 4 : 1,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.viewModel.mutationError ?? 'Failed to create schedule')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.darkLine,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('New Schedule', style: AppTextStyles.h2.copyWith(color: AppColors.darkFg1)),
              const SizedBox(height: 16),
              _field(_nameCtrl, 'Schedule Name', required: true),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _vehicleType,
                dropdownColor: AppColors.darkBg0,
                style: AppTextStyles.body.copyWith(color: AppColors.darkFg1),
                decoration: _inputDecoration('Vehicle Type'),
                items: ['SEDAN', 'SUV', 'LUXURY']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) => setState(() => _vehicleType = v!),
              ),
              const SizedBox(height: 12),
              Text('Recurrence Days', style: AppTextStyles.caption.copyWith(color: AppColors.darkFg2)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _allDays.map((d) {
                  final selected = _days.contains(d);
                  return FilterChip(
                    label: Text(d, style: AppTextStyles.caption.copyWith(
                      color: selected ? Colors.white : AppColors.darkFg2,
                    )),
                    selected: selected,
                    selectedColor: AppColors.accent,
                    backgroundColor: AppColors.darkBg1,
                    checkmarkColor: Colors.white,
                    side: BorderSide(color: selected ? AppColors.accent : AppColors.darkLine),
                    onSelected: (v) => setState(() {
                      if (v) _days.add(d); else _days.remove(d);
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeCtrl,
                readOnly: true,
                style: AppTextStyles.body.copyWith(color: AppColors.darkFg1),
                decoration: _inputDecoration('Pickup Time (HH:mm)'),
                onTap: _pickTime,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _field(_dropCtrl, 'Drop Address', required: true),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Pooled Ride', style: AppTextStyles.body.copyWith(color: AppColors.darkFg1)),
                value: _isPooled,
                activeColor: AppColors.accent,
                onChanged: (v) => setState(() => _isPooled = v),
              ),
              if (_isPooled) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _capacityCtrl,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.body.copyWith(color: AppColors.darkFg1),
                  decoration: _inputDecoration('Max Capacity (1–12)'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1 || n > 12) return 'Enter 1–12';
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              ListenableBuilder(
                listenable: widget.viewModel,
                builder: (_, __) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: widget.viewModel.isMutating ? null : _submit,
                    child: widget.viewModel.isMutating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Create Schedule', style: AppTextStyles.body.copyWith(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, {bool required = false}) {
    return TextFormField(
      controller: ctrl,
      style: AppTextStyles.body.copyWith(color: AppColors.darkFg1),
      decoration: _inputDecoration(label),
      validator: required ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.caption.copyWith(color: AppColors.darkFg3),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.darkLine),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.accent),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: AppColors.darkBg1,
    );
  }
}

class _EnrollSheet extends StatefulWidget {
  const _EnrollSheet({required this.schedule, required this.viewModel});
  final DailySchedule schedule;
  final CorpAdminSchedulesViewModel viewModel;

  @override
  State<_EnrollSheet> createState() => _EnrollSheetState();
}

class _EnrollSheetState extends State<_EnrollSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await widget.viewModel.enrollPassenger(
      widget.schedule.id,
      employeeEmail: _emailCtrl.text.trim(),
      pickupAddress: _addressCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.viewModel.mutationError ?? 'Failed to enroll employee')),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.caption.copyWith(color: AppColors.darkFg3),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.darkLine),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.accent),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: AppColors.darkBg1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkLine,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Enroll Employee', style: AppTextStyles.h2.copyWith(color: AppColors.darkFg1)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: AppTextStyles.body.copyWith(color: AppColors.darkFg1),
              decoration: _inputDecoration('Employee Email'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressCtrl,
              style: AppTextStyles.body.copyWith(color: AppColors.darkFg1),
              decoration: _inputDecoration('Pickup Address'),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: widget.viewModel,
              builder: (_, __) => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: widget.viewModel.isMutating ? null : _submit,
                  child: widget.viewModel.isMutating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Enroll', style: AppTextStyles.body.copyWith(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
