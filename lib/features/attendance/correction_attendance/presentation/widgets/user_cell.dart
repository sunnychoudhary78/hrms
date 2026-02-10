import 'package:flutter/material.dart';

class UserCell extends StatelessWidget {
  final String name;
  final String? image;

  const UserCell({super.key, required this.name, this.image});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: image != null ? NetworkImage(image!) : null,
          child: image == null ? Text(name[0]) : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
