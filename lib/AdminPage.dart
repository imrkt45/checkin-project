import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List users = [];
  List attendance = [];
  bool isLoading = true;

  Future<void> fetchData() async {
    final usersUrl = Uri.parse("http://localhost:3000/users");
    final attendanceUrl = Uri.parse("http://localhost:3000/attendance");

    try {
      final usersResponse = await http.get(usersUrl);
      final attendanceResponse = await http.get(attendanceUrl);

      if (usersResponse.statusCode == 200 && attendanceResponse.statusCode == 200) {
        setState(() {
          users = json.decode(usersResponse.body);
          attendance = json.decode(attendanceResponse.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("Failed to load data");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, dynamic>? getLatestAttendance(String username) {
    // Filter attendance for the specific user
    final userRecords = attendance
        .where((record) => record['username'] == username)
        .toList();

    if (userRecords.isEmpty) return null;

    // Sort by checkIn date (latest first)
    userRecords.sort((a, b) =>
        DateTime.parse(b['checkIn']).compareTo(DateTime.parse(a['checkIn'])));

    return userRecords.first;
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text("ID")),
            DataColumn(label: Text("Username")),
            DataColumn(label: Text("Email")),
            DataColumn(label: Text("Latest Check In")),
            DataColumn(label: Text("Latest Check Out")),
          ],
          rows: users.map((user) {
            final latest = getLatestAttendance(user['username']);
            return DataRow(cells: [
              DataCell(Text(user['id'].toString())),
              DataCell(Text(user['username'] ?? "")),
              DataCell(Text(user['email'] ?? "")),
              DataCell(Text(latest?['checkIn'] ?? "Not Checked In")),
              DataCell(Text(latest?['checkOut'] ?? "Not Checked Out")),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
