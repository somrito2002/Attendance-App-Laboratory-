import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';

enum GpsStatus { idle, acquiring, acquired, failed }

class LoginScreen extends StatefulWidget {
  final void Function(AttendanceRecord record) onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _loginIdController  = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();

  String       _selectedLocation = siteLocations.first;
  bool         _passwordVisible  = false;
  bool         _isLoading        = false;
  String?      _errorMessage;
  GpsStatus    _gpsStatus        = GpsStatus.idle;
  String?      _gpsCoordinates;

  late AnimationController _shakeController;
  late Animation<double>   _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _shakeError() {
    _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
  }

  Future<void> _fetchGps() async {
    setState(() => _gpsStatus = GpsStatus.acquiring);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() { _gpsStatus = GpsStatus.failed; });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      setState(() { _gpsStatus = GpsStatus.failed; });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      setState(() {
        _gpsStatus       = GpsStatus.acquired;
        _gpsCoordinates  =
            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      });
    } catch (_) {
      setState(() => _gpsStatus = GpsStatus.failed);
    }
  }

  void _attemptLogin() {
    setState(() => _errorMessage = null);

    final loginId  = _loginIdController.text.trim();
    final password = _passwordController.text;

    if (loginId.isEmpty) {
      setState(() => _errorMessage = 'Login ID cannot be empty');
      _shakeError();
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Password cannot be empty');
      _shakeError();
      return;
    }

    setState(() => _isLoading = true);

    final employee = validateLogin(loginId, password);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (employee != null) {
        widget.onLoginSuccess(
          AttendanceRecord(
            employee:     employee,
            locationName: _selectedLocation,
            loginTime:    DateTime.now(),
          ),
        );
      } else {
        setState(() => _errorMessage = 'Invalid Login ID or Password');
        _shakeError();
      }
    });
  }

  Color get _gpsButtonColor {
    switch (_gpsStatus) {
      case GpsStatus.acquired:  return const Color(0xFF2E7D32);
      case GpsStatus.failed:    return errorRed;
      case GpsStatus.acquiring: return const Color(0xFFF57C00);
      case GpsStatus.idle:      return Colors.white;
    }
  }

  String get _gpsButtonLabel {
    switch (_gpsStatus) {
      case GpsStatus.idle:      return 'Verify GPS';
      case GpsStatus.acquiring: return 'Locating…';
      case GpsStatus.acquired:  return 'GPS Verified ✓';
      case GpsStatus.failed:    return 'GPS Failed – Retry';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Theme.of(context).colorScheme.primary;
    final textSubColor = isDark ? Colors.white.withValues(alpha: 0.75) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.75);
    final glassColor = isDark ? Colors.white.withValues(alpha: 0.15) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05);
    final glassBorderColor = isDark ? Colors.white.withValues(alpha: 0.3) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2);
    final glassFocusedBorderColor = isDark ? Colors.white : Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Stack(
          children: [
            const Positioned.fill(child: WaterRippleBackground()),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),

                    // App logo
                    Container(
                      width: 96, height: 96,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, // Match the image's background to avoid lines
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/water_drop.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Lab Attendance',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Field Worker Portal',
                      style: TextStyle(
                        fontSize: 14,
                        color: textSubColor,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Login card with shake animation
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: glassColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: glassBorderColor,
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              inputDecorationTheme: InputDecorationTheme(
                                filled: true,
                                fillColor: glassColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: glassBorderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: glassBorderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: glassFocusedBorderColor, width: 2),
                                ),
                                labelStyle: TextStyle(color: textSubColor),
                                floatingLabelStyle: TextStyle(color: textColor),
                                hintStyle: TextStyle(color: textSubColor.withValues(alpha: 0.5)),
                                prefixIconColor: textSubColor,
                                suffixIconColor: textSubColor,
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Check In',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                ),
                                const SizedBox(height: 20),

                                // Login ID
                                TextField(
                                  controller: _loginIdController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Login ID',
                                    hintText:  'e.g. EMP001',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) => setState(() => _errorMessage = null),
                                ),
                                const SizedBox(height: 16),

                                // Password
                                TextField(
                                  controller: _passwordController,
                                  obscureText: !_passwordVisible,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(_passwordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () => setState(
                                          () => _passwordVisible = !_passwordVisible),
                                    ),
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onChanged: (_) => setState(() => _errorMessage = null),
                                  onSubmitted: (_) => _attemptLogin(),
                                ),
                                const SizedBox(height: 16),

                                // Location dropdown
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedLocation,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                  dropdownColor: const Color(0xFF0F3A4A),
                                  decoration: const InputDecoration(
                                    labelText: 'Location / Site',
                                    prefixIcon: Icon(Icons.location_on_outlined),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  items: siteLocations
                                      .map((s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s, style: const TextStyle(color: Colors.white)),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedLocation = v!),
                                ),
                                const SizedBox(height: 12),

                                // GPS row
                                Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: _gpsButtonColor,
                                          side: BorderSide(color: _gpsButtonColor),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        icon: _gpsStatus == GpsStatus.acquiring
                                            ? SizedBox(
                                                width:  14,
                                                height: 14,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: _gpsButtonColor,
                                                ),
                                              )
                                            : const Icon(Icons.gps_fixed, size: 16),
                                        label: Text(
                                          _gpsButtonLabel,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        onPressed: _gpsStatus == GpsStatus.acquiring
                                            ? null
                                            : _fetchGps,
                                      ),
                                    ),
                                    if (_gpsCoordinates != null) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _gpsCoordinates!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Error message
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: _errorMessage != null
                                      ? Container(
                                          key: ValueKey(_errorMessage),
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: errorRed.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                                color: errorRed.withValues(alpha: 0.3)),
                                          ),
                                          child: Text(
                                            _errorMessage!,
                                            style: const TextStyle(
                                              color: errorRed,
                                              fontSize: 13,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                const SizedBox(height: 16),

                                // Sign In button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: (_isLoading || _loginIdController.text.trim().isEmpty || _passwordController.text.isEmpty) ? null : _attemptLogin,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width:  22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Check In'),
                                  ),
                                ),
                              ],
                            ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      '© 2026 Lab Attendance System',
                      style: TextStyle(
                        fontSize: 12,
                        color: textSubColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class WaterRippleBackground extends StatefulWidget {
  const WaterRippleBackground({super.key});

  @override
  State<WaterRippleBackground> createState() => _WaterRippleBackgroundState();
}

class _WaterRippleBackgroundState extends State<WaterRippleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.bottomCenter,
          radius: 1.5,
          colors: isDark
              ? const [
                  Color(0xFF0F3A4A), // Deep water blue-teal
                  Color(0xFF031622), // Very dark blue edge
                ]
              : const [
                  Colors.white, // Professional white center
                  Color(0xFFF0F5F5), // Very light grey-teal edge
                ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WaterRipplePainter(_controller.value),
            child: Container(),
          );
        },
      ),
    );
  }
}

class _WaterRipplePainter extends CustomPainter {
  final double progress;
  _WaterRipplePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.7);
    
    // Draw ripples
    for (int i = 0; i < 4; i++) {
      double offsetProgress = (progress + (i * 0.25)) % 1.0;
      double radius = size.width * 1.2 * offsetProgress;
      double opacity = (1.0 - offsetProgress).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(1.0, 0.35); // flatten to look 3D

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 + (15 * (1 - offsetProgress))
        ..shader = SweepGradient(
          colors: [
            Colors.cyan.withValues(alpha: opacity * 0.5),
            Colors.pinkAccent.withValues(alpha: opacity * 0.3),
            Colors.white.withValues(alpha: opacity * 0.6),
            Colors.cyan.withValues(alpha: opacity * 0.5),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));

      canvas.drawCircle(Offset.zero, radius, paint);
      canvas.restore();
    }

    // Draw the falling drop
    if (progress < 0.2) {
      double dropProgress = progress / 0.2; // 0 to 1
      double startY = size.height * 0.3;
      double endY = center.dy;
      double currentY = startY + (endY - startY) * (dropProgress * dropProgress); // accelerate falling

      final dropPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = const RadialGradient(
          colors: [Colors.white, Colors.cyan, Colors.blue],
          stops: [0.1, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(center.dx, currentY - 10), radius: 8));

      // Main drop
      canvas.drawCircle(Offset(center.dx, currentY), 8, dropPaint);
      
      // Drop reflection/tail
      final tailPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white.withValues(alpha: 0.3);
      canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, currentY - 8), width: 6, height: 12), tailPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaterRipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
