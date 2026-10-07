import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';

class FaceAuthenticationScreen extends StatefulWidget {
  final AttendanceRecord record;
  final void Function(AttendanceRecord) onVerificationSuccess;
  final VoidCallback onCancel;

  const FaceAuthenticationScreen({
    super.key,
    required this.record,
    required this.onVerificationSuccess,
    required this.onCancel,
  });

  @override
  State<FaceAuthenticationScreen> createState() => _FaceAuthenticationScreenState();
}

class _FaceAuthenticationScreenState extends State<FaceAuthenticationScreen> {
  CameraController? _cameraController;
  bool _isInitializing = true;
  String _statusMessage = 'Initializing camera...';
  bool _isVerified = false;
  bool _hasFailed = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {
        _isInitializing = false;
        _statusMessage = 'Position your face inside the frame';
      });

      _startVerificationProcess();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _hasFailed = true;
        _statusMessage = 'Camera initialization failed';
      });
    }
  }

  void _startVerificationProcess() async {
    // This mocks the ML Kit face detection and embedding process
    // 1. Detect Face
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _statusMessage = 'Face detected');

    // 2. Liveness Check
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _statusMessage = 'Checking liveness... Please blink');

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _statusMessage = 'Verifying identity...');

    // 3. Mock Face Match using Logged-in User ID
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Simulate backend entry recording after match
    await _recordEntryAndProceed();
  }

  Future<void> _recordEntryAndProceed() async {
    String? capturedPhotoPath;
    try {
      // Bypassing takePicture() because it is deadlocking the native CameraX thread
      // on certain devices (like Oppo/Realme), causing the app to silently freeze.
      // capturedPhotoPath will remain null, and the Dashboard will gracefully 
      // fallback to showing the user's initials.
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }

    // Backend assigns the entry time securely
    final verifiedRecord = AttendanceRecord(
      employee: widget.record.employee,
      locationName: widget.record.locationName,
      loginTime: DateTime.now(), // Simulated backend timestamp
      photoPath: capturedPhotoPath,
    );
    
    if (!mounted) return;
    setState(() {
      _isVerified = true;
      _statusMessage = 'Identity verified ✓';
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        widget.onVerificationSuccess(verifiedRecord);
      }
    });
  }

  void _retry() {
    setState(() {
      _hasFailed = false;
      _isVerified = false;
      _statusMessage = 'Position your face inside the frame';
    });
    _startVerificationProcess();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Verify Identity'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            'Authenticating ${widget.record.employee.name}',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: _isInitializing
                  ? const CircularProgressIndicator()
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_cameraController != null && _cameraController!.value.isInitialized)
                          ClipOval(
                            child: SizedBox(
                              width: 300,
                              height: 300,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: CameraPreview(_cameraController!),
                              ),
                            ),
                          ),
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isVerified ? Colors.green : (_hasFailed ? Colors.red : Colors.blue),
                              width: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: _isVerified ? Colors.green : (_hasFailed ? Colors.red : Colors.white),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (_hasFailed)
            ElevatedButton(
              onPressed: _retry,
              child: const Text('Retry'),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
