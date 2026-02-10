import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/features/auth/presentation/providers/auth_provider.dart';
import 'package:lms/features/profile/presentation/widgets/floating_details_card.dart';
import 'package:lms/features/profile/presentation/widgets/profile_header.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _refreshUser() async {
    await ref.read(authProvider.notifier).tryAutoLogin();
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final ext = pickedFile.path.split('.').last.toLowerCase();

    if (!['png', 'jpg', 'jpeg'].contains(ext)) {
      _snack("Only JPG and PNG images allowed");
      return;
    }

    final sizeMB = await file.length() / (1024 * 1024);
    if (sizeMB > 1) {
      _snack("Please select image smaller than 1MB");
      return;
    }

    _snack("Profile upload coming soon 🙂");
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = state.authUser;
    final profile = state.profile;

    final name = profile?.associatesName ?? user?.name ?? 'Guest';
    final empId = profile?.payrollCode ?? 'EMP0001';

    final details = [
      ("Employee ID", empId, Icons.badge_outlined),
      ("Designation", profile?.designation ?? 'N/A', Icons.work_outline),
      (
        "Department",
        profile?.departmentName ?? 'N/A',
        Icons.apartment_outlined,
      ),
      (
        "Manager",
        profile?.manager?.name ?? 'N/A',
        Icons.supervisor_account_outlined,
      ),
      (
        "Reporting To",
        profile?.departmentHead?.name ?? 'N/A',
        Icons.leaderboard_outlined,
      ),
      ("Email", profile?.email ?? 'N/A', Icons.email_outlined),
      (
        "Blood Group",
        profile?.bloodGroup ?? 'N/A',
        Icons.favorite_border_outlined,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: RefreshIndicator(
        onRefresh: _refreshUser,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              CurvedProfileHeader(
                name: name,
                empId: empId,
                imageUrl: state.profileUrl,
                onEditTap: _pickAndUploadImage,
              ),

              /// Floating card overlap
              Transform.translate(
                offset: const Offset(0, -150),
                child: ProfileDetailsCard(details: details),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
