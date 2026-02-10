import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/home/presentation/widgets/app_drawer.dart';
import 'package:lms/shared/utils/app_snackbar.dart';
import '../providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  static const int _maxLen = 15;
  static const Color _primaryColor = Color(0xFF2563EB);

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Security Settings",
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_rounded, color: Colors.grey.shade800),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _HeaderIcon(color: _primaryColor),
                const SizedBox(height: 24),
                _TitleSection(),
                const SizedBox(height: 32),

                _FormCard(
                  child: Column(
                    children: [
                      PasswordField(
                        label: "Current Password",
                        controller: _currentCtrl,
                        show: _showCurrent,
                        onToggle: () =>
                            setState(() => _showCurrent = !_showCurrent),
                        primaryColor: _primaryColor,
                        maxLen: _maxLen,
                      ),
                      const SizedBox(height: 20),
                      PasswordField(
                        label: "New Password",
                        controller: _newCtrl,
                        show: _showNew,
                        onToggle: () => setState(() => _showNew = !_showNew),
                        primaryColor: _primaryColor,
                        maxLen: _maxLen,
                      ),
                      const SizedBox(height: 20),
                      PasswordField(
                        label: "Confirm Password",
                        controller: _confirmCtrl,
                        show: _showConfirm,
                        onToggle: () =>
                            setState(() => _showConfirm = !_showConfirm),
                        primaryColor: _primaryColor,
                        maxLen: _maxLen,
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: authState.isLoading
                              ? null
                              : () async {
                                  // ── validation ──
                                  if (_currentCtrl.text.isEmpty ||
                                      _newCtrl.text.isEmpty ||
                                      _confirmCtrl.text.isEmpty) {
                                    AppSnackbar.error(
                                      context,
                                      "Please fill all fields",
                                    );
                                    return;
                                  }

                                  if (_newCtrl.text != _confirmCtrl.text) {
                                    AppSnackbar.error(
                                      context,
                                      "Passwords do not match",
                                    );
                                    return;
                                  }

                                  if (_newCtrl.text.length < 6) {
                                    AppSnackbar.error(
                                      context,
                                      "Password must be at least 6 characters",
                                    );
                                    return;
                                  }

                                  try {
                                    // 1️⃣ API call
                                    await authNotifier.changePassword(
                                      currentPassword: _currentCtrl.text,
                                      newPassword: _newCtrl.text,
                                      confirmPassword: _confirmCtrl.text,
                                    );
                                  } catch (_) {
                                    if (context.mounted) {
                                      AppSnackbar.error(
                                        context,
                                        "Failed to change password",
                                      );
                                    }
                                    return;
                                  }

                                  if (!context.mounted) return;

                                  // 2️⃣ Success message
                                  AppSnackbar.success(
                                    context,
                                    "Password changed successfully. Please login again.",
                                  );

                                  // 3️⃣ Small delay so user sees snackbar
                                  await Future.delayed(
                                    const Duration(milliseconds: 600),
                                  );

                                  // 4️⃣ Force logout
                                  await authNotifier.logout();

                                  if (!context.mounted) return;

                                  // 5️⃣ HARD redirect to login
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login',
                                    (route) => false,
                                  );
                                },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Reset Password",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
// ─────────────────── WIDGETS ───────────────────
//

class _HeaderIcon extends StatelessWidget {
  final Color color;

  const _HeaderIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.lock_reset_rounded, size: 48, color: color),
    );
  }
}

class _TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "New Password",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Create a strong password different from your previous one.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;

  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool show;
  final VoidCallback onToggle;
  final Color primaryColor;
  final int maxLen;

  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.show,
    required this.onToggle,
    required this.primaryColor,
    required this.maxLen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !show,
          maxLength: maxLen,
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            hintText: "••••••••",
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: controller.text.isNotEmpty
                  ? primaryColor
                  : Colors.grey.shade500,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
