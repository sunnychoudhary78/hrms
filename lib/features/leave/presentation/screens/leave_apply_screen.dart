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

  /// ✅ CRITICAL FIX: correct backend date format
  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  double _calculateLeaveDays() {
    if (fromDate == null || toDate == null) return 0;

    if (dayType == DayType.half) {
      return 0.5;
    }

    final diff = toDate!.difference(fromDate!).inDays + 1;

    return diff.toDouble();
  }

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

    /// ✅ NEW: LEAVE BALANCE VALIDATION
    final requestedDays = _calculateLeaveDays();
    final availableDays = selectedLeave!.available;

    debugPrint("Requested days: $requestedDays");
    debugPrint("Available days: $availableDays");

    /// Fix floating precision issues
    if (requestedDays > availableDays + 0.001) {
      final formattedAvailable = availableDays % 1 == 0
          ? availableDays.toInt().toString()
          : availableDays.toString();

      _showError(
        "You only have $formattedAvailable ${selectedLeave!.name} remaining",
      );

      return;
    }

    final requestData = <String, dynamic>{
      "leaveTypeId": selectedLeave!.leaveTypeId,
      "startDate": _formatDate(fromDate!),
      "endDate": _formatDate(toDate!),
      "reason": reason,
      "isHalfDay": dayType == DayType.half,
    };

    if (dayType == DayType.half) {
      requestData["halfDayPart"] = halfDayPart!.name.toUpperCase();
    }

    debugPrint("========== LEAVE APPLY DEBUG ==========");
    debugPrint("leaveTypeId: ${selectedLeave!.leaveTypeId}");
    debugPrint("fromDate RAW: $fromDate");
    debugPrint("toDate RAW: $toDate");
    debugPrint("startDate SENT: ${requestData["startDate"]}");
    debugPrint("endDate SENT: ${requestData["endDate"]}");
    debugPrint("isHalfDay SENT: ${requestData["isHalfDay"]}");
    debugPrint("halfDayPart SENT: ${requestData["halfDayPart"]}");
    debugPrint("reason SENT: $reason");
    debugPrint("document PATH: ${document?.path}");
    debugPrint("======================================");

    try {
      await ref
          .read(leaveApplyProvider.notifier)
          .submitLeave(data: requestData, document: document);
      if (mounted) {
        Navigator.pop(context);

        Future.delayed(const Duration(milliseconds: 300), () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Leave applied successfully")),
          );
        });
      }
    } catch (e) {
      debugPrint("LEAVE APPLY ERROR: $e");
      _showError(e.toString().replaceAll("Exception: ", ""));
    }
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
      drawer: const AppDrawer(),
      body: balanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (leaves) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          children: [
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
                    const _SectionTitle("Leave Type"),

                    LeaveTypeDropdown(
                      leaves: leaves,
                      selected: selectedLeave,
                      onChanged: (leave) =>
                          setState(() => selectedLeave = leave),
                    ),

                    const SizedBox(height: 24),

                    const _SectionTitle("Duration"),

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
                      maxLeaveDays: selectedLeave?.available ?? 0,
                      isHalfDay: dayType == DayType.half,
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

                    const _SectionTitle("Reason"),

                    ReasonInput(onChanged: (v) => reason = v),

                    if (isDocumentRequired) ...[
                      const SizedBox(height: 24),
                      const _SectionTitle("Supporting Document"),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.attach_file),
                        label: Text(
                          document == null
                              ? "Attach Document"
                              : "Document Selected",
                        ),
                        onPressed: () {
                          /// implement file picker if needed
                        },
                      ),
                    ],

                    const SizedBox(height: 28),

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
