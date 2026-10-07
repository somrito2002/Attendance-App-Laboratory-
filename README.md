# 🏭 Lab Attendance – Flutter App

A **Material 3** Flutter attendance app for field workers and lab staff, featuring GPS location verification and a live attendance dashboard.

## ✨ Features

### 🔐 Login Screen
- **Login ID** field with keyboard navigation
- **Password** field with show/hide toggle
- **Location / Site** dropdown (6 predefined job sites)
- **GPS Verify** button — requests permission, fetches real coordinates via `geolocator`
- Animated color feedback: idle → orange → green ✓
- **Shake animation** on invalid credentials
- Animated error messages

### 📊 Dashboard Screen
- Gradient header with **live running clock** (updates every second)
- Pulsing **CHECKED IN** green status badge
- **Avatar circle** auto-generated from employee initials
- Employee **Name, Position, ID** displayed prominently
- **Login Time**, **Lab / Site**, **Date** info cards
- Attendance confirmed banner

## 🧪 Test Credentials

| Login ID | Password | Name | Position |
|----------|----------|------|----------|
| `EMP001` | `pass123` | Arjun Sharma | Field Engineer |
| `EMP002` | `pass456` | Priya Nair | Lab Technician |
| `EMP003` | `pass789` | Rahul Verma | Site Supervisor |
| `EMP004` | `pass321` | Divya Krishnan | Quality Analyst |
| `EMP005` | `pass654` | Mohammed Irfan | Safety Officer |

## 🚀 Getting Started

```bash
cd "d:\Lab Attendance\LabAttendanceFlutter"
flutter pub get
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart                    # Entry point & navigation
├── data/
│   └── models.dart              # Employee, AttendanceRecord, mock DB
├── screens/
│   ├── login_screen.dart        # Login UI with GPS
│   └── dashboard_screen.dart   # Live dashboard
└── theme/
    └── app_theme.dart           # Color palette & Material 3 theme
```

## 📦 Dependencies

- `geolocator` — GPS location
- `intl` — Date/time formatting

## 🎨 Design System

Deep Teal brand palette (`#006E6A`) with Amber accent (`#FFC107`) — Material Design 3.
