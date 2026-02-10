import 'package:flutter/material.dart';

class ModernPunchButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final List<Color> colors;

  const ModernPunchButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: disabled
              ? null
              : LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: disabled ? Colors.grey[300] : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: disabled
              ? []
              : [
                  BoxShadow(
                    color: colors.first.withOpacity(.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: disabled ? Colors.grey[500] : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: disabled ? Colors.grey[600] : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
