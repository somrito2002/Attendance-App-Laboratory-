// Data models for the Lab Attendance app

class Employee {
  final String id;
  final String name;
  final String position;
  final String password;

  const Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.password,
  });
}

class AttendanceRecord {
  final Employee employee;
  final String locationName;
  final DateTime loginTime;
  final String? photoPath;

  const AttendanceRecord({
    required this.employee,
    required this.locationName,
    required this.loginTime,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
    'employeeId': employee.id,
    'locationName': locationName,
    'loginTime': loginTime.toIso8601String(),
    'photoPath': photoPath,
  };

  static AttendanceRecord? fromJson(Map<String, dynamic> json) {
    final emp = employeeDatabase.cast<Employee?>().firstWhere(
      (e) => e?.id == json['employeeId'],
      orElse: () => null,
    );
    if (emp == null) return null;
    
    return AttendanceRecord(
      employee: emp,
      locationName: json['locationName'] as String,
      loginTime: DateTime.parse(json['loginTime'] as String),
      photoPath: json['photoPath'] as String?,
    );
  }
}

// Predefined job-site locations
const List<String> siteLocations = [
  'Main Office – HQ',
  'Site A – North Zone',
  'Site B – South Zone',
  'Site C – East Zone',
  'Site D – West Zone',
  'Remote / Field',
];

// Mock employee database
const List<Employee> employeeDatabase = [
  Employee(id: 'EMP01',  name: 'Test User',      position: 'Hardcoded User',  password: 'nopass'),
  Employee(id: 'EMP001', name: 'Arjun Sharma',   position: 'Field Engineer',  password: 'pass123'),
  Employee(id: 'EMP002', name: 'Priya Nair',     position: 'Lab Technician',  password: 'pass456'),
  Employee(id: 'EMP003', name: 'Rahul Verma',    position: 'Site Supervisor', password: 'pass789'),
  Employee(id: 'EMP004', name: 'Divya Krishnan', position: 'Quality Analyst', password: 'pass321'),
  Employee(id: 'EMP005', name: 'Mohammed Irfan', position: 'Safety Officer',  password: 'pass654'),
];

/// Returns the matching employee or null if credentials are invalid.
Employee? validateLogin(String loginId, String password) {
  try {
    return employeeDatabase.firstWhere(
      (e) => e.id.toLowerCase() == loginId.trim().toLowerCase() && e.password == password,
    );
  } catch (_) {
    return null;
  }
}
