import 'package:flutter/material.dart';

class ProfileDetailsCard extends StatelessWidget {
  final List<(String title, String value, IconData icon)> details;

  const ProfileDetailsCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: details.map((d) {
              return ListTile(
                leading: Icon(d.$3, color: const Color(0xFF1565C0)),
                title: Text(
                  d.$1,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                subtitle: Text(
                  d.$2,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
