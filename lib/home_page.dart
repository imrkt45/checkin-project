import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'AdminPage.dart';

// Entry Point
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CheckIn(username: "user1"), // Pass the username dynamically
  ));
}

// TimeSlider Widget with attendance saving
class TimeSlider extends StatefulWidget {
  final String username;
  const TimeSlider({super.key, required this.username});

  @override
  _TimeSliderState createState() => _TimeSliderState();
}

class _TimeSliderState extends State<TimeSlider> {
  Color _sliderColor = Colors.blue;
  double _currentTime = 0; // hours completed
  final double _totalHours = 8.0; // shift length
  Timer? _timer;
  bool buttonClicked = false;

  DateTime? _startTime;
  DateTime? _endTime;
  DateTime? _clockOutTime;

  void _startIncreasingTime() {
    setState(() {
      _currentTime = 0;
      _startTime = DateTime.now();
      _endTime = _startTime!.add(Duration(hours: _totalHours.toInt()));
      _clockOutTime = null; // reset old clock out
      _sliderColor = Colors.green;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTime < _totalHours) {
        setState(() {
          _currentTime += 1 / 3600; // increase in hours
        });
      } else {
        _timer?.cancel();
        setState(() {
          _sliderColor = Colors.blue;
          buttonClicked = false;
        });
      }
    });
  }

  void _stopIncreasingTime() {
    _timer?.cancel();
    setState(() {
      _sliderColor = Colors.blue;
      _clockOutTime = DateTime.now();
    });

    // Save attendance after clock out
    if (_startTime != null && _clockOutTime != null) {
      saveAttendance(widget.username, _startTime!, _clockOutTime!);
    }
  }

  // Save attendance to JSON-server
  Future<void> saveAttendance(String username, DateTime startTime, DateTime endTime) async {
    final url = Uri.parse('http://localhost:3000/attendance');

    final body = {
      "username": username,
      "checkIn": startTime.toIso8601String(),
      "checkOut": endTime.toIso8601String(),
      "durationHours": _currentTime.toStringAsFixed(2)
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        print("Attendance saved successfully: ${response.body}");
      } else {
        print("Failed to save attendance: ${response.body}");
      }
    } catch (e) {
      print("Error saving attendance: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('HH:mm');

    final shiftStart =
    _startTime != null ? timeFormatter.format(_startTime!) : "--:--";
    final shiftEnd =
    _endTime != null ? timeFormatter.format(_endTime!) : "--:--";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Slider(
          value: _currentTime,
          onChanged: null, // auto only
          min: 0,
          max: _totalHours,
          divisions: (_totalHours * 60).toInt(),
          label: '${_currentTime.toStringAsFixed(2)} hrs',
          activeColor: _sliderColor,
        ),
        if (_startTime != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeFormatter.format(DateTime.now()),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                shiftEnd,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Shift   $shiftStart  -  $shiftEnd',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            if (buttonClicked) {
              _stopIncreasingTime();
            } else {
              _startIncreasingTime();
            }
            setState(() {
              buttonClicked = !buttonClicked;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonClicked ? Colors.grey : Colors.green,
          ),
          child: Text(buttonClicked ? 'Clock Out' : 'Clock In'),
        ),
        const SizedBox(height: 20),
        if (_startTime != null && _clockOutTime != null) ...[
          Text(
            "Check In: ${timeFormatter.format(_startTime!)}",
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
          Text(
            "Check Out: ${timeFormatter.format(_clockOutTime!)}",
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
        ]
      ],
    );
  }
}

// CheckIn Page
class CheckIn extends StatelessWidget {
  final String username;
  const CheckIn({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final yearFormatter = DateFormat('y');
    final dateFormatter = DateFormat('dd');
    final dayFormatter = DateFormat('EE');
    final monthFormatter = DateFormat('MMM');
    final currentYear = yearFormatter.format(now);
    final currentDate = dateFormatter.format(now);
    final currentDay = dayFormatter.format(now);
    final currentMonth = monthFormatter.format(now);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Check In/Check Out',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  AdminPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$currentDay $currentMonth $currentDate $currentYear',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                const Text(
                  '08:00 hrs Shift',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
            Expanded(child: TimeSlider(username: username)),
          ],
        ),
      ),
    );
  }
}
