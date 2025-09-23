import 'package:flutter/material.dart';
import 'package:course_match/schedule_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('themeMode');
  final initialMode = _themeModeFromString(saved);
  runApp(MyApp(initialMode: initialMode));
}

ThemeMode _themeModeFromString(String? value) {
  switch (value) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
}

String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.light:
      return 'light';
    case ThemeMode.system:
    default:
      return 'system';
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialMode});
  final ThemeMode initialMode;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialMode;
  }

  Future<void> _toggleTheme() async {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeModeToString(_themeMode));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CourseMatch',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF708240), brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFFFFBF0),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF708240), brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: SchedulePage(title: 'CourseMatch', onToggleTheme: _toggleTheme, isDark: _themeMode == ThemeMode.dark),
      debugShowCheckedModeBanner: false,
    );
  }
}