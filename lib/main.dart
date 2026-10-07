import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/models.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/face_auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const LabAttendanceApp());
}

class LabAttendanceApp extends StatelessWidget {
  const LabAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:        'Lab Attendance',
      debugShowCheckedModeBanner: false,
      themeMode:    ThemeMode.system,
      theme:        appTheme,
      darkTheme:    appDarkTheme,
      home:         const AppNavigator(),
    );
  }
}

/// Simple in-memory navigator that manages Login ↔ FaceAuth ↔ Dashboard transitions.
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

enum AuthState { unauthenticated, credentialVerified, fullyAuthenticated }

class _AppNavigatorState extends State<AppNavigator> {
  AttendanceRecord? _pendingRecord;
  List<AttendanceRecord> _records = [];
  bool _showSplash = true;
  AuthState _authState = AuthState.unauthenticated;

  @override
  void initState() {
    super.initState();
    _loadPersistedState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString('records');

    if (recordsJson != null) {
      final List<dynamic> decodedList = jsonDecode(recordsJson);
      final List<AttendanceRecord> loadedRecords = decodedList
          .map((item) => AttendanceRecord.fromJson(item as Map<String, dynamic>))
          .whereType<AttendanceRecord>()
          .toList();
      
      if (loadedRecords.isNotEmpty) {
        setState(() {
          _records = loadedRecords;
          _authState = AuthState.fullyAuthenticated;
        });
      }
    }
  }

  Future<void> _savePersistedState(List<AttendanceRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString('records', encodedList);
  }

  Future<void> _clearPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_showSplash) {
      child = const SplashScreen(key: ValueKey('splash'));
    } else if (_authState == AuthState.unauthenticated || _pendingRecord == null) {
      child = LoginScreen(
        key: const ValueKey('login'),
        onLoginSuccess: (record) {
          setState(() {
            _pendingRecord = record;
            _authState = AuthState.credentialVerified;
          });
        },
      );
    } else if (_authState == AuthState.credentialVerified) {
      child = FaceAuthenticationScreen(
        key: const ValueKey('face_auth'),
        record: _pendingRecord!,
        onVerificationSuccess: (verifiedRecord) async {
          final updatedRecords = List<AttendanceRecord>.from(_records)..add(verifiedRecord);
          await _savePersistedState(updatedRecords);
          if (!mounted) return;
          setState(() {
            _records = updatedRecords;
            _pendingRecord = null;
            _authState = AuthState.fullyAuthenticated;
          });
        },
        onCancel: () {
          setState(() {
            _pendingRecord = null;
            if (_records.isNotEmpty) {
              _authState = AuthState.fullyAuthenticated;
            } else {
              _authState = AuthState.unauthenticated;
            }
          });
        },
      );
    } else {
      child = DashboardScreen(
        key: const ValueKey('dashboard'),
        records: _records,
        onAddUser: () {
          setState(() {
            _authState = AuthState.unauthenticated;
          });
        },
        onLogout: () async {
          await _clearPersistedState();
          if (!mounted) return;
          setState(() {
            _records = [];
            _pendingRecord = null;
            _authState = AuthState.unauthenticated;
          });
        },
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: child,
    );
  }
}

