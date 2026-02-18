import 'dart:ui';
import 'package:flutter/material.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;

  const AppAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AppBar(
          elevation: 0,

          /// TRUE glass background
          backgroundColor: scheme.surface.withOpacity(0.55),

          foregroundColor: scheme.onSurface,

          scrolledUnderElevation: 0,

          surfaceTintColor: Colors.transparent,

          shadowColor: Colors.transparent,

          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: -.2,
            ),
          ),

          leading: showBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              : null,

          actions: actions,

          /// Glass border highlight
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: scheme.outline.withOpacity(.15)),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
