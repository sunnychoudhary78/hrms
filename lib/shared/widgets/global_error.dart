import 'package:flutter/material.dart';

class GlobalError extends StatelessWidget {
  final String message;

  const GlobalError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
