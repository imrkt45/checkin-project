import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List users = [];
  bool isLoading = true;

  Future<void> fetchUsers() async {
    final url = Uri.parse("http://localhost:3000/users");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Failed to load users: ${response.body}");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
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
            DataColumn(label: Text("Check In")),
            DataColumn(label: Text("Check Out")),
          ],
          rows: users.map((user) {
            return DataRow(cells: [
              DataCell(Text(user['id'].toString())),
              DataCell(Text(user['username'] ?? "")),
              DataCell(Text(user['email'] ?? "")),
              DataCell(Text(user['checkIn'] ?? "Not Checked In")),
              DataCell(Text(user['checkOut'] ?? "Not Checked Out")),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
