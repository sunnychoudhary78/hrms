import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GlobalLoader extends StatelessWidget {
  final String message;

  const GlobalLoader({super.key, this.message = "Please wait..."});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        /// 🔥 Dark Blur Background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(color: Colors.black.withOpacity(0.35)),
        ).animate().fadeIn(duration: 200.ms),

        /// 🔥 Premium Glass Card
        Center(
          child: Material(
            color: Colors.transparent,
            child:
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surface.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: scheme.outline.withOpacity(0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: 1,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// 🔥 Animated Pulse Loader
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: scheme.primary.withOpacity(0.08),
                                    ),
                                  )
                                  .animate(onPlay: (c) => c.repeat())
                                  .scale(
                                    begin: const Offset(0.8, 0.8),
                                    end: const Offset(1.2, 1.2),
                                    duration: 1200.ms,
                                    curve: Curves.easeInOut,
                                  )
                                  .fade(begin: 0.4, end: 0, duration: 1200.ms),

                              SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation(
                                    scheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          /// 🔥 Message
                          Text(
                                message,
                                textAlign: TextAlign.center,

                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface,
                                  letterSpacing: 0.4,
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 200.ms)
                              .slideY(begin: 0.3, end: 0),
                        ],
                      ),
                    )
                    .animate()
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 300.ms),
          ),
        ),
      ],
    );
  }
}
