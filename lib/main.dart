import 'package:flutter/material.dart';
import 'package:course_match/schedule_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CourseMatch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF708240)),
        useMaterial3: true,
      ),
      home: const SchedulePage(title: 'CourseMatch'),
      debugShowCheckedModeBanner: false,
    );
  }
}