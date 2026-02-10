import 'package:flutter/material.dart';

class LeaveColorMapper {
  static Color colorFor(String leaveName) {
    final name = leaveName.toLowerCase();

    if (name.contains('casual')) return Colors.indigo;
    if (name.contains('sick')) return Colors.redAccent;
    if (name.contains('earned')) return Colors.green;
    if (name.contains('emergency')) return Colors.orange;
    if (name.contains('paternity')) return Colors.blueGrey;

    return Colors.purple; // fallback
  }
}
