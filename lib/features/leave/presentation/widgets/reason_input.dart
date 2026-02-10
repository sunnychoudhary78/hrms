import 'package:flutter/material.dart';

class ReasonInput extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const ReasonInput({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: "Reason",
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
