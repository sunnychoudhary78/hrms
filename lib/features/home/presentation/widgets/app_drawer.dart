import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/app/app_root.dart';
import 'package:lms/features/auth/presentation/providers/auth_provider.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  bool _isLeaveExpanded = false;
  bool _isAttendanceExpanded = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final profile = authState.profile;

    // ✅ REAL PERMISSIONS FROM BACKEND
    final permissions = authState.permissions;

    // Team dashboard only for manager
    final bool hasApprovePermission = permissions.contains(
      'leave.request.approve',
    );

    final name = profile?.associatesName ?? "User";
    final empId = profile?.payrollCode ?? "EMP0001";
    final profileImg = authState.profileUrl;

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(name, empId, profileImg),

                    const SizedBox(height: 10),

                    _buildDrawerItem(
                      icon: Icons.home_rounded,
                      title: "Home",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, "/home");
                      },
                    ),

                    _buildDrawerItem(
                      icon: Icons.person,
                      title: "Profile",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, "/profile");
                      },
                    ),

                    _buildDrawerItem(
                      icon: Icons.notifications_rounded,
                      title: "Notifications",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, "/notifications");
                      },
                    ),

                    if (hasApprovePermission)
                      _buildDrawerItem(
                        icon: Icons.dashboard_rounded,
                        title: "Team Dashboard",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, "/team-dashboard");
                        },
                      ),

                    _buildExpandableItem(
                      icon: Icons.beach_access_rounded,
                      title: "Leave",
                      expanded: _isLeaveExpanded,
                      onTap: () {
                        setState(() {
                          _isLeaveExpanded = !_isLeaveExpanded;
                        });
                      },
                      subItems: [
                        _buildSubItem(
                          title: "Leave Balance",
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, "/leave-balance");
                          },
                        ),

                        _buildSubItem(
                          title: "Leave Apply",
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, "/leave-apply");
                          },
                        ),

                        _buildSubItem(
                          title: "Leave Status",
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, "/leave-status");
                          },
                        ),

                        if (hasApprovePermission)
                          _buildSubItem(
                            title: "Leave Approve/Reject",
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, "/leave-approve");
                            },
                          ),
                      ],
                    ),

                    _buildDrawerItem(
                      icon: Icons.lock_outline_rounded,
                      title: "Change Password",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, "/change-password");
                      },
                    ),

                    _buildExpandableItem(
                      icon: Icons.access_time_rounded,
                      title: "Attendance",
                      expanded: _isAttendanceExpanded,
                      onTap: () {
                        setState(() {
                          _isAttendanceExpanded = !_isAttendanceExpanded;
                        });
                      },
                      subItems: [
                        _buildSubItem(
                          title: "Mark Attendance",
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, "/mark-attendance");
                          },
                        ),

                        _buildSubItem(
                          title: "View Attendance",
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, "/view-attendance");
                          },
                        ),

                        if (hasApprovePermission)
                          _buildSubItem(
                            title: "Attendance Correction",
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                "/correct-attendance",
                              );
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            const Divider(height: 1, color: Colors.grey),

            _buildDrawerItem(
              icon: Icons.logout_rounded,
              title: "Logout",
              color: Colors.redAccent,
              onTap: () async {
                await ref.read(authProvider.notifier).logout();

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AppRoot()),
                  (_) => false,
                );
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(String name, String empId, String img) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC000), Color(0xFFFFD54F), Color(0xFFFFE082)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundImage: img.isNotEmpty
                ? NetworkImage(img)
                : const AssetImage('assets/images/profile.jpg')
                      as ImageProvider,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 6),

                Text(
                  empId,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: .85),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= DRAWER ITEM =================

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFC000), Color(0xFFFFA000)],
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= EXPANDABLE =================

  Widget _buildExpandableItem({
    required IconData icon,
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required List<Widget> subItems,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFC000), Color(0xFFFFA000)],
                          ),
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              firstChild: const SizedBox.shrink(),
              secondChild: Column(children: subItems),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );
  }

  // ================= SUB ITEM =================

  Widget _buildSubItem({required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 16, top: 4, bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_right,
                    color: Colors.black54,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(title, style: const TextStyle(fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
