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
      _showError("Please select AM or PM");
      return;
    }

    if (isDocumentRequired && document == null) {
      _showError("Document required for this leave");
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
      appBar: const AppAppBar(title: "Apply Leave", showBack: false),
      drawer: AppDrawer(),

      body: balanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),

        data: (leaves) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          children: [
            /// SINGLE MAIN CARD
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// LEAVE TYPE
                    _SectionTitle("Leave Type"),

                    LeaveTypeDropdown(
                      leaves: leaves,
                      selected: selectedLeave,
                      onChanged: (leave) =>
                          setState(() => selectedLeave = leave),
                    ),

                    const SizedBox(height: 24),

                    /// DURATION
                    _SectionTitle("Duration"),

                    const SizedBox(height: 8),

                    _DayTypeSelector(
                      value: dayType,
                      onChanged: (v) {
                        setState(() {
                          dayType = v;
                          halfDayPart = null;

                          if (v == DayType.half && fromDate != null) {
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

                          if (fromDate != d) {
                            dayType = DayType.full;
                            halfDayPart = null;
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    /// REASON
                    _SectionTitle("Reason"),

                    ReasonInput(onChanged: (v) => reason = v),

                    if (isDocumentRequired) ...[
                      const SizedBox(height: 24),

                      _SectionTitle("Supporting Document"),

                      OutlinedButton.icon(
                        icon: const Icon(Icons.attach_file),
                        label: Text(
                          document == null
                              ? "Attach Document"
                              : "Document Selected",
                        ),
                        onPressed: () {},
                      ),
                    ],

                    const SizedBox(height: 28),

                    /// SUBMIT BUTTON INSIDE CARD
                    SubmitButton(
                      isLoading: applyState.isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CLEAN SECTION TITLE
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
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
