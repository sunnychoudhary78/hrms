import 'package:flutter/material.dart';

class ProfileDetailsCard extends StatelessWidget {
  final List<(String title, String value, IconData icon)> details;

  const ProfileDetailsCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 10,
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: details.map((d) {
              return ListTile(
                leading: Icon(d.$3, color: scheme.primary),
                title: Text(
                  d.$1,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                subtitle: Text(
                  d.$2,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
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
