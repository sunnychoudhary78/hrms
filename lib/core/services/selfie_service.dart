import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/providers/global_loading_provider.dart';

class SelfieService {
  /// Opens front camera safely
  Future<File?> captureSelfie(BuildContext context) async {
    /// ✅ CRITICAL FIX — hide loader before opening camera
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      container.read(globalLoadingProvider.notifier).hide();
    } catch (_) {}

    /// Open camera screen
    return await Navigator.push<File?>(
      context,
      MaterialPageRoute(builder: (_) => const _SelfieCameraScreen()),
    );
  }

  /// Compress image
  Future<File> compressImage(File file) async {
    final dir = await getTemporaryDirectory();

    final path =
        "${dir.path}/selfie_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      path,
      quality: 70,
    );

    return File(result!.path);
  }
}

class _SelfieCameraScreen extends StatefulWidget {
  const _SelfieCameraScreen();

  @override
  State<_SelfieCameraScreen> createState() => _SelfieCameraScreenState();
}

class _SelfieCameraScreenState extends State<_SelfieCameraScreen> {
  CameraController? controller;

  bool isReady = false;

  bool isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();

    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );

    controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller!.initialize();

    if (mounted) {
      setState(() {
        isReady = true;
      });
    }
  }

  Future<void> _capture() async {
    if (isCapturing) return;

    isCapturing = true;

    try {
      final XFile file = await controller!.takePicture();

      if (mounted) {
        Navigator.pop(context, File(file.path));
      }
    } catch (_) {
      Navigator.pop(context, null);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// NORMAL FRONT CAMERA PREVIEW (mirrored for natural selfie view)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller!.value.previewSize!.height,
                height: controller!.value.previewSize!.width,
                child: CameraPreview(controller!),
              ),
            ),
          ),

          /// CAPTURE BUTTON (UI only improved, logic unchanged)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _capture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400, width: 5),
                  ),
                ),
              ),
            ),
          ),

          /// CLOSE BUTTON (unchanged)
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context, null),
            ),
          ),
        ],
      ),
    );
  }
}
