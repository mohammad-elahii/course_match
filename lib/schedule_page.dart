import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key, required this.title});
  final String title;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<Map<String, dynamic>> students = [];
  List<String> timeSlots = [];
  List<String> selectedStudents = [];
  bool showRestTime = false;
  late bool isOddWeek;
  
  // Original semester start date
  DateTime semesterStartDate = DateTime(2025, 2, 8); 

  // Override isOddWeek for a specific week number (use this if automatic calculation isn't accurate)
  bool overrideWeekType() {
    // We're currently in week 7 which is odd
    return true; // true for odd, false for even
  }

  DateTime getCurrentDate() {
    return DateTime.now();
  }

  final List<String> days = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday'
  ];

  // Calculate the week number with a correction of -2 weeks for holidays
  bool determineWeekType() {
    final today = getCurrentDate();
    final difference = today.difference(semesterStartDate).inDays;
    final calculatedWeekNumber = (difference / 7).ceil();
    
    // Adjust for the 2-week holiday period
    final correctedWeekNumber = calculatedWeekNumber - 2;
    
    // Week number should be positive
    final weekNumber = correctedWeekNumber > 0 ? correctedWeekNumber : 1;
    
    return weekNumber.isOdd; // true for odd weeks, false for even weeks
  }

  String getCurrentWeekType() {
    final today = getCurrentDate();
    final difference = today.difference(semesterStartDate).inDays;
    final calculatedWeekNumber = (difference / 7).floor() + 1;
    
    // Adjust for the 2-week holiday period
    final correctedWeekNumber = calculatedWeekNumber - 2;
    
    // Week number should be positive
    final weekNumber = correctedWeekNumber > 0 ? correctedWeekNumber : 1;
    
    return '${isOddWeek ? "Odd" : "Even"} Week (Week $weekNumber)';
  }

  @override
  void initState() {
    super.initState();
    isOddWeek = determineWeekType();
    loadStudentData();
  }

  Color getColorFromString(String colorName) {
    switch (colorName) {
      case 'code1':
        return Color(0xFFDF6149);
      case 'code2':
        return Color(0xFFF49069);
      case 'code3':
        return Color(0xFFABBA72);
      case 'code4':
        return Color(0xFFFEDC7B);
      case 'code5':
        return Color(0xFF708240);
      case 'code6':
        return Color(0xFF008080);
      default:
        return Colors.grey;
    }
  }

  Future<void> loadStudentData() async {
    try {
      // Load both odd and even week data
      final String oddWeekJson = await rootBundle.loadString('assets/student_odd_week.json');
      final String evenWeekJson = await rootBundle.loadString('assets/student_even_week.json');

      final oddWeekData = json.decode(oddWeekJson);
      final evenWeekData = json.decode(evenWeekJson);

      setState(() {
        // Store both schedules in the students list with a week type indicator
        students = [];

        // Add odd week schedules
        List<Map<String, dynamic>> oddWeekStudents = List<Map<String, dynamic>>.from(oddWeekData['students']);
        for (var student in oddWeekStudents) {
          student['weekType'] = 'odd';
          students.add(student);
        }

        // Add even week schedules
        List<Map<String, dynamic>> evenWeekStudents = List<Map<String, dynamic>>.from(evenWeekData['students']);
        for (var student in evenWeekStudents) {
          student['weekType'] = 'even';
          students.add(student);
        }

        // Time slots should be the same for both weeks
        timeSlots = List<String>.from(oddWeekData['timeSlots']);
      });
    } catch (e) {
      debugPrint('Error loading student data: $e'); // Keeping this one for error handling
    }
  }

  // Helper method to get students for the current week type
  List<Map<String, dynamic>> getFilteredStudents() {
    final weekType = isOddWeek ? 'odd' : 'even';
    return students.where((student) => student['weekType'] == weekType).toList();
  }

  // Add this method to check if a day is today
  bool isCurrentDay(String day) {
    final today = getCurrentDate();
    final weekday = today.weekday;
    final scheduleDay = switch (weekday) {
      DateTime.saturday => 'Saturday',
      DateTime.sunday => 'Sunday',
      DateTime.monday => 'Monday',
      DateTime.tuesday => 'Tuesday',
      DateTime.wednesday => 'Wednesday',
      DateTime.thursday => 'Thursday',
      DateTime.friday => 'Friday',
      _ => '',
    };
    return day == scheduleDay;
  }

  void toggleStudentSelection(String studentName) {
    setState(() {
      if (selectedStudents.contains(studentName)) {
        selectedStudents.remove(studentName);
      } else {
        if (selectedStudents.length < 2) {
          selectedStudents.add(studentName);
        } else {
          // If already 2 students selected, remove the first one and add the new one
          selectedStudents.removeAt(0);
          selectedStudents.add(studentName);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate responsive sizes
    final timeSlotWidth = screenWidth * 0.12; // 12% of screen width
    final timeSlotHeight = screenHeight * 0.06; // 6% of screen height
    final restSlotWidth = timeSlotWidth * 0.35; // 35% of time slot width
    final dotSize = timeSlotHeight * 0.13; // 13% of slot height
    final restDotSize = dotSize * 0.7; // 70% of dot size
    final studentIconSize = screenWidth * 0.025; // 2.5% of screen width for student icons
    final fontSize = screenWidth * 0.017; // 1.7% of screen width for general text
    final titleFontSize = screenWidth * 0.035; // 3.5% of screen width for title
    final studentNameFontSize = screenWidth * 0.015; // 1.5% of screen width for student names

    return Scaffold(
      backgroundColor: Color(0xFFFFFBF0),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CourseMatch',
              style: TextStyle(
                color: Color(0xFF708240),
                fontFamily: 'Sableklish',
                fontSize: titleFontSize,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      body: students.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      children: [
                        // Current week indicator
                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF708240).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(screenWidth * 0.05),
                            ),
                            child: Text(
                              getCurrentWeekType(),
                              style: TextStyle(
                                color: Color(0xFF708240),
                                fontWeight: FontWeight.bold,
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // Student selection
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: getFilteredStudents().map((student) => Padding(
                              padding: EdgeInsets.all(screenWidth * 0.01),
                              child: InkWell(
                                onTap: () => toggleStudentSelection(student['name']),
                                child: Row(
                                  children: [
                                    Container(
                                      width: studentIconSize,
                                      height: studentIconSize,
                                      decoration: BoxDecoration(
                                        color: getColorFromString(student['color']),
                                        shape: BoxShape.circle,
                                        border: selectedStudents.contains(student['name'])
                                            ? Border.all(color: Colors.black, width: screenWidth * 0.001)
                                            : null,
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.01),
                                    Text(
                                      student['name'],
                                      style: TextStyle(
                                        fontWeight: selectedStudents.contains(student['name'])
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: studentNameFontSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Schedule table
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: timeSlotWidth * 0.8),
                              ...timeSlots.map((time) => SizedBox(
                                width: timeSlotWidth,
                                child: Text(
                                  time,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSize,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          ...days.map((day) => _buildDayRow(
                            day,
                            timeSlotWidth,
                            timeSlotHeight,
                            restSlotWidth,
                            dotSize,
                            restDotSize,
                            fontSize,
                          )),
                        ],
                      ),
                    ),
                  ),
                  // Bottom switch control
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/logos/class.svg',
                              width: screenWidth * 0.03,
                              height: screenWidth * 0.03,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: showRestTime,
                                onChanged: (value) {
                                  setState(() {
                                    showRestTime = value;
                                  });
                                },
                                activeColor: Color(0xFF708240),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            SvgPicture.asset(
                              'assets/logos/fun.svg',
                              width: screenWidth * 0.05,
                              height: screenWidth * 0.05,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  bool hasRestTime(String day, int timeIndex, Map<String, dynamic> student) {
    var schedule = student['schedule'][day] as List<dynamic>;
    return schedule.contains(timeIndex);
  }

  Widget _buildDayRow(
    String day,
    double timeSlotWidth,
    double timeSlotHeight,
    double restSlotWidth,
    double dotSize,
    double restDotSize,
    double fontSize,
  ) {
    final isToday = isCurrentDay(day);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        decoration: isToday ? BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFE3EF9A).withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ],
        ) : null,
        child: Row(
          children: [
            SizedBox(
              width: timeSlotWidth * 0.8,
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? Color(0xFF708240) : Colors.black,
                  fontSize: fontSize,
                ),
              ),
            ),
            ...List.generate(timeSlots.length * 2 - 1, (index) {
              bool isRestSlot = index.isOdd;
              int timeIndex = index ~/ 2 + 1;

              if (isRestSlot && showRestTime) {
                return Container(
                  width: restSlotWidth,
                  height: timeSlotHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    color: Colors.grey.withOpacity(0.1),
                    boxShadow: isToday ? [
                      BoxShadow(
                        color: Color(0xFFE3EF9A).withOpacity(0.8),
                        blurRadius: 4,
                        spreadRadius: 0,
                      )
                    ] : null,
                  ),
                  child: Center(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: getFilteredStudents().where((student) {
                        return selectedStudents.isEmpty ||
                            selectedStudents.contains(student['name']);
                      }).map((student) {
                        bool hasRest = hasRestTime(day, timeIndex, student);
                        return Container(
                          width: restDotSize,
                          height: restDotSize,
                          decoration: BoxDecoration(
                            color: hasRest
                                ? getColorFromString(student['color'])
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              } else if (!isRestSlot) {
                return Container(
                  width: timeSlotWidth,
                  height: timeSlotHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: getFilteredStudents().where((student) {
                        return selectedStudents.isEmpty ||
                            selectedStudents.contains(student['name']);
                      }).map((student) {
                        final schedule = student['schedule'][day] as List<dynamic>;
                        final hasClass = schedule.contains(timeIndex);
                        return Container(
                          width: dotSize,
                          height: dotSize,
                          decoration: BoxDecoration(
                            color: hasClass
                                ? getColorFromString(student['color']).withOpacity(showRestTime ? 0.3 : 1.0)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              } else {
                return Container(
                  width: 0,
                  height: timeSlotHeight,
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}