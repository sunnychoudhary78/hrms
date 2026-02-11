import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/home/presentation/widgets/app_drawer.dart';
import 'package:lms/shared/widgets/app_bar.dart';
import '../providers/leave_apply_provider.dart';
import '../providers/leave_balance_provider.dart';
import '../widgets/leave_type_dropdown.dart';
import '../widgets/date_range_picker.dart';
import '../widgets/reason_input.dart';
import '../widgets/submit_button.dart';
import '../../data/models/leave_balance_model.dart';

enum DayType { full, half }

enum HalfDayPart { am, pm }

class LeaveApplyScreen extends ConsumerStatefulWidget {
  const LeaveApplyScreen({super.key});

  @override
  ConsumerState<LeaveApplyScreen> createState() => _LeaveApplyScreenState();
}

class _LeaveApplyScreenState extends ConsumerState<LeaveApplyScreen> {
  LeaveBalance? selectedLeave;
  DateTime? fromDate;
  DateTime? toDate;
  DayType dayType = DayType.full;
  HalfDayPart? halfDayPart;
  String reason = '';
  File? document;

  bool get isDocumentRequired {
    if (selectedLeave == null) return false;
    final name = selectedLeave!.name.toLowerCase();
    return name.contains('maternity') || name.contains('paternity');
  }

  Future<void> _submit() async {
    if (selectedLeave == null ||
        fromDate == null ||
        toDate == null ||
        reason.isEmpty) {
      _showError("Please fill all required fields");
      return;
    }

    if (dayType == DayType.half && halfDayPart == null) {
      _showError("Please select AM or PM for half day");
      return;
    }

    if (isDocumentRequired && document == null) {
      _showError("Document is required for this leave type");
      return;
    }

    await ref
        .read(leaveApplyProvider.notifier)
        .submitLeave(
          data: {
            "leaveTypeId": selectedLeave!.leaveTypeId,
            "startDate": fromDate!.toIso8601String(),
            "endDate": toDate!.toIso8601String(),
            "reason": reason,
            "isHalfDay": dayType == DayType.half,
            "halfDayPart": dayType == DayType.half
                ? halfDayPart!.name.toUpperCase()
                : null,
          },
          document: document,
        );

    if (mounted) Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final balanceAsync = ref.watch(leaveBalanceProvider);
    final applyState = ref.watch(leaveApplyProvider);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      resizeToAvoidBottomInset: true,
      appBar: const AppAppBar(
        title: "Apply Leave",
        showBack: false, // 👈 Root screen → no back button
      ),
      drawer: AppDrawer(),
      body: balanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (leaves) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          children: [
            _SectionCard(
              title: "Leave Type",
              child: LeaveTypeDropdown(
                leaves: leaves,
                selected: selectedLeave,
                onChanged: (leave) => setState(() => selectedLeave = leave),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: "Duration",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DayTypeSelector(
                    value: dayType,
                    onChanged: (v) {
                      setState(() {
                        dayType = v;
                        halfDayPart = null;
                        if (dayType == DayType.half && fromDate != null) {
                          toDate = fromDate;
                        }
                      });
                    },
                  ),
                  if (dayType == DayType.half) ...[
                    const SizedBox(height: 12),
                    _HalfDaySelector(
                      value: halfDayPart,
                      onChanged: (v) => setState(() => halfDayPart = v),
                    ),
                  ],
                  const SizedBox(height: 16),
                  DateRangePicker(
                    from: fromDate,
                    to: toDate,
                    onFromPick: (d) {
                      setState(() {
                        fromDate = d;
                        if (dayType == DayType.half) {
                          toDate = d;
                        }
                      });
                    },
                    onToPick: (d) {
                      setState(() {
                        toDate = d;
                        if (fromDate != null && d != fromDate) {
                          dayType = DayType.full;
                          halfDayPart = null;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: "Reason",
              child: ReasonInput(onChanged: (v) => reason = v),
            ),
            if (isDocumentRequired) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: "Supporting Document",
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    document == null ? "Attach Document" : "Document Selected",
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: SubmitButton(
            isLoading: applyState.isLoading,
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}

/// ===========================================================
/// ==================== SUPPORT WIDGETS =======================
/// ===========================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _DayTypeSelector extends StatelessWidget {
  final DayType value;
  final ValueChanged<DayType> onChanged;

  const _DayTypeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DayType>(
      segments: const [
        ButtonSegment(value: DayType.full, label: Text("Full Day")),
        ButtonSegment(value: DayType.half, label: Text("Half Day")),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _HalfDaySelector extends StatelessWidget {
  final HalfDayPart? value;
  final ValueChanged<HalfDayPart> onChanged;

  const _HalfDaySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: [
        ChoiceChip(
          label: const Text("AM"),
          selected: value == HalfDayPart.am,
          onSelected: (_) => onChanged(HalfDayPart.am),
        ),
        ChoiceChip(
          label: const Text("PM"),
          selected: value == HalfDayPart.pm,
          onSelected: (_) => onChanged(HalfDayPart.pm),
        ),
      ],
    );
  }
}
