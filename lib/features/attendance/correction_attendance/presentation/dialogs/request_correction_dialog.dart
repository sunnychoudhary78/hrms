import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/attendance/shared/data/attendance_repository_provider.dart';
import '../widgets/section_header.dart';
import '../widgets/time_picker_card.dart';

void showRequestCorrectionDialog({
  required BuildContext context,
  required DateTime selectedDate,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _RequestCorrectionDialog(),
  );
}

class _RequestCorrectionDialog extends ConsumerStatefulWidget {
  const _RequestCorrectionDialog();

  @override
  ConsumerState<_RequestCorrectionDialog> createState() =>
      _RequestCorrectionDialogState();
}

class _RequestCorrectionDialogState
    extends ConsumerState<_RequestCorrectionDialog> {
  late DateTime targetDate;
  TimeOfDay? proposedIn;
  TimeOfDay? proposedOut;
  final reasonController = TextEditingController();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    targetDate = DateTime.now();
  }

  Future<void> _submit() async {
    if (proposedIn == null || reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Time & reason required")));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      String toIso(TimeOfDay t) {
        return DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          t.hour,
          t.minute,
        ).toIso8601String();
      }

      await ref.read(attendanceRepositoryProvider).requestCorrection({
        "targetDate": DateFormat('yyyy-MM-dd').format(targetDate),
        "proposedCheckIn": toIso(proposedIn!),
        if (proposedOut != null) "proposedCheckOut": toIso(proposedOut!),
        "reason": reasonController.text.trim(),
      });

      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Correction request submitted")),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Request Correction",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// DATE
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: targetDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => targetDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    DateFormat('EEEE, d MMM y').format(targetDate),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const SectionHeader(
                title: "New Correction",
                icon: Icons.edit_note,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TimePickerCard(
                      label: "In Time",
                      time: proposedIn,
                      onPick: (t) => setState(() => proposedIn = t),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TimePickerCard(
                      label: "Out Time",
                      time: proposedOut,
                      onPick: (t) => setState(() => proposedOut = t),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Reason",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Request"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
